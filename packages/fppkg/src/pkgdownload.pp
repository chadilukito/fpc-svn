unit pkgDownload;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, pkghandler, pkgFppkg;

Type

  { TBaseDownloader }

  TBaseDownloader = Class(TComponent)
  Private
    FBackupFile : Boolean;
  Protected
    // Needs overriding.
    Procedure FTPDownload(Const URL : String; Dest : TStream); Virtual;
    Procedure HTTPDownload(Const URL : String; Dest : TStream); Virtual;
    Procedure FileDownload(Const URL : String; Dest : TStream); Virtual;
  Public
    Procedure Download(Const URL,DestFileName : String);
    Procedure Download(Const URL : String; Dest : TStream);
    Property BackupFiles : Boolean Read FBackupFile Write FBackupFile;
  end;
  TBaseDownloaderClass = Class of TBaseDownloader;

  { TDownloadPackage }

  TDownloadPackage = Class(TPackagehandler)
  Public
    function Execute: Boolean;override;
  end;

procedure RegisterDownloader(const AName:string;Downloaderclass:TBaseDownloaderClass);
function GetDownloader(const AName:string):TBaseDownloaderClass;

procedure DownloadFile(const RemoteFile,LocalFile:String; PackageManager: TpkgFPpkg);


implementation

uses
  contnrs,
  uriparser,
  fprepos,
  pkgglobals,
  pkgoptions,
  pkgmessages,
  pkgrepos;

var
  DownloaderList  : TFPHashList;

procedure RegisterDownloader(const AName:string;Downloaderclass:TBaseDownloaderClass);
begin
  if DownloaderList.Find(AName)<>nil then
    begin
      Error('Downloader already registered');
      exit;
    end;
  DownloaderList.Add(AName,Downloaderclass);
end;


function GetDownloader(const AName:string):TBaseDownloaderClass;
begin
  result:=TBaseDownloaderClass(DownloaderList.Find(AName));
  if result=nil then
    Error('Downloader %s not supported',[AName]);
end;


procedure DownloadFile(const RemoteFile,LocalFile:String; PackageManager: TpkgFPpkg);
var
  DownloaderClass : TBaseDownloaderClass;
begin
  DownloaderClass:=GetDownloader(PackageManager.Options.GlobalSection.Downloader);
  with DownloaderClass.Create(nil) do
    try
      Download(RemoteFile,LocalFile);
    finally
      Free;
    end;
end;


{ TBaseDownloader }

procedure TBaseDownloader.FTPDownload(const URL: String; Dest: TStream);
begin
  Error(SErrNoFTPDownload);
end;

procedure TBaseDownloader.HTTPDownload(const URL: String; Dest: TStream);
begin
  Error(SErrNoHTTPDownload);
end;

procedure TBaseDownloader.FileDownload(const URL: String; Dest: TStream);

Var
  FN : String;
  F : TFileStream;

begin
  URIToFilename(URL,FN);
  If Not FileExists(FN) then
    Error(SErrNoSuchFile,[FN]);
  F:=TFileStream.Create(FN,fmOpenRead);
  Try
    Dest.CopyFrom(F,0);
  Finally
    F.Free;
  end;
end;

procedure TBaseDownloader.Download(const URL, DestFileName: String);

Var
  F : TFileStream;

begin
  If FileExists(DestFileName) and BackupFiles then
    BackupFile(DestFileName);
  try
    F:=TFileStream.Create(DestFileName,fmCreate);
    try
      Download(URL,F);
    finally
      F.Free;
    end;
  except
    DeleteFile(DestFileName);
    raise;
  end;
end;

procedure TBaseDownloader.Download(const URL: String; Dest: TStream);

Var
  URI : TURI;
  P : String;

begin
  URI:=ParseURI(URL);
  P:=URI.Protocol;
  If CompareText(P,'ftp')=0 then
    FTPDownload(URL,Dest)
  else if CompareText(P,'http')=0 then
    HTTPDownload(URL,Dest)
  else if CompareText(P,'file')=0 then
    FileDownload(URL,Dest)
  else
    Error(SErrUnknownProtocol,[P, URL]);
end;


{ TDownloadPackage }

function TDownloadPackage.Execute: Boolean;
var
  DownloaderClass : TBaseDownloaderClass;
  P : TFPPackage;
  RemoteArchive: string;
begin
  Result := False;
  P:=PackageManager.PackageByName(PackageName, pkgpkAvailable);
  DownloaderClass:=GetDownloader(PackageManager.Options.GlobalSection.Downloader);
  if Assigned(DownloaderClass) then
    begin
      with DownloaderClass.Create(nil) do
        try
          RemoteArchive := PackageManager.PackageRemoteArchive(P);
          if RemoteArchive <> '' then
            begin
              Log(llCommands,SLogDownloading,[RemoteArchive,PackageManager.PackageLocalArchive(P)]);
              pkgglobals.log(llProgres,SProgrDownloadPackage,[P.Name, P.Version.AsString]);

              // Force the existing of the archives-directory if it is being used
              if (P.Name<>CurrentDirPackageName) and (P.Name<>CmdLinePackageName) then
                ForceDirectories(PackageManager.Options.GlobalSection.ArchivesDir);

              Download(RemoteArchive,PackageManager.PackageLocalArchive(P));
              Result := True;
            end
          else
            Error(SErrDownloadPackageFailed);
        finally
          Free;
        end;
    end;
end;


initialization
  DownloaderList:=TFPHashList.Create;
  RegisterDownloader('base',TBaseDownloader);
  RegisterPkgHandler('downloadpackage',TDownloadPackage);
finalization
  FreeAndNil(DownloaderList);
end.

