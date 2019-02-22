{ %CPU=aarch64 }
{ %skiptarget=darwin }

{
  Tests that arguments and the result are not required to be sign/zero extended.
}

procedure ProcByte(p: byte);
begin
  if p <> $78 then
    Halt(1);
end;

procedure ProcWord(p: word);
begin
  if p <> $5678 then
    Halt(2);
end;

procedure ProcDWord(p: dword);
begin
  if p <> $12345678 then
    Halt(3);
end;

function RetByte: byte;
var
  q: qword;
begin
  q:=$1111111112345678;
  asm
    ldr x0,q
  end;
end;

function RetWord: word;
var
  q: qword;
begin
  q:=$1111111112345678;
  asm
    ldr x0,q
  end;
end;

function RetDWord: dword;
var
  q: qword;
begin
  q:=$1111111112345678;
  asm
    ldr x0,q
  end;
end;

procedure TestParams;
var
  q: qword;
begin
  q:=$1111111112345678;
  asm
    ldr x0,q
    bl ProcByte
    ldr x0,q
    bl ProcWord
    ldr x0,q
    bl ProcDWord
  end;
end;

procedure TestReturns;
begin
  if RetByte <> $78 then
    Halt(11);
  if RetWord <> $5678 then
    Halt(12);
  if RetDWord <> $12345678 then
    Halt(13);
end;

begin
  TestParams;
  TestReturns;
end.
