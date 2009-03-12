{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by the Free Pascal development team

    TCGIApplication class.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{ $define CGIDEBUG}
{$mode objfpc}
{$H+}

unit custcgi;

Interface

uses
  CustApp,Classes,SysUtils, httpdefs;

Const
  CGIVarCount = 34;

Type
  TCGIVarArray = Array[1..CGIVarCount] of String;

Const
  CgiVarNames : TCGIVarArray =
   ({ 1  } 'AUTH_TYPE',
    { 2  } 'CONTENT_LENGTH',
    { 3  } 'CONTENT_TYPE',
    { 4  } 'GATEWAY_INTERFACE',
    { 5  } 'PATH_INFO',
    { 6  } 'PATH_TRANSLATED',
    { 7  } 'QUERY_STRING',
    { 8  } 'REMOTE_ADDR',
    { 9  } 'REMOTE_HOST',
    { 10 } 'REMOTE_IDENT',
    { 11 } 'REMOTE_USER',
    { 12 } 'REQUEST_METHOD',
    { 13 } 'SCRIPT_NAME',
    { 14 } 'SERVER_NAME',
    { 15 } 'SERVER_PORT',
    { 16 } 'SERVER_PROTOCOL',
    { 17 } 'SERVER_SOFTWARE',
    { 18 } 'HTTP_ACCEPT',
    { 19 } 'HTTP_ACCEPT_CHARSET',
    { 20 } 'HTTP_ACCEPT_ENCODING',
    { 21 } 'HTTP_IF_MODIFIED_SINCE',
    { 22 } 'HTTP_REFERER',
    { 23 } 'HTTP_USER_AGENT',
    { 24 } 'HTTP_COOKIE',
     // Additional Apache vars
    { 25 } 'HTTP_CONNECTION',
    { 26 } 'HTTP_ACCEPT_LANGUAGE',
    { 27 } 'HTTP_HOST',
    { 28 } 'SERVER_SIGNATURE',
    { 29 } 'SERVER_ADDR',
    { 30 } 'DOCUMENT_ROOT',
    { 31 } 'SERVER_ADMIN',
    { 32 } 'SCRIPT_FILENAME',
    { 33 } 'REMOTE_PORT',
    { 34 } 'REQUEST_URI'
    );
    

Type
  { TCGIRequest }
  TCustomCGIApplication = Class;

  TCGIRequest = Class(TRequest)
  Private
    FCGI : TCustomCGIApplication;
    function GetCGIVar(Index: integer): String;
  Protected
    Function GetFieldValue(Index : Integer) : String; override;
    Procedure InitFromEnvironment;
    procedure ReadContent; override;
  Public
    Constructor CreateCGI(ACGI : TCustomCGIApplication);
    Property GatewayInterface : String Index 1 Read GetCGIVar;
    Property RemoteIdent : String Index 2 read GetCGIVar;
    Property RemoteUser : String Index 3 read GetCGIVar;
    Property RequestMethod : String Index 4 read GetCGIVar;
    Property ServerName : String Index 5 read GetCGIVar;
    Property ServerProtocol : String Index 6 read GetCGIVar;
    Property ServerSoftware : String Index 7 read GetCGIVar;
  end;
  
  { TCGIResponse }

  TCGIResponse = Class(TResponse)
  private
    FCGI : TCustomCGIApplication;
    FOutput : TStream;
  Protected
    Procedure DoSendHeaders(Headers : TStrings); override;
    Procedure DoSendContent; override;
  Public
    Constructor CreateCGI(ACGI : TCustomCGIApplication; AStream : TStream);
  end;

  { TCustomCgiApplication }

  TCustomCGIApplication = Class(TCustomApplication)
  Private
    FResponse : TCGIResponse;
    FRequest : TCGIRequest;
    FEmail : String;
    FAdministrator : String;
    FOutput : TStream;
    FHandleGetOnPost : Boolean;
    FRedirectOnError : Boolean;
    FRedirectOnErrorURL : String;
    Function GetEmail : String;
    Function GetAdministrator : String;
    Function GetRequestVariable(Const VarName : String) : String;
    Function GetRequestVariableCount : Integer;
  Public
    constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    Property Request : TCGIRequest read FRequest;
    Property Response: TCGIResponse Read FResponse;
    Procedure AddResponse(Const S : String);
    Procedure AddResponse(Const Fmt : String; Args : Array of const);
    Procedure AddResponseLn(Const S : String);
    Procedure AddResponseLn(Const Fmt : String; Args : Array of const);
    Procedure Initialize; override;
    Procedure GetCGIVarList(List : TStrings);
    Procedure ShowException(E: Exception);override;
    Procedure DeleteFormFiles;
    Procedure DoRun; override;
    Procedure handleRequest(ARequest : TRequest; AResponse : TResponse); virtual;
    Function GetTempCGIFileName : String;
    Function VariableIsUploadedFile(Const VarName : String) : boolean;
    Function UploadedFileName(Const VarName : String) : String;
    Property Email : String Read GetEmail Write FEmail;
    Property Administrator : String Read GetAdministrator Write FAdministrator;
    Property HandleGetOnPost : Boolean Read FHandleGetOnPost Write FHandleGetOnPost;
    Property RequestVariables[VarName : String] : String Read GetRequestVariable;
    Property RequestVariableCount : Integer Read GetRequestVariableCount;
    Property RedirectOnError : boolean Read FRedirectOnError Write FRedirectOnError;
    Property RedirectOnErrorURL : string Read FRedirectOnErrorURL Write FRedirectOnErrorURL;
  end;

ResourceString
  SWebMaster = 'webmaster';
  SCGIError  = 'CGI Error';
  SAppEncounteredError = 'The application encountered the following error:';
  SError     = 'Error: ';
  SNotify    = 'Notify: ';
  SErrNoContentLength = 'No content length passed from server!';

Implementation

uses
{$ifdef CGIDEBUG}
  dbugintf,
{$endif}
  iostream;

Const
  MapCgiToHTTP : TCGIVarArray =
   ({ 1: 'AUTH_TYPE'               } fieldWWWAuthenticate, // ?
    { 2: 'CONTENT_LENGTH'          } FieldContentLength,
    { 3: 'CONTENT_TYPE'            } FieldContentType,
    { 4: 'GATEWAY_INTERFACE'       } '',
    { 5: 'PATH_INFO'               } '',
    { 6: 'PATH_TRANSLATED'         } '',
    { 7: 'QUERY_STRING'            } '',
    { 8: 'REMOTE_ADDR'             } '',
    { 9: 'REMOTE_HOST'             } '',
    { 10: 'REMOTE_IDENT'           } '',
    { 11: 'REMOTE_USER'            } '',
    { 12: 'REQUEST_METHOD'         } '',
    { 13: 'SCRIPT_NAME'            } '',
    { 14: 'SERVER_NAME'            } '',
    { 15: 'SERVER_PORT'            } '',
    { 16: 'SERVER_PROTOCOL'        } '',
    { 17: 'SERVER_SOFTWARE'        } '',
    { 18: 'HTTP_ACCEPT'            } FieldAccept,
    { 19: 'HTTP_ACCEPT_CHARSET'    } FieldAcceptCharset,
    { 20: 'HTTP_ACCEPT_ENCODING'   } FieldAcceptEncoding,
    { 21: 'HTTP_IF_MODIFIED_SINCE' } FieldIfModifiedSince,
    { 22: 'HTTP_REFERER'           } FieldReferer,
    { 23: 'HTTP_USER_AGENT'        } FieldUserAgent,
    { 24: 'HTTP_COOKIE'            } FieldCookie,
     // Additional Apache vars
    { 25: 'HTTP_CONNECTION'        } FieldConnection,
    { 26: 'HTTP_ACCEPT_LANGUAGE'   } FieldAcceptLanguage,
    { 27: 'HTTP_HOST'              } '',
    { 28: 'SERVER_SIGNATURE'       } '',
    { 29: 'SERVER_ADDR'            } '',
    { 30: 'DOCUMENT_ROOT'          } '',
    { 31: 'SERVER_ADMIN'           } '',
    { 32: 'SCRIPT_FILENAME'        } '',
    { 33: 'REMOTE_PORT'            } '',
    { 34: 'REQUEST_URI'            } ''
  );


Destructor TCustomCGIApplication.Destroy;

begin
  DeleteFormFiles;
  FreeAndNil(FRequest);
  FreeAndNil(FResponse);
  FreeAndNil(FOutPut);
  Inherited;
end;

Function TCustomCGIApplication.GetTempCGIFileName : String;

begin
//Result:=GetTempFileName('/tmp/','CGI') {Hard coded path no good for all OS-es}
{
GetTempDir returns the OS temporary directory if possible, or from the
environment variable TEMP . For CGI programs you need to pass global environment
 variables, it is not automatic. For example in the Apache httpd.conf with a
"PassEnv TEMP" or "SetEnv TEMP /pathtotmpdir" line so the web server passes this
 global environment variable to the CGI programs' local environment variables.
}
  Result := GetTempFileName(GetTempDir, 'CGI');
end;

Procedure TCustomCGIApplication.DeleteFormFiles;

Var
  I : Integer;
  FN : String;

begin
  If Assigned(FRequest) then
    For I:=0 to FRequest.Files.Count-1 do
      begin
      FN:=FRequest.Files[I].LocalFileName;
      If FileExists(FN) then
        DeleteFile(FN);
      end;
end;

procedure TCustomCGIApplication.DoRun;
begin
  HandleRequest(FRequest,FResponse);
  If Not FResponse.ContentSent then
    begin
    FResponse.SendContent;
    end;
  Terminate;
end;

procedure TCustomCGIApplication.HandleRequest(ARequest: TRequest; AResponse: TResponse);
begin
  // Needs overriding;
end;

Procedure TCustomCGIApplication.Initialize;

begin
  StopOnException:=True;
  Inherited;
  FRequest:=TCGIRequest.CreateCGI(Self);
  FRequest.InitFromEnvironment;
  FRequest.InitRequestVars;
  FOutput:=TIOStream.Create(iosOutput);
  FResponse:=TCGIResponse.CreateCGI(Self,Self.FOutput);
end;

Procedure TCustomCGIApplication.GetCGIVarList(List : TStrings);

Var
  I : Integer;

begin
  List.Clear;
  For I:=1 to cgiVarCount do
    List.Add(CGIVarNames[i]+'='+GetEnvironmentVariable(CGIVarNames[i]));
end;


Procedure TCustomCGIApplication.ShowException(E: Exception);

Var
  TheEmail : String;
  FrameCount: integer;
  Frames: PPointer;
  FrameNumber:Integer;
  S : TStrings;

begin
  If RedirectOnError and not FResponse.HeadersSent then
    begin
    FResponse.Location := RedirectOnErrorURL;
    FResponse.Code := 301;
    FResponse.SendContent;
    Exit;
    end;
  If not FResponse.HeadersSent then
    FResponse.ContentType:='text/html';
  If (FResponse.ContentType='text/html') then
    begin
    S:=TStringList.Create;
    Try
      With S do
        begin
        Add('<html><head><title>'+Title+': '+SCGIError+'</title></head>'+LineEnding);
        Add('<body>');
        Add('<center><hr><h1>'+Title+': ERROR</h1><hr></center><br><br>');
        Add(SAppEncounteredError+'<br>');
        Add('<ul>');
        Add('<li>'+SError+' <b>'+E.Message+'</b>');
        Add('<li> Stack trace:<br>');
        Add(BackTraceStrFunc(ExceptAddr)+'<br>');
        FrameCount:=ExceptFrameCount;
        Frames:=ExceptFrames;
        for FrameNumber := 0 to FrameCount-1 do
          Add(BackTraceStrFunc(Frames[FrameNumber])+'<br>');
        Add('</ul><hr>');
        TheEmail:=Email;
        If (TheEmail<>'') then
          Add('<h5><p><i>'+SNotify+Administrator+': <a href="mailto:'+TheEmail+'">'+TheEmail+'</a></i></p></h5>');
        Add('</body></html>');
        end;
      FResponse.Content:=S.Text;
      FResponse.SendContent;
    Finally
      FreeAndNil(S);
    end;
    end;
end;

Function TCustomCGIApplication.GetEmail : String;

Var
  H : String;

begin
  If (FEmail='') then
    begin
    H:=Request.ServerName;
    If (H<>'') then
      Result:=Administrator+'@'+H
    else
      Result:='';
    end
  else
    Result:=Email;
end;

Function TCustomCGIApplication.GetAdministrator : String;

begin
  If (FADministrator<>'') then
    Result:=FAdministrator
  else
    Result:=SWebMaster;
end;

constructor TCGIRequest.CreateCGI(ACGI: TCustomCGIApplication);
begin
  Inherited Create;
  FCGI:=ACGI;
end;

Function TCustomCGIApplication.GetRequestVariable(Const VarName : String) : String;

begin
 If Assigned(Request) then
   Result:=FRequest.QueryFields.Values[VarName]
 else
   Result:='';
end;

Function TCustomCGIApplication.GetRequestVariableCount : Integer;

begin
 If Assigned(Request) then
    Result:=FRequest.QueryFields.Count
  else
    Result:=0;
end;

constructor TCustomCGIApplication.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHandleGetOnPost := True;
  FRedirectOnError := False;
  FRedirectOnErrorURL := '';
end;

Procedure TCustomCGIApplication.AddResponse(Const S : String);

Var
  L : Integer;

begin
  L:=Length(S);
  If L>0 then
    Response.Content:=Response.Content+S;
end;

Procedure TCustomCGIApplication.AddResponse(Const Fmt : String; Args : Array of const);

begin
  AddResponse(Format(Fmt,Args));
end;

Procedure TCustomCGIApplication.AddResponseLN(Const S : String);


begin
  AddResponse(S+LineEnding);
end;

Procedure TCustomCGIApplication.AddResponseLN(Const Fmt : String; Args : Array of const);

begin
  AddResponseLN(Format(Fmt,Args));
end;

Function TCustomCGIApplication.VariableIsUploadedFile(Const VarName : String) : boolean;

begin
  Result:=FRequest.Files.IndexOfFile(VarName)<>-1;
end;

Function TCustomCGIApplication.UploadedFileName(Const VarName : String) : String;

begin
  If VariableIsUploadedFile(VarName) then
    Result:=FRequest.Files.FileByName(VarName).LocalFileName
  else
    Result:='';
end;

{ TCGIHTTPRequest }

function TCGIRequest.GetCGIVar(Index: integer): String;

Var
  R : String;

begin
  Case Index of
   1 : R:=GetEnvironmentVariable(CGIVarNames[4]); // Property GatewayInterface : String Index 1 Read GetCGIVar;
   2 : R:=GetEnvironmentVariable(CGIVarNames[10]); // Property RemoteIdent : String Index 2 read GetCGIVar;
   3 : R:=GetEnvironmentVariable(CGIVarNames[11]); // Property RemoteUser : String Index 3 read GetCGIVar;
   4 : R:=GetEnvironmentVariable(CGIVarNames[12]); // Property RequestMethod : String Index 4 read GetCGIVar;
   5 : R:=GetEnvironmentVariable(CGIVarNames[14]); // Property ServerName : String Index 5 read GetCGIVar;
   6 : R:=GetEnvironmentVariable(CGIVarNames[16]); // Property ServerProtocol : String Index 6 read GetCGIVar;
   7 : R:=GetEnvironmentVariable(CGIVarNames[17]); // Property ServerSoftware : String Index 7 read GetCGIVar;
  end;
  Result:=HTTPDecode(R);
end;

Procedure TCGIRequest.InitFromEnvironment;


Var
  I : Integer;
  N,V,OV : String;
  
  
begin
  For I:=1 to CGIVarCount do
    begin
    N:=MapCgiToHTTP[i];
    if (N<>'') then
      begin
      OV:=GetFieldByName(N);
      V:=GetEnvironmentVariable(CGIVarNames[I]);
      If (OV='') or (V<>'') then
        SetFieldByName(N,HTTPDecode(V));
      end;
    end;
end;

procedure TCGIRequest.ReadContent;
var
  I : TIOStream;
  Cl : Integer;
  B : Byte;
begin
  Cl := ContentLength;
  I:=TIOStream.Create(iosInput);
  Try
    if (CL<>0) then
      begin
      SetLength(FContent,Cl);
      I.Read(FContent[1],Cl);
      end
    else
      begin
      FContent:='';
      While (I.Read(B,1)>0) do
        FContent:=FContent + chr(B);
      end;
  Finally
    I.Free;
  end;
  FContentRead:=True;
end;

Function TCGIRequest.GetFieldValue(Index : Integer) : String;

  Function DecodeVar(I : Integer) : String;
  
  begin
    Result:=HTTPDecode(GetEnvironmentVariable(CGIVarNames[I]));
  end;

begin
  Case Index of
    25 : Result:=Decodevar(5); // Property PathInfo
    26 : Result:=DecodeVar(6); // Property PathTranslated
    27 : Result:=DecodeVar(8); // Property RemoteAddress
    28 : Result:=DecodeVar(9); // Property RemoteHost
    29 : Result:=DecodeVar(13); // Property ScriptName
    30 : Result:=DecodeVar(15); // Property ServerPort
    31 : Result:=DecodeVar(12); // Property RequestMethod
    33 : Result:=DecodeVar(7); // Property QueryString
  else
    Result:=Inherited GetFieldValue(Index);
  end;
end;


{ TCGIResponse }

procedure TCGIResponse.DoSendHeaders(Headers : TStrings);
begin
{$ifdef CGIDEBUG}
  SendMethodEnter('TCGIResponse.DoSendHeaders');
  SendDebug('Headers: '+Headers.Text);
{$endif}
  if Assigned(FOutput) then
    Headers.SaveToStream(FOutput);
{$ifdef CGIDEBUG}
  SendMethodExit('TCGIResponse.DoSendHeaders');
{$endif}
end;

procedure TCGIResponse.DoSendContent;
begin
{$ifdef CGIDEBUG}
  SendMethodEnter('TCGIResponse.DoSendContent');
{$endif}
  If Assigned(ContentStream) then
    FOutput.CopyFrom(ContentStream,0)
  else
    Contents.SaveToStream(FOutput);
{$ifdef CGIDEBUG}
  SendMethodExit('TCGIResponse.DoSendContent');
{$endif}
end;

constructor TCGIResponse.CreateCGI(ACGI: TCustomCGIApplication; AStream: TStream);
begin
  inherited Create(ACGI.Request);
  FCGI:=ACGI;
  FOutput:=AStream;
end;

initialization

finalization
{$ifdef CGIDEBUG}
  if (SendError<>'') then
    Writeln('Debug failed: ',SendError);
{$endif}
end.
