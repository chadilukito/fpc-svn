{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2017 by Michael Van Canneyt

    Unit tests for Pascal-to-Javascript converter class.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************

 Examples:
   ./testpas2js --suite=TTestOptimizations
   ./testpas2js --suite=TTestOptimizations.TestOmitLocalVar
}
unit TCOptimizations;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, testregistry, fppas2js, pastree,
  PScanner, Pas2jsUseAnalyzer, PasResolver, PasResolveEval,
  TCModules;

type

  { TCustomTestOptimizations }

  TCustomTestOptimizations = class(TCustomTestModule)
  private
    FAnalyzerModule: TPas2JSAnalyzer;
    FAnalyzerProgram: TPas2JSAnalyzer;
    FWholeProgramOptimization: boolean;
    function OnConverterIsElementUsed(Sender: TObject; El: TPasElement): boolean;
    function OnConverterIsTypeInfoUsed(Sender: TObject; El: TPasElement): boolean;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure ParseModule; override;
    procedure ParseProgram; override;
    function CreateConverter: TPasToJSConverter; override;
  public
    property AnalyzerModule: TPas2JSAnalyzer read FAnalyzerModule;
    property AnalyzerProgram: TPas2JSAnalyzer read FAnalyzerProgram;
    property WholeProgramOptimization: boolean read FWholeProgramOptimization
        write FWholeProgramOptimization;
  end;

  { TTestOptimizations }

  TTestOptimizations = class(TCustomTestOptimizations)
  published
    // unit optimization: jsshortrefglobals
    procedure TestOptShortRefGlobals_Program;
    procedure TestOptShortRefGlobals_Unit_FromIntfImpl_ToIntfImpl;
    procedure TestOptShortRefGlobals_Property;
    procedure TestOptShortRefGlobals_GenericFunction;
    procedure TestOptShortRefGlobals_SameUnit_EnumType;
    procedure TestOptShortRefGlobals_SameUnit_ClassType;
    procedure TestOptShortRefGlobals_SameUnit_RecordType;

    // Whole Program Optimization
    procedure TestWPO_OmitLocalVar;
    procedure TestWPO_OmitLocalProc;
    procedure TestWPO_OmitLocalProcForward;
    procedure TestWPO_OmitProcLocalVar;
    procedure TestWPO_OmitProcLocalConst;
    procedure TestWPO_OmitProcLocalType;
    procedure TestWPO_OmitProcLocalProc;
    procedure TestWPO_OmitProcLocalForwardProc;
    procedure TestWPO_OmitRecordMember;
    procedure TestWPO_OmitNotUsedTObject;
    procedure TestWPO_TObject;
    procedure TestWPO_Class_Property;
    procedure TestWPO_Class_OmitField;
    procedure TestWPO_Class_OmitMethod;
    procedure TestWPO_Class_OmitClassMethod;
    procedure TestWPO_Class_OmitPropertyGetter1;
    procedure TestWPO_Class_OmitPropertyGetter2;
    procedure TestWPO_Class_OmitPropertySetter1;
    procedure TestWPO_Class_OmitPropertySetter2;
    procedure TestWPO_Class_KeepNewInstance;
    procedure TestWPO_CallInherited;
    procedure TestWPO_UseUnit;
    procedure TestWPO_ArrayOfConst_Use;
    procedure TestWPO_ArrayOfConst_NotUsed;
    procedure TestWPO_Class_PropertyInOtherUnit;
    procedure TestWPO_ProgramPublicDeclaration;
    procedure TestWPO_ConstructorDefaultValueConst;
    procedure TestWPO_RTTI_PublishedField;
    procedure TestWPO_RTTI_TypeInfo;
  end;

implementation

{ TCustomTestOptimizations }

function TCustomTestOptimizations.OnConverterIsElementUsed(Sender: TObject;
  El: TPasElement): boolean;
var
  A: TPas2JSAnalyzer;
begin
  if WholeProgramOptimization then
    A:=AnalyzerProgram
  else if Sender=Converter then
    A:=AnalyzerModule
  else
    begin
    {$IF defined(VerbosePas2JS) or defined(VerbosePasAnalyzer)}
    writeln('TCustomTestOptimizations.OnConverterIsElementUsed El=',GetObjName(El),' WPO=',WholeProgramOptimization,' Sender=',GetObjName(Sender));
    {$ENDIF}
    Fail('converting other unit without WPO');
    end;
  Result:=A.IsUsed(El);
  {$IF defined(VerbosePas2JS) or defined(VerbosePasAnalyzer)}
  writeln('TCustomTestOptimizations.OnConverterIsElementUsed El=',GetObjName(El),' WPO=',WholeProgramOptimization,' Result=',Result);
  {$ENDIF}
end;

function TCustomTestOptimizations.OnConverterIsTypeInfoUsed(Sender: TObject;
  El: TPasElement): boolean;
var
  A: TPas2JSAnalyzer;
begin
  if WholeProgramOptimization then
    A:=AnalyzerProgram
  else if Sender=Converter then
    A:=AnalyzerModule
  else
    begin
    {$IF defined(VerbosePas2JS) or defined(VerbosePasAnalyzer)}
    writeln('TCustomTestOptimizations.OnConverterIsTypeInfoUsed El=',GetObjName(El),' WPO=',WholeProgramOptimization,' Sender=',GetObjName(Sender));
    {$ENDIF}
    Fail('converting other unit without WPO');
    end;
  Result:=A.IsTypeInfoUsed(El);
  {$IF defined(VerbosePas2JS) or defined(VerbosePasAnalyzer)}
  writeln('TCustomTestOptimizations.OnConverterIsTypeInfoUsed El=',GetObjName(El),' WPO=',WholeProgramOptimization,' Result=',Result);
  {$ENDIF}
end;

procedure TCustomTestOptimizations.SetUp;
begin
  inherited SetUp;
  FWholeProgramOptimization:=false;
  FAnalyzerModule:=TPas2JSAnalyzer.Create;
  FAnalyzerModule.Resolver:=Engine;
  FAnalyzerProgram:=TPas2JSAnalyzer.Create;
  FAnalyzerProgram.Resolver:=Engine;
end;

procedure TCustomTestOptimizations.TearDown;
begin
  FreeAndNil(FAnalyzerProgram);
  FreeAndNil(FAnalyzerModule);
  inherited TearDown;
end;

