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

    P:=AddPackage('iconvenc');
{$ifdef ALLPACKAGES}
    P.Directory:='iconvenc';
{$endif ALLPACKAGES}
    P.Version:='2.2.2-0';
    P.Author := 'Marco van de Voort';
    P.License := 'Library: LGPL2 or later, header: LGPL with modification, ';
    P.ExternalURL := 'www.freepascal.org';
    P.Email := '';
    P.Description := 'A libiconv header translation.';
    P.NeedLibC:= true;

    P.SourcePath.Add('src');
    P.IncludePath.Add('src');

    T:=P.Targets.AddUnit('iconvenc.pas');

    P.ExamplePath.Add('examples');
    P.Targets.AddExampleProgram('iconvtest.pp');

{$ifndef ALLPACKAGES}
    Run;
    end;
end.
{$endif ALLPACKAGES}
