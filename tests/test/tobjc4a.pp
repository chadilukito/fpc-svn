{ %fail }
{ %target=darwin }
{ %cpu=powerpc,i386 }

{$modeswitch objectivec1}

type
  ta = objcclass
    { no destructors in Objective-C }
    destructor done; message 'done';
  end; external;

begin
end.