procedure TCustomTestOptimizations.ParseModule;
begin
  inherited ParseModule;
  {$IF defined(VerbosePas2JS) or defined(VerbosePasAnalyzer)}
  writeln('TCustomTestOptimizations.ParseModule START');
  {$ENDIF}
  AnalyzerModule.AnalyzeModule(Module);
  {$IF defined(VerbosePas2JS) or defined(VerbosePasAnalyzer)}
  writeln('TCustomTestOptimizations.ParseModule END');
  {$ENDIF}
end;

procedure TCustomTestOptimizations.ParseProgram;
begin
  WholeProgramOptimization:=true;
  inherited ParseProgram;
  {$IF defined(VerbosePas2JS) or defined(VerbosePasAnalyzer)}
  writeln('TCustomTestOptimizations.ParseProgram START');
  {$ENDIF}
  AnalyzerProgram.AnalyzeWholeProgram(Module as TPasProgram);
  {$IF defined(VerbosePas2JS) or defined(VerbosePasAnalyzer)}
  writeln('TCustomTestOptimizations.ParseProgram START');
  {$ENDIF}
end;

function TCustomTestOptimizations.CreateConverter: TPasToJSConverter;
begin
  Result:=inherited CreateConverter;
  Result.OnIsElementUsed:=@OnConverterIsElementUsed;
  Result.OnIsTypeInfoUsed:=@OnConverterIsTypeInfoUsed;
end;

{ TTestOptimizations }

procedure TTestOptimizations.TestOptShortRefGlobals_Program;
begin
  AddModuleWithIntfImplSrc('UnitA.pas',
  LinesToStr([
    'type',
    '  TColor = (red,green,blue);',
    '  TColors = set of TColor;',
    'const',
    '  cRedBlue = [red,blue];',
    'type',
    '  TBird = class',
    '  public',
    '    class var c: word;',
    '    class function Run(w: word): word; virtual; abstract;',
    '  end;',
    '  TRec = record',
    '    x: word;',
    '  end;',
    'var b: TBird;',
    '']),
  LinesToStr([
    '']));

  StartProgram(true,[supTObject]);
  Add([
  '{$optimization JSShortRefGlobals}',
  'uses unita;',
  'type',
  '  TEagle = class(TBird)',
  '    class function Run(w: word = 5): word; override;',
  '  end;',
  'class function TEagle.Run(w: word): word;',
  'begin',
  'end;',
  'var',
  '  e: TEagle;',
  '  r: TRec;',
  '  c: TColors;',
  'begin',
  '  e:=TEagle.Create;',
  '  b:=TBird.Create;',
  '  e.c:=e.c+1;',
  '  r.x:=TBird.c;',
  '  r.x:=b.c;',
  '  r.x:=e.Run;',
  '  r.x:=e.Run();',
  '  r.x:=e.Run(4);',
  '  c:=cRedBlue;',
  '']);
  ConvertProgram;
  CheckSource('TestOptShortRefGlobals_Program',
    LinesToStr([
    'var $lt = null;',
    'var $lm = pas.UnitA;',
    'var $lt1 = $lm.TBird;',
    'var $lt2 = $lm.TRec;',
    'rtl.createClass(this, "TEagle", $lt1, function () {',
    '  $lt = this;',
    '  this.Run = function (w) {',
    '    var Result = 0;',
    '    return Result;',
    '  };',
    '});',
    'this.e = null;',
    'this.r = $lt2.$new();',
    'this.c = {};',
    '']),
    LinesToStr([
    '$mod.e = $lt.$create("Create");',
    '$lm.b = $lt1.$create("Create");',
    '$lt1.c = $mod.e.c + 1;',
    '$mod.r.x = $lt1.c;',
    '$mod.r.x = $lm.b.c;',
    '$mod.r.x = $mod.e.$class.Run(5);',
    '$mod.r.x = $mod.e.$class.Run(5);',
    '$mod.r.x = $mod.e.$class.Run(4);',
    '$mod.c = rtl.refSet($lm.cRedBlue);',
    '']));
end;

procedure TTestOptimizations.TestOptShortRefGlobals_Unit_FromIntfImpl_ToIntfImpl;
begin
  AddModuleWithIntfImplSrc('UnitA.pas',
  LinesToStr([
    'type',
    '  TBird = class',
    '  public Speed: word;',
    '  end;',
    '  TRecA = record',
    '    x: word;',
    '  end;',
    'var Bird: TBird;',
    '']),
  LinesToStr([
    '']));
  AddModuleWithIntfImplSrc('UnitB.pas',
  LinesToStr([
    'type',
    '  TAnt = class',
    '  public Size: word;',
    '  end;',
    '  TRecB = record',
    '    y: word;',
    '  end;',
    '  TBear = class',
    '  end;',
    '  TFrog = class',
    '  end;',
    'var Ant: TAnt;',
    '']),
  LinesToStr([
    '']));
  StartUnit(true,[supTObject]);
  Add([
  '{$optimization JSShortRefGlobals}',
  'interface',
  'uses unita;',
  'type',
  '  TEagle = class(TBird)', // intf-JS to intf-uses
  '    procedure Fly;',
  '  end;',
  'implementation',
  'uses unitb;',
  'type',
  '  TRedAnt = class(TAnt)', // impl-JS to impl-uses
  '    procedure Run;',
  '  end;',
  'procedure TEagle.Fly;',
  'begin',
  '  TRedAnt.Create;', // intf-JS to impl-JS
  '  TAnt.Create;', // intf-JS to impl-uses
  '  TBird.Create;', // intf-JS to intf-uses
  '  TEagle.Create;', // intf-JS to intf-JS
  'end;',
  'procedure TRedAnt.Run;',
  'begin',
  '  TRedAnt.Create;', // impl-JS to impl-JS
  '  TAnt.Create;', // impl-JS to impl-uses
  '  TBird.Create;', // impl-JS to intf-uses
  '  TEagle.Create;', // impl-JS to intf-JS
  '  TBear.Create', // only in impl-JS to impl-uses
  'end;',
  'var',
  '  RedAnt: TRedAnt;',
  '  Ant: TAnt;',
  '  Bird: TBird;',
  '  Eagle: TEagle;',
  'initialization',
  '  RedAnt:=TRedAnt.Create;', // init to impl-JS
  '  Ant:=TAnt.Create;', // init to impl-uses
  '  Bird:=TBird.Create;', // init to intf-uses
  '  Eagle:=TEagle.Create;', // init to intf-JS
  '  TFrog.Create;', // only in init to impl-uses
  '  Eagle.Fly;',
  '  RedAnt.Run;',
  '']);
  ConvertUnit;
  CheckSource('TestOptShortRefGlobals_Unit_FromIntfImpl_ToIntfImpl',
    LinesToStr([
    'var $impl = $mod.$impl;',
    'var $lt = null;',
    'var $lt1 = null;',
    'var $lm = pas.UnitA;',
    'var $lt2 = $lm.TBird;',
    'var $lm1 = null;',
    'var $lt3 = null;',
    'var $lt4 = null;',
    'var $lt5 = null;',
    'rtl.createClass(this, "TEagle", $lt2, function () {',
    '  $lt = this;',
    '  this.Fly = function () {',
    '    $lt1.$create("Create");',
    '    $lt3.$create("Create");',
    '    $lt2.$create("Create");',
    '    $lt.$create("Create");',
    '  };',
    '});',
    '']),
    LinesToStr([
    '$impl.RedAnt = $lt1.$create("Create");',
    '$impl.Ant = $lt3.$create("Create");',
    '$impl.Bird = $lt2.$create("Create");',
    '$impl.Eagle = $lt.$create("Create");',
    '$lt5.$create("Create");',
    '$impl.Eagle.Fly();',
    '$impl.RedAnt.Run();',
    '']),
    LinesToStr([
    '$lm1 = pas.UnitB;',
    '$lt3 = $lm1.TAnt;',
    '$lt4 = $lm1.TBear;',
    '$lt5 = $lm1.TFrog;',
    'rtl.createClass($impl, "TRedAnt", $lt3, function () {',
    '  $lt1 = this;',
    '  this.Run = function () {',
    '    $lt1.$create("Create");',
    '    $lt3.$create("Create");',
    '    $lt2.$create("Create");',
    '    $lt.$create("Create");',
    '    $lt4.$create("Create");',
    '  };',
    '});',
    '$impl.RedAnt = null;',
    '$impl.Ant = null;',
    '$impl.Bird = null;',
    '$impl.Eagle = null;',
    '']));
