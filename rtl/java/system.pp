{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2006 by Florian Klaempfl
    member of the Free Pascal development team.

    System unit for embedded systems

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

Unit system;

{$namespace org.freepascal.rtl}

{*****************************************************************************}
                                    interface
{*****************************************************************************}

{$define FPC_IS_SYSTEM}

{$I-,Q-,H-,R-,V-}
{$implicitexceptions off}
{$mode objfpc}

{$undef FPC_HAS_FEATURE_ANSISTRINGS}
{$undef FPC_HAS_FEATURE_TEXTIO}
{$undef FPC_HAS_FEATURE_VARIANTS}
{$undef FPC_HAS_FEATURE_CLASSES}
{$undef FPC_HAS_FEATURE_EXCEPTIONS}
{$undef FPC_HAS_FEATURE_OBJECTS}
{$undef FPC_HAS_FEATURE_RTTI}
{$undef FPC_HAS_FEATURE_FILEIO}
{$undef FPC_INCLUDE_SOFTWARE_INT64_TO_DOUBLE}

Type
  { The compiler has all integer types defined internally. Here
    we define only aliases }
  DWord    = LongWord;
  Cardinal = LongWord;
  Integer  = SmallInt;
  UInt64   = QWord;
  SizeInt  = Longint;
  SizeUInt = Longint;
  PtrInt   = Longint;
  PtrUInt  = Longint;

  ValReal = Double;

  AnsiChar    = Char;
  UnicodeChar = WideChar;

  { map comp to int64, }
  Comp = Int64;

  HResult = type longint;

  { Java primitive types }
  jboolean = boolean;
  jbyte = shortint;
  jshort = smallint;
  jint = longint;
  jlong = int64;
  jchar = widechar;
  jfloat = single;
  jdouble = double;

  Arr1jboolean = array of jboolean;
  Arr1jbyte = array of jbyte;
  Arr1jshort = array of jshort;
  Arr1jint = array of jint;
  Arr1jlong = array of jlong;
  Arr1jchar = array of jchar;
  Arr1jfloat = array of jfloat;
  Arr1jdouble = array of jdouble;

  Arr2jboolean = array of Arr1jboolean;
  Arr2jbyte = array of Arr1jbyte;
  Arr2jshort = array of Arr1jshort;
  Arr2jint = array of Arr1jint;
  Arr2jlong = array of Arr1jlong;
  Arr2jchar = array of Arr1jchar;
  Arr2jfloat = array of Arr1jfloat;
  Arr2jdouble = array of Arr1jdouble;

  Arr3jboolean = array of Arr2jboolean;
  Arr3jbyte = array of Arr2jbyte;
  Arr3jshort = array of Arr2jshort;
  Arr3jint = array of Arr2jint;
  Arr3jlong = array of Arr2jlong;
  Arr3jchar = array of Arr2jchar;
  Arr3jfloat = array of Arr2jfloat;
  Arr3jdouble = array of Arr2jdouble;

const
{ max. values for longint and int}
  maxLongint  = $7fffffff;
  maxSmallint = 32767;

  maxint   = maxsmallint;


{ Java base class type }
{$i java_sysh.inc}
{$i java_sys.inc}

type
  TObject = class(JLObject)
   strict private
    DestructorCalled: Boolean;
   public
    procedure Free;
    destructor Destroy; virtual;
    procedure finalize; override;
  end;

{$i innr.inc}
{$i jmathh.inc}
{$i jrech.inc}
{$i jdynarrh.inc}

{$ifndef nounsupported}
type
  tmethod = record
    code: jlobject;
  end;

const
   vtInteger       = 0;
   vtBoolean       = 1;
   vtChar          = 2;
{$ifndef FPUNONE}
   vtExtended      = 3;
{$endif}
   vtString        = 4;
   vtPointer       = 5;
   vtPChar         = 6;
   vtObject        = 7;
   vtClass         = 8;
   vtWideChar      = 9;
   vtPWideChar     = 10;
   vtAnsiString    = 11;
   vtCurrency      = 12;
   vtVariant       = 13;
   vtInterface     = 14;
   vtWideString    = 15;
   vtInt64         = 16;
   vtQWord         = 17;
   vtUnicodeString = 18;

type
  TVarRec = record
     case VType : sizeint of
{$ifdef ENDIAN_BIG}
       vtInteger       : ({$IFDEF CPU64}integerdummy1 : Longint;{$ENDIF CPU64}VInteger: Longint);
       vtBoolean       : ({$IFDEF CPU64}booldummy : Longint;{$ENDIF CPU64}booldummy1,booldummy2,booldummy3: byte; VBoolean: Boolean);
       vtChar          : ({$IFDEF CPU64}chardummy : Longint;{$ENDIF CPU64}chardummy1,chardummy2,chardummy3: byte; VChar: Char);
       vtWideChar      : ({$IFDEF CPU64}widechardummy : Longint;{$ENDIF CPU64}wchardummy1,VWideChar: WideChar);
{$else ENDIAN_BIG}
       vtInteger       : (VInteger: Longint);
       vtBoolean       : (VBoolean: Boolean);
       vtChar          : (VChar: Char);
       vtWideChar      : (VWideChar: WideChar);
{$endif ENDIAN_BIG}
//       vtString        : (VString: PShortString);
//       vtPointer       : (VPointer: Pointer);
///       vtPChar         : (VPChar: PChar);
       vtObject        : (VObject: TObject);
//       vtClass         : (VClass: TClass);
//       vtPWideChar     : (VPWideChar: PWideChar);
       vtAnsiString    : (VAnsiString: JLString);
       vtCurrency      : (VCurrency: Currency);
//       vtVariant       : (VVariant: PVariant);
       vtInterface     : (VInterface: JLObject);
       vtWideString    : (VWideString: JLString);
       vtInt64         : (VInt64: Int64);
       vtUnicodeString : (VUnicodeString: JLString);
       vtQWord         : (VQWord: QWord);
   end;

{$endif}

Function  lo(i : Integer) : byte;  [INTERNPROC: fpc_in_lo_Word];
Function  lo(w : Word) : byte;     [INTERNPROC: fpc_in_lo_Word];
Function  lo(l : Longint) : Word;  [INTERNPROC: fpc_in_lo_long];
Function  lo(l : DWord) : Word;    [INTERNPROC: fpc_in_lo_long];
Function  lo(i : Int64) : DWord;   [INTERNPROC: fpc_in_lo_qword];
Function  lo(q : QWord) : DWord;   [INTERNPROC: fpc_in_lo_qword];
Function  hi(i : Integer) : byte;  [INTERNPROC: fpc_in_hi_Word];
Function  hi(w : Word) : byte;     [INTERNPROC: fpc_in_hi_Word];
Function  hi(l : Longint) : Word;  [INTERNPROC: fpc_in_hi_long];
Function  hi(l : DWord) : Word;    [INTERNPROC: fpc_in_hi_long];
Function  hi(i : Int64) : DWord;   [INTERNPROC: fpc_in_hi_qword];
Function  hi(q : QWord) : DWord;   [INTERNPROC: fpc_in_hi_qword];

Function chr(b : byte) : AnsiChar;      [INTERNPROC: fpc_in_chr_byte];

function RorByte(Const AValue : Byte): Byte;[internproc:fpc_in_ror_x];
function RorByte(Const AValue : Byte;Dist : Byte): Byte;[internproc:fpc_in_ror_x_x];

function RolByte(Const AValue : Byte): Byte;[internproc:fpc_in_rol_x];
function RolByte(Const AValue : Byte;Dist : Byte): Byte;[internproc:fpc_in_rol_x_x];

function RorWord(Const AValue : Word): Word;[internproc:fpc_in_ror_x];
function RorWord(Const AValue : Word;Dist : Byte): Word;[internproc:fpc_in_ror_x_x];

function RolWord(Const AValue : Word): Word;[internproc:fpc_in_rol_x];
function RolWord(Const AValue : Word;Dist : Byte): Word;[internproc:fpc_in_rol_x_x];

function RorDWord(Const AValue : DWord): DWord;[internproc:fpc_in_ror_x];
function RorDWord(Const AValue : DWord;Dist : Byte): DWord;[internproc:fpc_in_ror_x_x];

function RolDWord(Const AValue : DWord): DWord;[internproc:fpc_in_rol_x];
function RolDWord(Const AValue : DWord;Dist : Byte): DWord;[internproc:fpc_in_rol_x_x];

function RorQWord(Const AValue : QWord): QWord;[internproc:fpc_in_ror_x];
function RorQWord(Const AValue : QWord;Dist : Byte): QWord;[internproc:fpc_in_ror_x_x];

function RolQWord(Const AValue : QWord): QWord;[internproc:fpc_in_rol_x];
function RolQWord(Const AValue : QWord;Dist : Byte): QWord;[internproc:fpc_in_rol_x_x];

function SarShortint(Const AValue : Shortint): Shortint;[internproc:fpc_in_sar_x];
function SarShortint(Const AValue : Shortint;Shift : Byte): Shortint;[internproc:fpc_in_sar_x_y];

function SarSmallint(Const AValue : Smallint): Smallint;[internproc:fpc_in_sar_x];
function SarSmallint(Const AValue : Smallint;Shift : Byte): Smallint;[internproc:fpc_in_sar_x_y];

function SarLongint(Const AValue : Longint): Longint;[internproc:fpc_in_sar_x];
function SarLongint(Const AValue : Longint;Shift : Byte): Longint;[internproc:fpc_in_sar_x_y];

function SarInt64(Const AValue : Int64): Int64;[internproc:fpc_in_sar_x];
function SarInt64(Const AValue : Int64;Shift : Byte): Int64;[internproc:fpc_in_sar_x_y];


{$i compproc.inc}

{$i ustringh.inc}

{*****************************************************************************}
                                 implementation
{*****************************************************************************}

{i jdynarr.inc}
{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2011 by Jonas Maebe
    member of the Free Pascal development team.

    This file implements the helper routines for dyn. Arrays in FPC

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************
}

{$i ustrings.inc}
{$i rtti.inc}
{$i jrec.inc}

function min(a,b : longint) : longint;
  begin
     if a<=b then
       min:=a
     else
       min:=b;
  end;

{ copying helpers }

{ also for booleans }
procedure fpc_copy_jbyte_array(src, dst: TJByteArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=src[i];
  end;


procedure fpc_copy_jshort_array(src, dst: TJShortArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=src[i];
  end;


procedure fpc_copy_jint_array(src, dst: TJIntArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=src[i];
  end;


procedure fpc_copy_jlong_array(src, dst: TJLongArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=src[i];
  end;


procedure fpc_copy_jchar_array(src, dst: TJCharArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=src[i];
  end;


procedure fpc_copy_jfloat_array(src, dst: TJFloatArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=src[i];
  end;


procedure fpc_copy_jdouble_array(src, dst: TJDoubleArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=src[i];
  end;


procedure fpc_copy_jobject_array(src, dst: TJObjectArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=src[i];
  end;


procedure fpc_copy_jrecord_array(src, dst: TJRecordArray);
  var
    i: longint;
  begin
    for i:=0 to min(high(src),high(dst)) do
      dst[i]:=FpcBaseRecordType(src[i].clone);
  end;


{ 1-dimensional setlength routines }

function fpc_setlength_dynarr_jbyte(aorg, anew: TJByteArray; deepcopy: boolean): TJByteArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        fpc_copy_jbyte_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


function fpc_setlength_dynarr_jshort(aorg, anew: TJShortArray; deepcopy: boolean): TJShortArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        fpc_copy_jshort_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


function fpc_setlength_dynarr_jint(aorg, anew: TJIntArray; deepcopy: boolean): TJIntArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        fpc_copy_jint_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


function fpc_setlength_dynarr_jlong(aorg, anew: TJLongArray; deepcopy: boolean): TJLongArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        fpc_copy_jlong_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


function fpc_setlength_dynarr_jchar(aorg, anew: TJCharArray; deepcopy: boolean): TJCharArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        fpc_copy_jchar_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


function fpc_setlength_dynarr_jfloat(aorg, anew: TJFloatArray; deepcopy: boolean): TJFloatArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        fpc_copy_jfloat_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


function fpc_setlength_dynarr_jdouble(aorg, anew: TJDoubleArray; deepcopy: boolean): TJDoubleArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        fpc_copy_jdouble_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


function fpc_setlength_dynarr_jobject(aorg, anew: TJObjectArray; deepcopy: boolean; docopy : boolean = true): TJObjectArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        if docopy then
          fpc_copy_jobject_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


function fpc_setlength_dynarr_jrecord(aorg, anew: TJRecordArray; deepcopy: boolean): TJRecordArray;
  begin
    if deepcopy or
       (length(aorg)<>length(anew)) then
      begin
        fpc_copy_jrecord_array(aorg,anew);
        result:=anew
      end
    else
      result:=aorg;
  end;


{ multi-dimensional setlength routine }
function fpc_setlength_dynarr_multidim(aorg, anew: TJObjectArray; deepcopy: boolean; ndim: longint; eletype: jchar): TJObjectArray;
  var
    partdone,
    i: longint;

  begin
    { resize the current dimension; no need to copy the subarrays of the old
      array, as the subarrays will be (re-)initialised immediately below }
    result:=fpc_setlength_dynarr_jobject(aorg,anew,deepcopy,false);
    { if aorg was empty, there's nothing else to do since result will now
      contain anew, of which all other dimensions are already initialised
      correctly since there are no aorg elements to copy }
    if not assigned(aorg) and
       not deepcopy then
      exit;
    partdone:=min(high(result),high(aorg));
    { ndim must be >=2 when this routine is called, since it has to return
      an array of java.lang.Object! (arrays are also objects, but primitive
      types are not) }
    if ndim=2 then
      begin
        { final dimension -> copy the primitive arrays }
        case eletype of
          FPCJDynArrTypeJByte:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jbyte(TJByteArray(aorg[i]),TJByteArray(anew[i]),deepcopy));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jbyte(nil,TJByteArray(anew[i]),deepcopy));
            end;
          FPCJDynArrTypeJShort:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jshort(TJShortArray(aorg[i]),TJShortArray(anew[i]),deepcopy));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jshort(nil,TJShortArray(anew[i]),deepcopy));
            end;
          FPCJDynArrTypeJInt:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jint(TJIntArray(aorg[i]),TJIntArray(anew[i]),deepcopy));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jint(nil,TJIntArray(anew[i]),deepcopy));
            end;
          FPCJDynArrTypeJLong:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jlong(TJLongArray(aorg[i]),TJLongArray(anew[i]),deepcopy));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jlong(nil,TJLongArray(anew[i]),deepcopy));
            end;
          FPCJDynArrTypeJChar:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jchar(TJCharArray(aorg[i]),TJCharArray(anew[i]),deepcopy));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jchar(nil,TJCharArray(anew[i]),deepcopy));
            end;
          FPCJDynArrTypeJFloat:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jfloat(TJFloatArray(aorg[i]),TJFloatArray(anew[i]),deepcopy));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jfloat(nil,TJFloatArray(anew[i]),deepcopy));
            end;
          FPCJDynArrTypeJDouble:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jdouble(TJDoubleArray(aorg[i]),TJDoubleArray(anew[i]),deepcopy));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jdouble(nil,TJDoubleArray(anew[i]),deepcopy));
            end;
          FPCJDynArrTypeJObject:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jobject(TJObjectArray(aorg[i]),TJObjectArray(anew[i]),deepcopy,true));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jobject(nil,TJObjectArray(anew[i]),deepcopy,true));
            end;
          FPCJDynArrTypeRecord:
            begin
              for i:=low(result) to partdone do
                result[i]:=JLObject(fpc_setlength_dynarr_jrecord(TJRecordArray(aorg[i]),TJRecordArray(anew[i]),deepcopy));
              for i:=succ(partdone) to high(result) do
                result[i]:=JLObject(fpc_setlength_dynarr_jrecord(nil,TJRecordArray(anew[i]),deepcopy));
          end;
        end;
      end
    else
      begin
        { recursively handle the next dimension }
        for i:=low(result) to partdone do
          result[i]:=JLObject(fpc_setlength_dynarr_multidim(TJObjectArray(aorg[i]),TJObjectArray(anew[i]),deepcopy,pred(ndim),eletype));
        for i:=succ(partdone) to high(result) do
          result[i]:=JLObject(fpc_setlength_dynarr_multidim(nil,TJObjectArray(anew[i]),deepcopy,pred(ndim),eletype));
      end;
  end;



{i jdynarr.inc end}



{*****************************************************************************
                       Misc. System Dependent Functions
*****************************************************************************}

  procedure TObject.Free;
    begin
      if not DestructorCalled then
        begin
          DestructorCalled:=true;
          Destroy;
        end;
    end;


  destructor TObject.Destroy;
    begin
    end;


  procedure TObject.Finalize;
    begin
      Free;
    end;

{*****************************************************************************
                         SystemUnit Initialization
*****************************************************************************}

end.

