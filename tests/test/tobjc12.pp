{ %target=darwin }
{ %cpu=powerpc,i386 }

{$mode objfpc}
{$modeswitch objectivec1}

var
  a: NSObject;
  b: pobjc_class;
  c: pobjc_class;
  d: pobjc_class;
begin
  a:=NSObject(NSObject(NSObject.alloc).init);
  b:=a._class;
  c:=NSObject.classClass;
  d:=a.classClass;
  if (b<>c) or
     (b<>d) then
    begin
      writeln('error: NSObject.Class <> NSObjectInstance.Class');
      halt(1);
    end;
end.