end;

procedure TTestOptimizations.TestOptShortRefGlobals_Property;
begin
  AddModuleWithIntfImplSrc('UnitA.pas',
  LinesToStr([
    'type',
    '  TBird = class',
    '    FWing: TObject;',
    '    class var FLeg: TObject;',
    '  public',
    '    property Wing: TObject read FWing write FWing;',
    '    class property Leg: TObject read FLeg write FLeg;',
    '  end;',
    '']),
  LinesToStr([
    '']));
  StartUnit(true,[supTObject]);
  Add([
  '{$optimization JSShortRefGlobals}',
  'interface',
  'uses unita;',
  'type',
  '  TEagle = class(TBird)', // intf-JS to intf-uses
  '    procedure Fly(o: TObject);',
  '  end;',
  'implementation',
  'procedure TEagle.Fly(o: TObject);',
  'begin',
  '  Fly(Wing);',
  '  Fly(Leg);',
  'end;',
  '']);
  ConvertUnit;
  CheckSource('TestOptShortRefGlobals_Property',
    LinesToStr([
    'var $lt = null;',
    'var $lm = pas.UnitA;',
    'var $lt1 = $lm.TBird;',
    'rtl.createClass(this, "TEagle", $lt1, function () {',
    '  $lt = this;',
    '  this.Fly = function (o) {',
    '    this.Fly(this.FWing);',
    '    this.Fly(this.FLeg);',
    '  };',
    '});',
    '']),
    LinesToStr([
    '']),
    LinesToStr([
    '']));
end;

procedure TTestOptimizations.TestOptShortRefGlobals_GenericFunction;
begin
  AddModuleWithIntfImplSrc('UnitA.pas',
  LinesToStr([
    'generic function Run<T>(a: T): T;',
    '']),
  LinesToStr([
    'generic function Run<T>(a: T): T;',
    'begin',
    'end;',
    '']));
  StartUnit(true,[supTObject]);
  Add([
  '{$optimization JSShortRefGlobals}',
  'interface',
  'uses unita;',
  'type',
  '  TEagle = class',
  '  end;',
  'procedure Fly;',
  'implementation',
  'procedure Fly;',
  'begin',
  '  specialize Run<TEagle>(nil);',
  'end;',
  '']);
  ConvertUnit;
  CheckSource('TestOptShortRefGlobals_GenericFunction',
    LinesToStr([
    'var $lt = null;',
    'var $lm = pas.system;',
    'var $lt1 = $lm.TObject;',
    'var $lm1 = pas.UnitA;',
    'var $lp = $lm1.Run$G1;',
    'rtl.createClass(this, "TEagle", $lt1, function () {',
    '  $lt = this;',
    '});',
    'this.Fly = function () {',
    '  $lp(null);',
    '};',
    '']),
    LinesToStr([
    '']),
    LinesToStr([
    '']));
end;

procedure TTestOptimizations.TestOptShortRefGlobals_SameUnit_EnumType;
begin
  StartUnit(true,[supTObject]);
  Add([
  '{$optimization JSShortRefGlobals}',
  'interface',
  'type',
  '  TBird = class',
  '  type',
  '    TFlag = (big,small);',
  '    procedure Fly;',
  '  end;',
  '  TEnum = (red,blue);',
  'var',
  '  e: TEnum;',
  '  f: TBird.TFlag;',
  'procedure Run;',
  'implementation',
  'procedure TBird.Fly;',
  'begin',
  '  e:=blue;',
  '  f:=small;',
  'end;',
  'procedure Run;',
  'type TSub = (left,right);',
  'var s: TSub;',
  'begin',
  '  e:=red;',
  '  s:=right;',
  '  f:=big;',
  'end;',
  '']);
  ConvertUnit;
  CheckSource('TestOptShortRefGlobals_SameUnit_EnumType',
    LinesToStr([
    'var $lt = null;',
    'var $lt1 = null;',
    'var $lt2 = null;',
    'var $lm = pas.system;',
    'var $lt3 = $lm.TObject;',
    'rtl.createClass(this, "TBird", $lt3, function () {',
    '  $lt = this;',
    '  $lt1 = this.TFlag = {',
    '    "0": "big",',
    '    big: 0,',
    '    "1": "small",',
    '    small: 1',
    '  };',
    '  this.Fly = function () {',
    '    $mod.e = $lt2.blue;',
    '    $mod.f = $lt1.small;',
    '  };',
    '});',
    '$lt2 = this.TEnum = {',
    '  "0": "red",',
    '  red: 0,',
    '  "1": "blue",',
    '  blue: 1',
    '};',
    'this.e = 0;',
    'this.f = 0;',
    'var TSub = {',
    '  "0": "left",',
    '  left: 0,',
    '  "1": "right",',
    '  right: 1',
    '};',
    'this.Run = function () {',
    '  var s = 0;',
    '  $mod.e = $lt2.red;',
    '  s = TSub.right;',
    '  $mod.f = $lt1.big;',
    '};',
    '']),
    LinesToStr([
    '']),
    LinesToStr([
    '']));
