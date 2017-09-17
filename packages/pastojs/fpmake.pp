{$ifndef ALLPACKAGES}
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;

Var
  P : TPackage;
  T : TTarget;

begin
  With Installer do 
    begin
{$endif ALLPACKAGES}

    P:=AddPackage('pastojs');
{$ifdef ALLPACKAGES}
    P.Directory:=ADirectory;
{$endif ALLPACKAGES}

    P.Version:='3.1.1';
    P.OSes := AllOses-[embedded,msdos,win16,macos,palmos];
    P.Dependencies.Add('fcl-js');
    P.Dependencies.Add('fcl-passrc');

    P.Author := 'Free Pascal development team';
    P.License := 'LGPL with modification, ';
    P.HomepageURL := 'www.freepascal.org';

    P.SourcePath.Add('src');
    P.SupportBuildModes := [bmOneByOne];

    P.Options.Add('-S2h');

    T:=P.Targets.AddUnit('fppas2js.pp');
    T:=P.Targets.AddUnit('fppjssrcmap.pp');
{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