end;

procedure TTestOptimizations.TestOptShortRefGlobals_SameUnit_ClassType;
begin
  WithTypeInfo:=true;
  StartUnit(true,[supTObject]);
  Add([
  '{$optimization JSShortRefGlobals}',
  'interface',
  'type',
  '  TBird = class;',
  '  TAnt = class',
  '  type',
  '    TLeg = class',
  '    end;',
  '    procedure Run;',
  '  published',
  '    Bird: TBird;',
  '  end;',
  '  TBird = class',
  '    procedure Fly;',
  '  end;',
  'implementation',
  'type',
  '  TFrog = class',
  '  end;',
  'procedure TAnt.Run;',
  'begin',
  '  if typeinfo(TBird)=nil then;',
  '  Bird:=TBird.Create;',
  '  TLeg.Create;',
  '  TFrog.Create;',
  'end;',
  'procedure TBird.Fly;',
  'begin',
  '  if typeinfo(TAnt)=nil then;',
  'end;',
  '']);
  ConvertUnit;
  CheckSource('TestOptShortRefGlobals_SameUnit_ClassType',
    LinesToStr([
    'var $impl = $mod.$impl;',
    'var $lt = null;',
    'var $lt1 = null;',
    'var $lt2 = null;',
    'var $lt3 = null;',
    'var $lm = pas.system;',
    'var $lt4 = $lm.TObject;',
    'this.$rtti.$Class("TBird");',
    'rtl.createClass(this, "TAnt", $lt4, function () {',
    '  $lt = this;',
    '  rtl.createClass(this, "TLeg", $lt4, function () {',
    '    $lt1 = this;',
    '  }, "TAnt.TLeg");',
    '  this.$init = function () {',
    '    $lt4.$init.call(this);',
    '    this.Bird = null;',
    '  };',
    '  this.$final = function () {',
    '    this.Bird = undefined;',
    '    $lt4.$final.call(this);',
    '  };',
    '  this.Run = function () {',
    '    if ($mod.$rtti["TBird"] === null) ;',
    '    this.Bird = $lt2.$create("Create");',
    '    $lt1.$create("Create");',
    '    $lt3.$create("Create");',
    '  };',
    '  var $r = this.$rtti;',
    '  $r.addField("Bird", $mod.$rtti["TBird"]);',
    '});',
    'rtl.createClass(this, "TBird", $lt4, function () {',
    '  $lt2 = this;',
    '  this.Fly = function () {',
    '    if ($mod.$rtti["TAnt"] === null) ;',
    '  };',
    '});',
    '']),
    LinesToStr([
    '']),
    LinesToStr([
    'rtl.createClass($impl, "TFrog", $lt4, function () {',
    '  $lt3 = this;',
    '});',
    '']));
end;

procedure TTestOptimizations.TestOptShortRefGlobals_SameUnit_RecordType;
begin
  StartUnit(true,[supTObject]);
  Add([
  '{$optimization JSShortRefGlobals}',
  '{$modeswitch advancedrecords}',
  'interface',
  'type',
  '  TAnt = record',
  '  type',
  '    TLeg = record',
  '      l: word;',
  '    end;',
  '    procedure Run;',
  '    Leg: TLeg;',
  '  end;',
  'implementation',
  'type',
  '  TBird = record',
  '    b: word;',
  '  end;',
  'procedure TAnt.Run;',
  'type',
  '  TFoot = record',
  '    f: word;',
  '  end;',
  'var',
  '  b: TBird;',
  '  l: TLeg;',
  '  a: TAnt;',
  '  f: TFoot;',
  'begin',
  '  b.b:=1;',
  '  l.l:=2;',
  '  a.Leg.l:=3;',
  '  f.f:=4;',
  'end;',
  '']);
  ConvertUnit;
  CheckSource('TestOptShortRefGlobals_SameUnit_RecordType',
    LinesToStr([
    'var $impl = $mod.$impl;',
    'var $lt = null;',
    'var $lt1 = null;',
    'var $lt2 = null;',
    'rtl.recNewT(this, "TAnt", function () {',
    '  $lt = this;',
    '  rtl.recNewT($lt, "TLeg", function () {',
    '    $lt1 = this;',
    '    this.l = 0;',
    '    this.$eq = function (b) {',
    '      return this.l === b.l;',
    '    };',
    '    this.$assign = function (s) {',
    '      this.l = s.l;',
    '      return this;',
    '    };',
    '  });',
    '  this.$new = function () {',
    '    var r = Object.create(this);',
    '    r.Leg = $lt1.$new();',
    '    return r;',
    '  };',
    '  this.$eq = function (b) {',
    '    return this.Leg.$eq(b.Leg);',
    '  };',
    '  this.$assign = function (s) {',
    '    this.Leg.$assign(s.Leg);',
    '    return this;',
    '  };',
    '  var TFoot = rtl.recNewT(null, "", function () {',
    '    this.f = 0;',
    '    this.$eq = function (b) {',
    '      return this.f === b.f;',
    '    };',
    '    this.$assign = function (s) {',
    '      this.f = s.f;',
    '      return this;',
    '    };',
    '  });',
    '  this.Run = function () {',
    '    var b = $lt2.$new();',
    '    var l = $lt1.$new();',
    '    var a = $lt.$new();',
    '    var f = TFoot.$new();',
    '    b.b = 1;',
    '    l.l = 2;',
    '    a.Leg.l = 3;',
    '    f.f = 4;',
    '  };',
    '}, true);',
    '']),
    LinesToStr([
    '']),
    LinesToStr([
    'rtl.recNewT($impl, "TBird", function () {',
    '  $lt2 = this;',
    '  this.b = 0;',
    '  this.$eq = function (b) {',
    '    return this.b === b.b;',
    '  };',
    '  this.$assign = function (s) {',
    '    this.b = s.b;',
    '    return this;',
    '  };',
    '});',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitLocalVar;
begin
  StartProgram(false);
  Add('var');
  Add('  a: longint;');
  Add('  b: longint;');
  Add('begin');
  Add('  b:=3;');
  ConvertProgram;
  CheckSource('TestWPO_OmitLocalVar',
    'this.b = 0;',
    '$mod.b = 3;');
end;

procedure TTestOptimizations.TestWPO_OmitLocalProc;
begin
  StartProgram(false);
  Add('procedure DoIt; begin end;');
  Add('procedure NoIt; begin end;');
  Add('begin');
  Add('  DoIt;');
  ConvertProgram;
  CheckSource('TestWPO_OmitLocalProc',
    LinesToStr([
    'this.DoIt = function () {',
    '};',
    '']),
    LinesToStr([
    '$mod.DoIt();',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitLocalProcForward;
begin
  StartProgram(false);
  Add('procedure DoIt; forward;');
  Add('procedure NoIt; forward;');
  Add('procedure DoIt; begin end;');
  Add('procedure NoIt; begin end;');
  Add('begin');
  Add('  DoIt;');
  ConvertProgram;
  CheckSource('TestWPO_OmitLocalProcForward',
    LinesToStr([
    'this.DoIt = function () {',
    '};',
    '']),
    LinesToStr([
    '$mod.DoIt();',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitProcLocalVar;
begin
  StartProgram(false);
  Add('function DoIt: longint;');
  Add('var');
  Add('  a: longint;');
  Add('  b: longint;');
  Add('begin');
  Add('  b:=3;');
  Add('  Result:=b;');
  Add('end;');
  Add('begin');
  Add('  DoIt;');
  ConvertProgram;
  CheckSource('TestWPO_OmitProcLocalVar',
    LinesToStr([
    'this.DoIt = function () {',
    '  var Result = 0;',
    '  var b = 0;',
    '  b = 3;',
    '  Result = b;',
    '  return Result;',
    '};',
    '']),
    LinesToStr([
    '$mod.DoIt();',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitProcLocalConst;
begin
  StartProgram(false);
  Add('function DoIt: longint;');
  Add('const');
  Add('  a = 3;');
  Add('  b = 4;');
  Add('  c: longint = 5;');
  Add('  d: longint = 6;');
  Add('begin');
  Add('  Result:=b+d;');
  Add('end;');
  Add('begin');
  Add('  DoIt;');
  ConvertProgram;
  CheckSource('TestWPO_OmitProcLocalConst',
    LinesToStr([
    'var b = 4;',
    'var d = 6;',
    'this.DoIt = function () {',
    '  var Result = 0;',
    '  Result = 4 + d;',
    '  return Result;',
    '};',
    '']),
    LinesToStr([
    '$mod.DoIt();',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitProcLocalType;
begin
  StartProgram(false);
  Add('function DoIt: longint;');
  Add('type');
  Add('  TEnum = (red, green);');
  Add('  TEnums = set of TEnum;');
  Add('begin');
  Add('  Result:=3;');
  Add('end;');
  Add('begin');
  Add('  DoIt;');
  ConvertProgram;
  CheckSource('TestWPO_OmitProcLocalType',
    LinesToStr([
    'this.DoIt = function () {',
    '  var Result = 0;',
    '  Result = 3;',
    '  return Result;',
    '};',
    '']),
    LinesToStr([
    '$mod.DoIt();',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitProcLocalProc;
begin
  StartProgram(false);
  Add('procedure DoIt;');
  Add('  procedure SubProcA; begin end;');
  Add('  procedure SubProcB; begin end;');
  Add('begin');
  Add('  SubProcB;');
  Add('end;');
  Add('begin');
  Add('  DoIt;');
  ConvertProgram;
  CheckSource('TestWPO_OmitProcLocalProc',
    LinesToStr([
    'this.DoIt = function () {',
    '  function SubProcB() {',
    '  };',
    '  SubProcB();',
    '};',
    '']),
    LinesToStr([
    '$mod.DoIt();',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitProcLocalForwardProc;
begin
  StartProgram(false);
  Add('procedure DoIt;');
  Add('  procedure SubProcA; forward;');
  Add('  procedure SubProcB; forward;');
  Add('  procedure SubProcA; begin end;');
  Add('  procedure SubProcB; begin end;');
  Add('begin');
  Add('  SubProcB;');
  Add('end;');
  Add('begin');
  Add('  DoIt;');
  ConvertProgram;
  CheckSource('TestWPO_OmitProcLocalForwardProc',
    LinesToStr([
    'this.DoIt = function () {',
    '  function SubProcB() {',
    '  };',
    '  SubProcB();',
    '};',
    '']),
    LinesToStr([
    '$mod.DoIt();',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitRecordMember;
begin
  StartProgram(false);
  Add('type');
  Add('  TRec = record');
  Add('    a: longint;');
  Add('    b: longint;');
  Add('  end;');
  Add('var r: TRec;');
  Add('begin');
  Add('  r.a:=3;');
  ConvertProgram;
  CheckSource('TestWPO_OmitRecordMember',
    LinesToStr([
    'rtl.recNewT(this, "TRec", function () {',
    '  this.a = 0;',
    '  this.$eq = function (b) {',
    '    return this.a === b.a;',
    '  };',
    '  this.$assign = function (s) {',
    '    this.a = s.a;',
    '    return this;',
    '  };',
    '});',
    'this.r = this.TRec.$new();',
    '']),
    LinesToStr([
    '$mod.r.a = 3;',
    '']));
end;

procedure TTestOptimizations.TestWPO_OmitNotUsedTObject;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class end;');
  Add('var o: TObject;');
  Add('begin');
  ConvertProgram;
  CheckSource('TestWPO_OmitNotUsedTObject',
    LinesToStr([
    '']),
    LinesToStr([
    '']));
end;

procedure TTestOptimizations.TestWPO_TObject;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    procedure AfterConstruction; virtual;');
  Add('    procedure BeforeDestruction; virtual;');
  Add('  end;');
  Add('procedure TObject.AfterConstruction; begin end;');
  Add('procedure TObject.BeforeDestruction; begin end;');
  Add('var o: TObject;');
  Add('begin');
  Add('  o:=nil;');
  ConvertProgram;
  CheckSource('TestWPO_TObject',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '  };',
    '  this.$final = function () {',
    '  };',
    '  this.AfterConstruction = function () {',
    '  };',
    '  this.BeforeDestruction = function () {',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    '$mod.o = null;']));
end;

procedure TTestOptimizations.TestWPO_Class_Property;
begin
  StartProgram(false);
  Add([
  'type',
  '  TObject = class',
  '  private',
  '    const CA = 3;',
  '  private',
  '    FA: longint;',
  '    function GetA: longint;',
  '    procedure SetA(Value: longint);',
  '    function IsStoredA: boolean;',
  '    property A: longint read GetA write SetA stored IsStoredA default CA;',
  '  end;',
  'function tobject.geta: longint; begin end;',
  'procedure tobject.seta(value: longint); begin end;',
  'function tobject.isstoreda: boolean; begin end;',
  'var o: TObject;',
  'begin',
  '  o.A:=o.A;']);
  ConvertProgram;
  CheckSource('TestWPO_Class_TObject',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '  };',
    '  this.$final = function () {',
    '  };',
    '  this.GetA = function () {',
    '    var Result = 0;',
    '    return Result;',
    '  };',
    '  this.SetA = function (Value) {',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    '$mod.o.SetA($mod.o.GetA());']));
end;

procedure TTestOptimizations.TestWPO_Class_OmitField;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    a: longint;');
  Add('    b: longint;');
  Add('  end;');
  Add('var o: TObject;');
  Add('begin');
  Add('  o.a:=3;');
  ConvertProgram;
  CheckSource('TestWPO_OmitClassField',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '    this.a = 0;',
    '  };',
    '  this.$final = function () {',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    '$mod.o.a = 3;']));
end;

procedure TTestOptimizations.TestWPO_Class_OmitMethod;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    procedure ProcA;');
  Add('    procedure ProcB;');
  Add('  end;');
  Add('procedure TObject.ProcA; begin end;');
  Add('procedure TObject.ProcB; begin end;');
  Add('var o: TObject;');
  Add('begin');
  Add('  o.ProcB;');
  ConvertProgram;
  CheckSource('TestWPO_OmitClassMethod',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '  };',
    '  this.$final = function () {',
    '  };',
    '  this.ProcB = function () {',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    '$mod.o.ProcB();']));
end;

procedure TTestOptimizations.TestWPO_Class_OmitClassMethod;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    class procedure ProcA;');
  Add('    class procedure ProcB;');
  Add('  end;');
  Add('class procedure TObject.ProcA; begin end;');
  Add('class procedure TObject.ProcB; begin end;');
  Add('var o: TObject;');
  Add('begin');
  Add('  o.ProcB;');
  ConvertProgram;
  CheckSource('TestWPO_OmitClassMethod',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '  };',
    '  this.$final = function () {',
    '  };',
    '  this.ProcB = function () {',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    '$mod.o.$class.ProcB();']));
end;

procedure TTestOptimizations.TestWPO_Class_OmitPropertyGetter1;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    FFoo: boolean;');
  Add('    function GetFoo: boolean;');
  Add('    property Foo: boolean read FFoo;');
  Add('    property Foo2: boolean read GetFoo;');
  Add('    FBar: boolean;');
  Add('    function GetBar: boolean;');
  Add('    property Bar: boolean read FBar;');
  Add('    property Bar2: boolean read GetBar;');
  Add('  end;');
  Add('function TObject.GetFoo: boolean; begin Result:=FFoo; end;');
  Add('function TObject.GetBar: boolean; begin Result:=FBar; end;');
  Add('var o: TObject;');
  Add('begin');
  Add('  if o.Foo then;');
  ConvertProgram;
  CheckSource('TestWPO_OmitClassPropertyGetter1',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '    this.FFoo = false;',
    '  };',
    '  this.$final = function () {',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    'if ($mod.o.FFoo);',
    '']));
end;

procedure TTestOptimizations.TestWPO_Class_OmitPropertyGetter2;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    FFoo: boolean;');
  Add('    function GetFoo: boolean;');
  Add('    property Foo: boolean read FFoo;');
  Add('    property Foo2: boolean read GetFoo;');
  Add('  end;');
  Add('function TObject.GetFoo: boolean; begin Result:=FFoo; end;');
  Add('var o: TObject;');
  Add('begin');
  Add('  if o.Foo2 then;');
  ConvertProgram;
  CheckSource('TestWPO_OmitClassPropertyGetter2',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '    this.FFoo = false;',
    '  };',
    '  this.$final = function () {',
    '  };',
    '  this.GetFoo = function () {',
    '    var Result = false;',
    '    Result = this.FFoo;',
    '    return Result;',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    'if ($mod.o.GetFoo()) ;',
    '']));
end;

procedure TTestOptimizations.TestWPO_Class_OmitPropertySetter1;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    FFoo: boolean;');
  Add('    procedure SetFoo(Value: boolean);');
  Add('    property Foo: boolean write FFoo;');
  Add('    property Foo2: boolean write SetFoo;');
  Add('    FBar: boolean;');
  Add('    procedure SetBar(Value: boolean);');
  Add('    property Bar: boolean write FBar;');
  Add('    property Bar2: boolean write SetBar;');
  Add('  end;');
  Add('procedure TObject.SetFoo(Value: boolean); begin FFoo:=Value; end;');
  Add('procedure TObject.SetBar(Value: boolean); begin FBar:=Value; end;');
  Add('var o: TObject;');
  Add('begin');
  Add('  o.Foo:=true;');
  ConvertProgram;
  CheckSource('TestWPO_OmitClassPropertySetter1',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '    this.FFoo = false;',
    '  };',
    '  this.$final = function () {',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    '$mod.o.FFoo = true;',
    '']));
end;

procedure TTestOptimizations.TestWPO_Class_OmitPropertySetter2;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    FFoo: boolean;');
  Add('    procedure SetFoo(Value: boolean);');
  Add('    property Foo: boolean write FFoo;');
  Add('    property Foo2: boolean write SetFoo;');
  Add('  end;');
  Add('procedure TObject.SetFoo(Value: boolean); begin FFoo:=Value; end;');
  Add('var o: TObject;');
  Add('begin');
  Add('  o.Foo2:=true;');
  ConvertProgram;
  CheckSource('TestWPO_OmitClassPropertySetter2',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '    this.FFoo = false;',
    '  };',
    '  this.$final = function () {',
    '  };',
    '  this.SetFoo = function (Value) {',
    '    this.FFoo = Value;',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    '$mod.o.SetFoo(true);',
    '']));
end;

procedure TTestOptimizations.TestWPO_Class_KeepNewInstance;
begin
  StartProgram(false);
  Add([
  '{$modeswitch externalclass}',
  'type',
  '  TExt = class external name ''Object''',
  '  end;',
  '  TBird = class(TExt)',
  '  protected',
  '    class function NewInstance(fnname: string; const paramarray): TBird; virtual;',
  '  public',
  '    constructor Create;',
  '  end;',
  'class function TBird.NewInstance(fnname: string; const paramarray): TBird;',
  'begin',
  '  asm',
  '  Result = Object.create();',
  '  end;',
  'end;',
  'constructor TBird.Create;',
  'begin',
  '  inherited;',
  'end;',
  'begin',
  '  TBird.Create;',
  '']);
  ConvertProgram;
  CheckSource('TestWPO_Class_KeepNewInstance',
    LinesToStr([
    'rtl.createClassExt(this, "TBird", Object, "NewInstance", function () {',
    '  this.$init = function () {',
    '  };',
    '  this.$final = function () {',
    '  };',
    '  this.NewInstance = function (fnname, paramarray) {',
    '    var Result = null;',
    '    Result = Object.create();',
    '    return Result;',
    '  };',
    '  this.Create = function () {',
    '    return this;',
    '  };',
    '});',
    '']),
    LinesToStr([
    '$mod.TBird.$create("Create");',
    '']));
end;

procedure TTestOptimizations.TestWPO_CallInherited;
begin
  StartProgram(false);
  Add('type');
  Add('  TObject = class');
  Add('    procedure DoA;');
  Add('    procedure DoB;');
  Add('  end;');
  Add('  TMobile = class');
  Add('    procedure DoA;');
  Add('    procedure DoC;');
  Add('  end;');
  Add('procedure TObject.DoA; begin end;');
  Add('procedure TObject.DoB; begin end;');
  Add('procedure TMobile.DoA;');
  Add('begin');
  Add('  inherited;');
  Add('end;');
  Add('procedure TMobile.DoC;');
  Add('begin');
  Add('  inherited DoB;');
  Add('end;');
  Add('var o: TMobile;');
  Add('begin');
  Add('  o.DoA;');
  Add('  o.DoC;');
  ConvertProgram;
  CheckSource('TestWPO_CallInherited',
    LinesToStr([
    'rtl.createClass(this, "TObject", null, function () {',
    '  this.$init = function () {',
    '  };',
    '  this.$final = function () {',
    '  };',
    '  this.DoA = function () {',
    '  };',
    '  this.DoB = function () {',
    '  };',
    '});',
    ' rtl.createClass(this, "TMobile", this.TObject, function () {',
    '  this.DoA$1 = function () {',
    '    $mod.TObject.DoA.call(this);',
    '  };',
    '  this.DoC = function () {',
    '    $mod.TObject.DoB.call(this);',
    '  };',
    '});',
    'this.o = null;',
    '']),
    LinesToStr([
    '$mod.o.DoA$1();',
    '$mod.o.DoC();',
    '']));
end;

procedure TTestOptimizations.TestWPO_UseUnit;
var
  ActualSrc, ExpectedSrc: String;
begin
  AddModuleWithIntfImplSrc('unit1.pp',
    LinesToStr([
    'var i: longint;',
    'procedure DoIt;',
    '']),
    LinesToStr([
    'procedure DoIt; begin end;']));

  AddModuleWithIntfImplSrc('unit2.pp',
    LinesToStr([
    'var j: longint;',
    'procedure DoMore;',
    '']),
    LinesToStr([
    'procedure DoMore; begin end;']));

  StartProgram(true);
  Add('uses unit2;');
  Add('begin');
  Add('  j:=3;');
  ConvertProgram;
  ActualSrc:=ConvertJSModuleToString(JSModule);
  ExpectedSrc:=LinesToStr([
    'rtl.module("program", ["system", "unit2"], function () {',
    '  var $mod = this;',
    '  $mod.$main = function () {',
    '    pas.unit2.j = 3;',
    '  };',
    '});',
    '']);
  CheckDiff('TestWPO_UseUnit',ExpectedSrc,ActualSrc);
end;

procedure TTestOptimizations.TestWPO_ArrayOfConst_Use;
begin
  StartProgram(true,[supTVarRec]);
  Add([
  'procedure Say(arr: array of const);',
  'begin',
  'end;',
  'begin',
  '  Say([true]);']);
  ConvertProgram;
  CheckUnit('system.pp',
  LinesToStr([
  'rtl.module("system", [], function () {',
  '  var $mod = this;',
  '  rtl.recNewT(this, "TVarRec", function () {',
  '    this.VType = 0;',
  '    this.VJSValue = undefined;',
  '    this.$eq = function (b) {',
  '      return (this.VType === b.VType) && (this.VJSValue === b.VJSValue);',
  '    };',
  '    this.$assign = function (s) {',
  '      this.VType = s.VType;',
  '      this.VJSValue = s.VJSValue;',
  '      return this;',
  '    };',
  '  });',
  '  this.VarRecs = function () {',
  '    var Result = [];',
  '    var v = null;',
  '    v.VType = 1;',
  '    v.VJSValue = 2;',
  '    return Result;',
  '  };',
  '});',
  '']));
end;

procedure TTestOptimizations.TestWPO_ArrayOfConst_NotUsed;
begin
  StartProgram(true,[supTVarRec]);
  Add([
  'procedure Say(arr: array of const);',
  'begin',
  'end;',
  'begin']);
  ConvertProgram;
  CheckUnit('system.pp',
  LinesToStr([
  'rtl.module("system", [], function () {',
  '  var $mod = this;',
  '});',
  '']));
end;

procedure TTestOptimizations.TestWPO_Class_PropertyInOtherUnit;
begin
  AddModuleWithIntfImplSrc('unit1.pp',
    LinesToStr([
    'type',
    '  TObject = class',
    '  private',
    '    const CA = 3;',
    '  private',
    '    FOther: string;',
    '    FA: longint;',
    '    function GetA: longint;',
    '    procedure SetA(Value: longint);',
    '    function IsStoredA: boolean;',
    '  public',
    '    property A: longint read GetA write SetA stored IsStoredA default CA;',
    '  end;',
    '']),
    LinesToStr([
    'function TObject.geta: longint;',
    'begin',
    'end;',
    'procedure TObject.seta(value: longint);',
    'begin',
    '  FA:=Value;',
    'end;',
    'function TObject.isstoreda: boolean; begin end;',
    '']));
  StartProgram(true);
  Add([
  'uses unit1;',
  'var o: TObject;',
  'begin',
  '  o.A:=o.A;']);
  ConvertProgram;
  CheckUnit('unit1.pp',
  LinesToStr([
  'rtl.module("unit1", ["system"], function () {',
  '  var $mod = this;',
  '  rtl.createClass(this, "TObject", null, function () {',
  '    this.$init = function () {',
  '      this.FA = 0;',
  '    };',
  '    this.$final = function () {',
  '    };',
  '    this.GetA = function () {',
  '      var Result = 0;',
  '      return Result;',
  '    };',
  '    this.SetA = function (Value) {',
  '      this.FA = Value;',
  '    };',
  '  });',
  '});',
  '']));
end;

procedure TTestOptimizations.TestWPO_ProgramPublicDeclaration;
var
  ActualSrc, ExpectedSrc: String;
begin
  StartProgram(true);
  Add('var');
  Add('  vPublic: longint; public;');
  Add('  vPrivate: longint;');
  Add('procedure DoPublic; public; begin end;');
  Add('procedure DoPrivate; begin end;');
  Add('begin');
  ConvertProgram;
  ActualSrc:=ConvertJSModuleToString(JSModule);
  ExpectedSrc:=LinesToStr([
    'rtl.module("program", ["system"], function () {',
    '  var $mod = this;',
    '  this.vPublic = 0;',
    '  this.DoPublic =function(){',
    '  };',
    '  $mod.$main = function () {',
    '  };',
    '});',
    '']);
  CheckDiff('TestWPO_ProgramPublicDeclaration',ExpectedSrc,ActualSrc);
end;

procedure TTestOptimizations.TestWPO_ConstructorDefaultValueConst;
var
  ActualSrc, ExpectedSrc: String;
begin
  WithTypeInfo:=true;
  StartProgram(true);
  Add([
  'const gcBlack = 0;',
  'type',
  '  TColor = longint;',
  '  TObject = class',
  '  private',
  '    FColor: TColor;',
  '  public',
  '    property Color: TColor read FColor write FColor;',
  '    constructor Create(const AColor: TColor = gcBlack);',
  '  end;',
  'constructor TObject.Create(const AColor: TColor = gcBlack);',
  'begin',
  '  FColor := AColor;',
  'end;',
  'var T: TObject;',
  'begin',
  '  T := TObject.Create;',
  '']);
  ConvertProgram;
  ActualSrc:=ConvertJSModuleToString(JSModule);
  ExpectedSrc:=LinesToStr([
  'rtl.module("program",["system"],function () {',
  '  var $mod = this;',
  '  this.gcBlack = 0;',
  '  rtl.createClass(this,"TObject",null,function () {',
  '    this.$init = function () {',
  '      this.FColor = 0;',
  '    };',
  '    this.$final = function () {',
  '    };',
  '    this.Create = function (AColor) {',
  '      this.FColor = AColor;',
  '      return this;',
  '    };',
  '  });',
  '  this.T = null;',
  '  $mod.$main = function () {',
  '    $mod.T = $mod.TObject.$create("Create",[0]);',
  '  };',
  '});',
  '']);
  CheckDiff('TestWPO_ConstructorDefaultValueConst',ExpectedSrc,ActualSrc);
end;

procedure TTestOptimizations.TestWPO_RTTI_PublishedField;
var
  ActualSrc, ExpectedSrc: String;
begin
  WithTypeInfo:=true;
  StartProgram(true);
  Add('type');
  Add('  TArrA = array of char;');
  Add('  TArrB = array of string;');
  Add('  TObject = class');
  Add('  public');
  Add('    PublicA: TArrA;');
  Add('  published');
  Add('    PublishedB: TArrB;');
  Add('  end;');
  Add('var');
  Add('  C: TObject;');
  Add('begin');
  Add('  C.PublicA:=nil;');
  ConvertProgram;
  ActualSrc:=ConvertJSModuleToString(JSModule);
  ExpectedSrc:=LinesToStr([
    'rtl.module("program", ["system"], function () {',
    '  var $mod = this;',
    '  this.$rtti.$DynArray("TArrB", {',
    '    eltype: rtl.string',
    '  });',
    '  rtl.createClass(this, "TObject", null, function () {',
    '    this.$init = function () {',
    '      this.PublicA = [];',
    '      this.PublishedB = [];',
    '    };',
    '    this.$final = function () {',
    '      this.PublicA = undefined;',
    '      this.PublishedB = undefined;',
    '    };',
    '    var $r = this.$rtti;',
    '    $r.addField("PublishedB", $mod.$rtti["TArrB"]);',
    '  });',
    '  this.C = null;',
    '  $mod.$main = function () {',
    '    $mod.C.PublicA = [];',
    '  };',
    '});',
    '']);
  CheckDiff('TestWPO_RTTI_PublishedField',ExpectedSrc,ActualSrc);
end;

procedure TTestOptimizations.TestWPO_RTTI_TypeInfo;
var
  ActualSrc, ExpectedSrc: String;
begin
  WithTypeInfo:=true;
  StartProgram(true);
  Add('type');
  Add('  TArrA = array of char;');
  Add('  TArrB = array of string;');
  Add('var');
  Add('  A: TArrA;');
  Add('  B: TArrB;');
  Add('  p: pointer;');
  Add('begin');
  Add('  A:=nil;');
  Add('  p:=typeinfo(B);');
  ConvertProgram;
  ActualSrc:=ConvertJSModuleToString(JSModule);
  ExpectedSrc:=LinesToStr([
    'rtl.module("program", ["system"], function () {',
    '  var $mod = this;',
    '  this.$rtti.$DynArray("TArrB", {',
    '    eltype: rtl.string',
    '  });',
    '  this.A = [];',
    '  this.B = [];',
    '  this.p = null;',
    '  $mod.$main = function () {',
    '    $mod.A = [];',
    '    $mod.p = $mod.$rtti["TArrB"];',
    '  };',
    '});',
    '']);
  CheckDiff('TestWPO_RTTI_TypeInfo',ExpectedSrc,ActualSrc);
end;

Initialization
  RegisterTests([TTestOptimizations]);
end.

