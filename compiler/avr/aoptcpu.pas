{
    Copyright (c) 1998-2002 by Jonas Maebe, member of the Free Pascal
    Development Team

    This unit implements the ARM optimizer object

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

 ****************************************************************************
}


Unit aoptcpu;

{$i fpcdefs.inc}

{$define DEBUG_AOPTCPU}

Interface

uses cpubase, cgbase, aasmtai, aopt,AoptObj, aoptcpub;

Type
  TCpuAsmOptimizer = class(TAsmOptimizer)
    { outputs a debug message into the assembler file }
    procedure DebugMsg(const s: string; p: tai);

    Function GetNextInstructionUsingReg(Current: tai; Var Next: tai;reg : TRegister): Boolean;
    function RegInInstruction(Reg: TRegister; p1: tai): Boolean; override;
    function RegLoadedWithNewValue(reg : tregister; hp : tai) : boolean; override;
    function InstructionLoadsFromReg(const reg : TRegister; const hp : tai) : boolean; override;

    { uses the same constructor as TAopObj }
    function PeepHoleOptPass1Cpu(var p: tai): boolean; override;
    procedure PeepHoleOptPass2;override;
  End;

Implementation

  uses
    cutils,
    verbose,
    cpuinfo,
    aasmbase,aasmcpu,aasmdata,
    globals,globtype,
    cgutils;

  type
    TAsmOpSet = set of TAsmOp;

  function CanBeCond(p : tai) : boolean;
    begin
      result:=(p.typ=ait_instruction) and (taicpu(p).condition=C_None);
    end;


  function RefsEqual(const r1, r2: treference): boolean;
    begin
      refsequal :=
        (r1.offset = r2.offset) and
        (r1.base = r2.base) and
        (r1.index = r2.index) and (r1.scalefactor = r2.scalefactor) and
        (r1.symbol=r2.symbol) and (r1.refaddr = r2.refaddr) and
        (r1.relsymbol = r2.relsymbol) and
        (r1.addressmode = r2.addressmode);
    end;


  function MatchOperand(const oper1: TOper; const oper2: TOper): boolean; inline;
    begin
      result:=oper1.typ=oper2.typ;

      if result then
        case oper1.typ of
          top_const:
            Result:=oper1.val = oper2.val;
          top_reg:
            Result:=oper1.reg = oper2.reg;
          top_ref:
            Result:=RefsEqual(oper1.ref^, oper2.ref^);
          else Result:=false;
        end
    end;


  function MatchOperand(const oper: TOper; const reg: TRegister): boolean; inline;
    begin
      result := (oper.typ = top_reg) and (oper.reg = reg);
    end;


  function MatchInstruction(const instr: tai; const op: TAsmOp): boolean;
    begin
      result :=
        (instr.typ = ait_instruction) and
        (taicpu(instr).opcode = op);
    end;


  function MatchInstruction(const instr: tai; const ops: TAsmOpSet): boolean;
    begin
      result :=
        (instr.typ = ait_instruction) and
        (taicpu(instr).opcode in ops);
    end;


  function MatchInstruction(const instr: tai; const ops: TAsmOpSet;opcount : byte): boolean;
    begin
      result :=
        (instr.typ = ait_instruction) and
        (taicpu(instr).opcode in ops) and
        (taicpu(instr).ops=opcount);
    end;


  function MatchOpType(const instr : tai;ot0,ot1 : toptype) : Boolean;
    begin
      Result:=(taicpu(instr).ops=2) and
        (taicpu(instr).oper[0]^.typ=ot0) and
        (taicpu(instr).oper[1]^.typ=ot1);
    end;

{$ifdef DEBUG_AOPTCPU}
  procedure TCpuAsmOptimizer.DebugMsg(const s: string;p : tai);
    begin
      asml.insertbefore(tai_comment.Create(strpnew(s)), p);
    end;
{$else DEBUG_AOPTCPU}
  procedure TCpuAsmOptimizer.DebugMsg(const s: string;p : tai);inline;
    begin
    end;
{$endif DEBUG_AOPTCPU}


  function TCpuAsmOptimizer.RegInInstruction(Reg: TRegister; p1: tai): Boolean;
    begin
      If (p1.typ = ait_instruction) and (taicpu(p1).opcode in [A_MUL,A_MULS,A_FMUL,A_FMULS,A_FMULSU]) and
              ((getsupreg(reg)=RS_R0) or (getsupreg(reg)=RS_R1)) then
        Result:=true
      else
        Result:=inherited RegInInstruction(Reg, p1);
    end;


  function TCpuAsmOptimizer.GetNextInstructionUsingReg(Current: tai;
    var Next: tai; reg: TRegister): Boolean;
    begin
      Next:=Current;
      repeat
        Result:=GetNextInstruction(Next,Next);
      until not(cs_opt_level3 in current_settings.optimizerswitches) or not(Result) or (Next.typ<>ait_instruction) or (RegInInstruction(reg,Next)) or
        (is_calljmp(taicpu(Next).opcode));
    end;


  function TCpuAsmOptimizer.RegLoadedWithNewValue(reg: tregister; hp: tai): boolean;
    var
      p: taicpu;
    begin
      if not assigned(hp) or
         (hp.typ <> ait_instruction) then
       begin
         Result := false;
         exit;
       end;
      p := taicpu(hp);
      Result := ((p.opcode in [A_LDI,A_MOV,A_LDS]) and (reg=p.oper[0]^.reg) and ((p.oper[1]^.typ<>top_reg) or (reg<>p.oper[0]^.reg))) or
        ((p.opcode in [A_LD,A_LDD,A_LPM]) and (reg=p.oper[0]^.reg) and not(RegInRef(reg,p.oper[1]^.ref^))) or
        ((p.opcode in [A_MOVW]) and ((reg=p.oper[0]^.reg) or (TRegister(ord(reg)+1)=p.oper[0]^.reg)) and not(reg=p.oper[1]^.reg) and not(TRegister(ord(reg)+1)=p.oper[1]^.reg)) or
        ((p.opcode in [A_POP]) and (reg=p.oper[0]^.reg));
    end;


  function TCpuAsmOptimizer.InstructionLoadsFromReg(const reg: TRegister; const hp: tai): boolean;
    var
      p: taicpu;
      i: longint;
    begin
      Result := false;

      if not (assigned(hp) and (hp.typ = ait_instruction)) then
        exit;
      p:=taicpu(hp);

      i:=0;

      { we do not care about the stack pointer }
      if p.opcode in [A_POP] then
        exit;

      { first operand only written?
        then skip it }
      if p.opcode in [A_MOV,A_LD,A_LDD,A_LDS,A_LPM,A_LDI,A_MOVW] then
        i:=1;

      while(i<p.ops) do
        begin
          case p.oper[I]^.typ of
            top_reg:
              Result := (p.oper[I]^.reg = reg) or
                { MOVW }
                ((i=1) and (p.opcode=A_MOVW) and (getsupreg(p.oper[0]^.reg)+1=getsupreg(reg)));
            top_ref:
              Result :=
                (p.oper[I]^.ref^.base = reg) or
                (p.oper[I]^.ref^.index = reg);
          end;
          { Bailout if we found something }
          if Result then
            exit;
          Inc(I);
        end;
    end;

  function TCpuAsmOptimizer.PeepHoleOptPass1Cpu(var p: tai): boolean;
    var
      hp1,hp2,hp3,hp4,hp5: tai;
      alloc, dealloc: tai_regalloc;
      i: integer;
      l: TAsmLabel;
      TmpUsedRegs : TAllUsedRegs;
    begin
      result := false;
      case p.typ of
        ait_instruction:
          begin
            {
              change
              <op> reg,x,y
              cp reg,r1
              into
              <op>s reg,x,y
            }
            { this optimization can applied only to the currently enabled operations because
              the other operations do not update all flags and FPC does not track flag usage }
            if MatchInstruction(p, [A_ADC,A_ADD,A_AND,A_ANDI,A_ASR,A_COM,A_DEC,A_EOR,
                                    A_INC,A_LSL,A_LSR,
                                    A_OR,A_ORI,A_ROL,A_ROR,A_SBC,A_SBCI,A_SUB,A_SUBI]) and
              GetNextInstruction(p, hp1) and
              ((MatchInstruction(hp1, A_CP) and
                (((taicpu(p).oper[0]^.reg = taicpu(hp1).oper[0]^.reg) and
                  (taicpu(hp1).oper[1]^.reg = NR_R1)) or
                 ((taicpu(p).oper[0]^.reg = taicpu(hp1).oper[1]^.reg) and
                  (taicpu(hp1).oper[0]^.reg = NR_R1) and
                  (taicpu(p).opcode in [A_ADC,A_ADD,A_AND,A_ANDI,A_ASR,A_COM,A_EOR,
                                        A_LSL,A_LSR,
                                        A_OR,A_ORI,A_ROL,A_ROR])))) or
               (MatchInstruction(hp1, A_CPI) and
                (taicpu(p).opcode = A_ANDI) and
                (taicpu(p).oper[1]^.typ=top_const) and
                (taicpu(hp1).oper[1]^.typ=top_const) and
                (taicpu(p).oper[1]^.val=taicpu(hp1).oper[1]^.val))) and
              GetNextInstruction(hp1, hp2) and
              { be careful here, following instructions could use other flags
                however after a jump fpc never depends on the value of flags }
              { All above instructions set Z and N according to the following
                Z := result = 0;
                N := result[31];
                EQ = Z=1; NE = Z=0;
                MI = N=1; PL = N=0; }
              MatchInstruction(hp2, A_BRxx) and
              (taicpu(hp2).condition in [C_EQ,C_NE,C_MI,C_PL]) { and
              no flag allocation tracking implemented yet on avr
              assigned(FindRegDealloc(NR_DEFAULTFLAGS,tai(hp2.Next)))} then
              begin
                { move flag allocation if possible }
                { no flag allocation tracking implemented yet on avr
                GetLastInstruction(hp1, hp2);
                hp2:=FindRegAlloc(NR_DEFAULTFLAGS,tai(hp2.Next));
                if assigned(hp2) then
                  begin
                    asml.Remove(hp2);
                    asml.insertbefore(hp2, p);
                  end;
                }

                // If we compare to the same value we are masking then invert the comparison
                if (taicpu(hp1).opcode=A_CPI) then
                  taicpu(hp2).condition:=inverse_cond(taicpu(hp2).condition);

                asml.InsertBefore(tai_regalloc.alloc(NR_DEFAULTFLAGS,p), p);
                asml.InsertAfter(tai_regalloc.dealloc(NR_DEFAULTFLAGS,hp2), hp2);
                IncludeRegInUsedRegs(NR_DEFAULTFLAGS,UsedRegs);

                DebugMsg('Peephole OpCp2Op performed', p);

                asml.remove(hp1);
                hp1.free;
                Result:=true;
              end
            else
              case taicpu(p).opcode of
                A_LDI:
                  begin
                    { turn
                      ldi reg0, imm
                      cp/mov reg1, reg0
                      dealloc reg0
                      into
                      cpi/ldi reg1, imm
                    }
                    if MatchOpType(p,top_reg,top_const) and
                       GetNextInstructionUsingReg(p, hp1, taicpu(p).oper[0]^.reg) and
                       MatchInstruction(hp1,[A_CP,A_MOV],2) and
                       (not RegModifiedBetween(taicpu(p).oper[0]^.reg, p, hp1)) and
                       MatchOpType(hp1,top_reg,top_reg) and
                       (getsupreg(taicpu(hp1).oper[0]^.reg) in [16..31]) and
                       (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) then
                      begin
                        CopyUsedRegs(TmpUsedRegs);
                        if not(RegUsedAfterInstruction(taicpu(hp1).oper[1]^.reg, hp1, TmpUsedRegs)) then
                          begin
                            case taicpu(hp1).opcode of
                              A_CP:
                                taicpu(hp1).opcode:=A_CPI;
                              A_MOV:
                                taicpu(hp1).opcode:=A_LDI;
                              else
                                internalerror(2016111901);
                            end;
                            taicpu(hp1).loadconst(1, taicpu(p).oper[1]^.val);

                            alloc:=FindRegAllocBackward(taicpu(p).oper[0]^.reg,tai(p.Previous));
                            dealloc:=FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(hp1.Next));

                            if assigned(alloc) and assigned(dealloc) then
                              begin
                                asml.Remove(alloc);
                                alloc.Free;
                                asml.Remove(dealloc);
                                dealloc.Free;
                              end;

                            DebugMsg('Peephole LdiMov/Cp2Ldi/Cpi performed', p);

                            GetNextInstruction(p,hp1);
                            asml.Remove(p);
                            p.Free;
                            p:=hp1;

                            result:=true;
                          end;
                        ReleaseUsedRegs(TmpUsedRegs);
                      end;
                  end;
                A_STS:
                  if (taicpu(p).oper[0]^.ref^.symbol=nil) and
                    (taicpu(p).oper[0]^.ref^.relsymbol=nil) and
                    (getsupreg(taicpu(p).oper[0]^.ref^.base)=RS_NO) and
                    (getsupreg(taicpu(p).oper[0]^.ref^.index)=RS_NO) and
                    (taicpu(p).oper[0]^.ref^.addressmode=AM_UNCHANGED) and
                    (taicpu(p).oper[0]^.ref^.offset>=32) and
                    (taicpu(p).oper[0]^.ref^.offset<=95) then
                    begin
                      DebugMsg('Peephole Sts2Out performed', p);

                      taicpu(p).opcode:=A_OUT;
                      taicpu(p).loadconst(0,taicpu(p).oper[0]^.ref^.offset-32);
                    end;
                A_LDS:
                  if (taicpu(p).oper[1]^.ref^.symbol=nil) and
                    (taicpu(p).oper[1]^.ref^.relsymbol=nil) and
                    (getsupreg(taicpu(p).oper[1]^.ref^.base)=RS_NO) and
                    (getsupreg(taicpu(p).oper[1]^.ref^.index)=RS_NO) and
                    (taicpu(p).oper[1]^.ref^.addressmode=AM_UNCHANGED) and
                    (taicpu(p).oper[1]^.ref^.offset>=32) and
                    (taicpu(p).oper[1]^.ref^.offset<=95) then
                    begin
                      DebugMsg('Peephole Lds2In performed', p);

                      taicpu(p).opcode:=A_IN;
                      taicpu(p).loadconst(1,taicpu(p).oper[1]^.ref^.offset-32);
                    end;
                A_IN:
                    if GetNextInstruction(p,hp1) then
                      begin
                        {
                          in rX,Y
                          ori rX,n
                          out Y,rX

                          into
                          sbi rX,lg(n)
                        }
                        if (taicpu(p).oper[1]^.val<=31) and
                          MatchInstruction(hp1,A_ORI) and
                          (taicpu(hp1).oper[0]^.reg=taicpu(p).oper[0]^.reg) and
                          (PopCnt(byte(taicpu(hp1).oper[1]^.val))=1) and
                          GetNextInstruction(hp1,hp2) and
                          MatchInstruction(hp2,A_OUT) and
                          MatchOperand(taicpu(hp2).oper[1]^,taicpu(p).oper[0]^) and
                          MatchOperand(taicpu(hp2).oper[0]^,taicpu(p).oper[1]^) then
                          begin
                            DebugMsg('Peephole InOriOut2Sbi performed', p);

                            taicpu(p).opcode:=A_SBI;
                            taicpu(p).loadconst(0,taicpu(p).oper[1]^.val);
                            taicpu(p).loadconst(1,BsrByte(taicpu(hp1).oper[1]^.val));
                            asml.Remove(hp1);
                            hp1.Free;
                            asml.Remove(hp2);
                            hp2.Free;
                            result:=true;
                          end
                         {
                          in rX,Y
                          andi rX,not(n)
                          out Y,rX

                          into
                          cbi rX,lg(n)
                        }
                        else if (taicpu(p).oper[1]^.val<=31) and
                           MatchInstruction(hp1,A_ANDI) and
                           (taicpu(hp1).oper[0]^.reg=taicpu(p).oper[0]^.reg) and
                           (PopCnt(byte(not(taicpu(hp1).oper[1]^.val)))=1) and
                           GetNextInstruction(hp1,hp2) and
                           MatchInstruction(hp2,A_OUT) and
                           MatchOperand(taicpu(hp2).oper[1]^,taicpu(p).oper[0]^) and
                           MatchOperand(taicpu(hp2).oper[0]^,taicpu(p).oper[1]^) then
                          begin
                            DebugMsg('Peephole InAndiOut2Cbi performed', p);

                            taicpu(p).opcode:=A_CBI;
                            taicpu(p).loadconst(0,taicpu(p).oper[1]^.val);
                            taicpu(p).loadconst(1,BsrByte(not(taicpu(hp1).oper[1]^.val)));
                            asml.Remove(hp1);
                            hp1.Free;
                            asml.Remove(hp2);
                            hp2.Free;
                            result:=true;
                          end
                         {
                              in rX,Y
                              andi rX,n
                              breq/brne L1

                          into
                              sbis/sbic Y,lg(n)
                              jmp L1
                            .Ltemp:
                        }
                        else if (taicpu(p).oper[1]^.val<=31) and
                           MatchInstruction(hp1,A_ANDI) and
                           (taicpu(hp1).oper[0]^.reg=taicpu(p).oper[0]^.reg) and
                           (PopCnt(byte(taicpu(hp1).oper[1]^.val))=1) and
                           GetNextInstruction(hp1,hp2) and
                           MatchInstruction(hp2,A_BRxx) and
                           (taicpu(hp2).condition in [C_EQ,C_NE]) then
                          begin
                            if taicpu(hp2).condition=C_EQ then
                              taicpu(p).opcode:=A_SBIS
                            else
                              taicpu(p).opcode:=A_SBIC;

                            DebugMsg('Peephole InAndiBrx2SbixJmp performed', p);

                            taicpu(p).loadconst(0,taicpu(p).oper[1]^.val);
                            taicpu(p).loadconst(1,BsrByte(taicpu(hp1).oper[1]^.val));
                            asml.Remove(hp1);
                            hp1.Free;

                            taicpu(hp2).condition:=C_None;
                            if CPUAVR_HAS_JMP_CALL in cpu_capabilities[current_settings.cputype] then
                              taicpu(hp2).opcode:=A_JMP
                            else
                              taicpu(hp2).opcode:=A_RJMP;

                            current_asmdata.getjumplabel(l);
                            l.increfs;
                            asml.InsertAfter(tai_label.create(l), hp2);

                            result:=true;
                          end;
                      end;
                A_ANDI:
                  begin
                    {
                      Turn
                          andi rx, #pow2
                          brne l
                          <op>
                        l:
                      Into
                          sbrs rx, #(1 shl imm)
                          <op>
                        l:
                    }
                    if (taicpu(p).ops=2) and
                       (taicpu(p).oper[1]^.typ=top_const) and
                       ispowerof2(taicpu(p).oper[1]^.val,i) and
                       assigned(FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(p.next))) and
                       GetNextInstruction(p,hp1) and
                       (hp1.typ=ait_instruction) and
                       (taicpu(hp1).opcode=A_BRxx) and
                       (taicpu(hp1).condition in [C_EQ,C_NE]) and
                       (taicpu(hp1).ops>0) and
                       (taicpu(hp1).oper[0]^.typ = top_ref) and
                       (taicpu(hp1).oper[0]^.ref^.symbol is TAsmLabel) and
                       GetNextInstruction(hp1,hp2) and
                       (hp2.typ=ait_instruction) and
                       GetNextInstruction(hp2,hp3) and
                       (hp3.typ=ait_label) and
                       (taicpu(hp1).oper[0]^.ref^.symbol=tai_label(hp3).labsym) then
                      begin
                        DebugMsg('Peephole AndiBr2Sbr performed', p);

                        taicpu(p).oper[1]^.val:=i;

                        if taicpu(hp1).condition=C_NE then
                          taicpu(p).opcode:=A_SBRS
                        else
                          taicpu(p).opcode:=A_SBRC;

                        asml.Remove(hp1);
                        hp1.free;

                        result:=true;
                      end
                    {
                      Remove
                        andi rx, #y
                        dealloc rx
                    }
                    else if (taicpu(p).ops=2) and
                       (taicpu(p).oper[0]^.typ=top_reg) and
                       assigned(FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(p.next))) and
                       (assigned(FindRegDeAlloc(NR_DEFAULTFLAGS,tai(p.Next))) or
                        (not RegInUsedRegs(NR_DEFAULTFLAGS,UsedRegs))) then
                      begin
                        DebugMsg('Redundant Andi removed', p);

                        GetNextInstruction(p,hp1);

                        AsmL.Remove(p);
                        p.free;

                        p:=hp1;

                        result:=true;
                      end;
                  end;
                A_CLR:
                  begin
                    { turn the common
                      clr rX
                      mov/ld rX, rY
                      into
                      mov/ld rX, rY
                    }
                    if (taicpu(p).ops=1) and
                       (taicpu(p).oper[0]^.typ=top_reg) and
                       GetNextInstructionUsingReg(p, hp1, taicpu(p).oper[0]^.reg) and
                       (not RegModifiedBetween(taicpu(p).oper[0]^.reg, p, hp1)) and
                       (hp1.typ=ait_instruction) and
                       (taicpu(hp1).opcode in [A_MOV,A_LD]) and
                       (taicpu(hp1).ops>0) and
                       (taicpu(hp1).oper[0]^.typ=top_reg) and
                       (taicpu(hp1).oper[0]^.reg=taicpu(p).oper[0]^.reg) then
                      begin
                        DebugMsg('Peephole ClrMov2Mov performed', p);

                        asml.Remove(p);
                        p.Free;
                        p:=hp1;
                        result:=true;
                      end
                    { turn
                      clr rX
                      ...
                      adc rY, rX
                      into
                      ...
                      adc rY, r1
                    }
                    else if (taicpu(p).ops=1) and
                       (taicpu(p).oper[0]^.typ=top_reg) and
                       GetNextInstructionUsingReg(p, hp1, taicpu(p).oper[0]^.reg) and
                       (not RegModifiedBetween(taicpu(p).oper[0]^.reg, p, hp1)) and
                       (hp1.typ=ait_instruction) and
                       (taicpu(hp1).opcode in [A_ADC,A_SBC]) and
                       (taicpu(hp1).ops=2) and
                       (taicpu(hp1).oper[1]^.typ=top_reg) and
                       (taicpu(hp1).oper[1]^.reg=taicpu(p).oper[0]^.reg) and
                       (taicpu(hp1).oper[0]^.reg<>taicpu(p).oper[0]^.reg) and
                       assigned(FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(hp1.Next))) then
                      begin
                        DebugMsg('Peephole ClrAdc2Adc performed', p);

                        taicpu(hp1).oper[1]^.reg:=NR_R1;

                        alloc:=FindRegAllocBackward(taicpu(p).oper[0]^.reg,tai(p.Previous));
                        dealloc:=FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(hp1.Next));

                        if assigned(alloc) and assigned(dealloc) then
                          begin
                            asml.Remove(alloc);
                            alloc.Free;
                            asml.Remove(dealloc);
                            dealloc.Free;
                          end;

                        GetNextInstruction(p,hp1);
                        asml.Remove(p);
                        p.free;
                        p:=hp1;

                        result:=true;
                      end;
                  end;
                A_PUSH:
                  begin
                    { turn
                      push reg0
                      push reg1
                      pop reg3
                      pop reg2

                      into

                      movw reg2,reg0

                      or

                      mov  reg3,reg1
                      mov  reg2,reg0

                    }
                    if GetNextInstruction(p,hp1) and
                       MatchInstruction(hp1,A_PUSH) and

                       GetNextInstruction(hp1,hp2) and
                       MatchInstruction(hp2,A_POP) and

                       GetNextInstruction(hp2,hp3) and
                       MatchInstruction(hp3,A_POP) then
                      begin
                       if (getsupreg(taicpu(hp1).oper[0]^.reg)=getsupreg(taicpu(p).oper[0]^.reg)+1) and
                         ((getsupreg(taicpu(p).oper[0]^.reg) mod 2)=0) and
                         (getsupreg(taicpu(hp2).oper[0]^.reg)=getsupreg(taicpu(hp3).oper[0]^.reg)+1) and
                         ((getsupreg(taicpu(hp3).oper[0]^.reg) mod 2)=0) then
                         begin
                           DebugMsg('Peephole PushPushPopPop2Movw performed', p);

                           taicpu(p).ops:=2;
                           taicpu(p).opcode:=A_MOVW;

                           taicpu(p).loadreg(1, taicpu(p).oper[0]^.reg);
                           taicpu(p).loadreg(0, taicpu(hp3).oper[0]^.reg);

                           asml.Remove(hp1);
                           hp1.Free;
                           asml.Remove(hp2);
                           hp2.Free;
                           asml.Remove(hp3);
                           hp3.Free;

                           result:=true;
                         end
                       else
                         begin
                           DebugMsg('Peephole PushPushPopPop2MovMov performed', p);

                           taicpu(p).ops:=2;
                           taicpu(p).opcode:=A_MOV;

                           taicpu(hp1).ops:=2;
                           taicpu(hp1).opcode:=A_MOV;

                           taicpu(p).loadreg(1, taicpu(p).oper[0]^.reg);
                           taicpu(p).loadreg(0, taicpu(hp3).oper[0]^.reg);

                           taicpu(hp1).loadreg(1, taicpu(hp1).oper[0]^.reg);
                           taicpu(hp1).loadreg(0, taicpu(hp2).oper[0]^.reg);

                           asml.Remove(hp2);
                           hp2.Free;
                           asml.Remove(hp3);
                           hp3.Free;

                           result:=true;
                         end

                      end;
                  end;
                A_MOV:
                  begin
                    { turn
                      mov reg0, reg1
                      push reg0
                      dealloc reg0
                      into
                      push reg1
                    }
                    if (taicpu(p).ops=2) and
                       (taicpu(p).oper[0]^.typ = top_reg) and
                       (taicpu(p).oper[1]^.typ = top_reg) and
                       GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                       (not RegModifiedBetween(taicpu(p).oper[1]^.reg, p, hp1)) and
                       (hp1.typ = ait_instruction) and
                       (taicpu(hp1).opcode in [A_PUSH,A_MOV,A_CP,A_CPC,A_ADD,A_SUB,A_ADC,A_SBC,A_EOR,A_AND,A_OR,
                                               A_STD,A_ST,
                                               A_OUT,A_IN]) and
                       RegInInstruction(taicpu(p).oper[0]^.reg, hp1) and
                       (not RegModifiedByInstruction(taicpu(p).oper[0]^.reg, hp1)) and
                       {(taicpu(hp1).ops=1) and
                       (taicpu(hp1).oper[0]^.typ = top_reg) and
                       (taicpu(hp1).oper[0]^.reg=taicpu(p).oper[0]^.reg) and  }
                       assigned(FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(hp1.Next))) then
                      begin
                        DebugMsg('Peephole MovPush2Push performed', p);

                        for i := 0 to taicpu(hp1).ops-1 do
                          if taicpu(hp1).oper[i]^.typ=top_reg then
                            if taicpu(hp1).oper[i]^.reg=taicpu(p).oper[0]^.reg then
                              taicpu(hp1).oper[i]^.reg:=taicpu(p).oper[1]^.reg;

                        alloc:=FindRegAllocBackward(taicpu(p).oper[0]^.reg,tai(p.Previous));
                        dealloc:=FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(hp1.Next));

                        if assigned(alloc) and assigned(dealloc) then
                          begin
                            asml.Remove(alloc);
                            alloc.Free;
                            asml.Remove(dealloc);
                            dealloc.Free;
                          end;

                        GetNextInstruction(p,hp1);
                        asml.Remove(p);
                        p.free;
                        p:=hp1;
                        result:=true;
                      end
                    { remove
                      mov reg0,reg0
                    }
                    else if (taicpu(p).ops=2) and
                       (taicpu(p).oper[0]^.typ = top_reg) and
                       (taicpu(p).oper[1]^.typ = top_reg) and
                       (taicpu(p).oper[0]^.reg = taicpu(p).oper[1]^.reg) then
                      begin
                        DebugMsg('Peephole RedundantMov performed', p);

                        GetNextInstruction(p,hp1);
                        asml.remove(p);
                        p.free;
                        p:=hp1;
                        result:=true;
                      end
                    {
                      Turn
                        mov rx,ry
                        op rx,rz
                        mov ry, rx
                      Into
                        op ry,rz
                    }
                    else if (taicpu(p).ops=2) and
                       (taicpu(p).oper[0]^.typ = top_reg) and
                       (taicpu(p).oper[1]^.typ = top_reg) and
                       GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                       (hp1.typ=ait_instruction) and
                       (taicpu(hp1).ops >= 1) and
                       (taicpu(hp1).oper[0]^.typ = top_reg) and
                       GetNextInstructionUsingReg(hp1,hp2,taicpu(hp1).oper[0]^.reg) and
                       (hp2.typ=ait_instruction) and
                       (taicpu(hp2).opcode=A_MOV) and
                       (taicpu(hp2).oper[0]^.typ = top_reg) and
                       (taicpu(hp2).oper[1]^.typ = top_reg) and
                       (taicpu(hp2).oper[0]^.reg = taicpu(p).oper[1]^.reg) and
                       (taicpu(hp2).oper[1]^.reg = taicpu(hp1).oper[0]^.reg) and
                       (taicpu(hp2).oper[1]^.reg = taicpu(p).oper[0]^.reg) and
                       (not RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp2)) and
                       (taicpu(hp1).opcode in [A_ADD,A_ADC,A_SUB,A_SBC,A_AND,A_OR,A_EOR,
                                               A_LSL,A_LSR,A_ASR,A_ROR,A_ROL]) and
                       assigned(FindRegDeAlloc(taicpu(p).oper[0]^.reg, tai(hp2.Next))) then
                      begin
                        DebugMsg('Peephole MovOpMov2Op performed', p);

                        if (taicpu(hp1).ops=2) and
                           (taicpu(hp1).oper[1]^.typ=top_reg) and
                           (taicpu(hp1).oper[1]^.reg = taicpu(p).oper[1]^.reg) then
                          taicpu(hp1).oper[1]^.reg:=taicpu(p).oper[1]^.reg;

                        taicpu(hp1).oper[0]^.reg:=taicpu(p).oper[1]^.reg;

                        alloc:=FindRegAllocBackward(taicpu(p).oper[0]^.reg,tai(p.Previous));
                        dealloc:=FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(hp2.Next));

                        if assigned(alloc) and assigned(dealloc) then
                          begin
                            asml.Remove(alloc);
                            alloc.Free;
                            asml.Remove(dealloc);
                            dealloc.Free;
                          end;

                        GetNextInstruction(p,hp1);

                        asml.remove(p);
                        p.free;
                        asml.remove(hp2);
                        hp2.free;

                        p:=hp1;

                        result:=true;
                      end
                    {
                      Turn
                        mov rx,ry
                        op  rx,rw
                        mov rw,rx
                      Into
                        op rw,ry
                    }
                    else if (taicpu(p).ops=2) and
                       (taicpu(p).oper[0]^.typ = top_reg) and
                       (taicpu(p).oper[1]^.typ = top_reg) and
                       GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
                       (hp1.typ=ait_instruction) and
                       (taicpu(hp1).ops = 2) and
                       (taicpu(hp1).oper[0]^.typ = top_reg) and
                       (taicpu(hp1).oper[1]^.typ = top_reg) and
                       GetNextInstructionUsingReg(hp1,hp2,taicpu(hp1).oper[0]^.reg) and
                       (hp2.typ=ait_instruction) and
                       (taicpu(hp2).opcode=A_MOV) and
                       (taicpu(hp2).oper[0]^.typ = top_reg) and
                       (taicpu(hp2).oper[1]^.typ = top_reg) and
                       (taicpu(hp2).oper[0]^.reg = taicpu(hp1).oper[1]^.reg) and
                       (taicpu(hp2).oper[1]^.reg = taicpu(hp1).oper[0]^.reg) and
                       (taicpu(hp2).oper[1]^.reg = taicpu(p).oper[0]^.reg) and
                       (not RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp1)) and
                       (taicpu(hp1).opcode in [A_ADD,A_ADC,A_AND,A_OR,A_EOR]) and
                       assigned(FindRegDeAlloc(taicpu(p).oper[0]^.reg, tai(hp2.Next))) then
                      begin
                        DebugMsg('Peephole MovOpMov2Op2 performed', p);

                        taicpu(hp1).oper[0]^.reg:=taicpu(hp2).oper[0]^.reg;
                        taicpu(hp1).oper[1]^.reg:=taicpu(p).oper[1]^.reg;

                        alloc:=FindRegAllocBackward(taicpu(p).oper[0]^.reg,tai(p.Previous));
                        dealloc:=FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(hp2.Next));

                        if assigned(alloc) and assigned(dealloc) then
                          begin
                            asml.Remove(alloc);
                            alloc.Free;
                            asml.Remove(dealloc);
                            dealloc.Free;
                          end;

                        GetNextInstruction(p,hp1);

                        asml.remove(p);
                        p.free;
                        asml.remove(hp2);
                        hp2.free;

                        p:=hp1;

                        result:=true;
                      end
                    { fold
                      mov reg2,reg0
                      mov reg3,reg1
                      to
                      movw reg2,reg0
                    }
                    else if (CPUAVR_HAS_MOVW in cpu_capabilities[current_settings.cputype]) and
                       (taicpu(p).ops=2) and
                       (taicpu(p).oper[0]^.typ = top_reg) and
                       (taicpu(p).oper[1]^.typ = top_reg) and
                       getnextinstruction(p,hp1) and
                       (hp1.typ = ait_instruction) and
                       (taicpu(hp1).opcode = A_MOV) and
                       (taicpu(hp1).ops=2) and
                       (taicpu(hp1).oper[0]^.typ = top_reg) and
                       (taicpu(hp1).oper[1]^.typ = top_reg) and
                       (getsupreg(taicpu(hp1).oper[0]^.reg)=getsupreg(taicpu(p).oper[0]^.reg)+1) and
                       ((getsupreg(taicpu(p).oper[0]^.reg) mod 2)=0) and
                       ((getsupreg(taicpu(p).oper[1]^.reg) mod 2)=0) and
                       (getsupreg(taicpu(hp1).oper[1]^.reg)=getsupreg(taicpu(p).oper[1]^.reg)+1) then
                      begin
                        DebugMsg('Peephole MovMov2Movw performed', p);

                        alloc:=FindRegAllocBackward(taicpu(hp1).oper[0]^.reg,tai(hp1.Previous));
                        if assigned(alloc) then
                          begin
                            asml.Remove(alloc);
                            asml.InsertBefore(alloc,p);
                          end;

                        taicpu(p).opcode:=A_MOVW;
                        asml.remove(hp1);
                        hp1.free;
                        result:=true;
                      end
                    {
                      This removes the first mov from
                      mov rX,...
                      mov rX,...
                    }
                    else if (hp1.typ=ait_instruction) and (taicpu(hp1).opcode=A_MOV) then
                      while (hp1.typ=ait_instruction) and (taicpu(hp1).opcode=A_MOV) and
                            MatchOperand(taicpu(p).oper[0]^, taicpu(hp1).oper[0]^) and
                            { don't remove the first mov if the second is a mov rX,rX }
                            not(MatchOperand(taicpu(hp1).oper[0]^,taicpu(hp1).oper[1]^)) do
                        begin
                          DebugMsg('Peephole MovMov2Mov performed', p);

                          asml.remove(p);
                          p.free;
                          p:=hp1;
                          GetNextInstruction(hp1,hp1);
                          result:=true;
                          if not assigned(hp1) then
                            break;
                        end;
                  end;
                A_SBIC,
                A_SBIS:
                  begin
                    {
                      Turn
                          sbic/sbis X, y
                          jmp .L1
                          op
                        .L1:

                      into
                          sbis/sbic X,y
                          op
                        .L1:
                    }
                    if GetNextInstruction(p, hp1) and
                       (hp1.typ=ait_instruction) and
                       (taicpu(hp1).opcode in [A_JMP,A_RJMP]) and
                       (taicpu(hp1).ops>0) and
                       (taicpu(hp1).oper[0]^.typ = top_ref) and
                       (taicpu(hp1).oper[0]^.ref^.symbol is TAsmLabel) and
                       GetNextInstruction(hp1, hp2) and
                       (hp2.typ=ait_instruction) and
                       (not taicpu(hp2).is_jmp) and
                       GetNextInstruction(hp2, hp3) and
                       (hp3.typ=ait_label) and
                       (taicpu(hp1).oper[0]^.ref^.symbol=tai_label(hp3).labsym) then
                      begin
                        DebugMsg('Peephole SbiJmp2Sbi performed',p);

                        if taicpu(p).opcode=A_SBIC then
                          taicpu(p).opcode:=A_SBIS
                        else
                          taicpu(p).opcode:=A_SBIC;

                        tai_label(hp3).labsym.decrefs;

                        AsmL.remove(hp1);
                        taicpu(hp1).Free;

                        result:=true;
                      end
                    {
                      Turn
                          sbiX X, y
                          jmp .L1
                          jmp .L2
                        .L1:
                          op
                        .L2:

                      into
                          sbiX X,y
                        .L1:
                          op
                        .L2:
                    }
                    else if GetNextInstruction(p, hp1) and
                       (hp1.typ=ait_instruction) and
                       (taicpu(hp1).opcode in [A_JMP,A_RJMP]) and
                       (taicpu(hp1).ops>0) and
                       (taicpu(hp1).oper[0]^.typ = top_ref) and
                       (taicpu(hp1).oper[0]^.ref^.symbol is TAsmLabel) and

                       GetNextInstruction(hp1, hp2) and
                       (hp2.typ=ait_instruction) and
                       (taicpu(hp2).opcode in [A_JMP,A_RJMP]) and
                       (taicpu(hp2).ops>0) and
                       (taicpu(hp2).oper[0]^.typ = top_ref) and
                       (taicpu(hp2).oper[0]^.ref^.symbol is TAsmLabel) and

                       GetNextInstruction(hp2, hp3) and
                       (hp3.typ=ait_label) and
                       (taicpu(hp1).oper[0]^.ref^.symbol=tai_label(hp3).labsym) and

                       GetNextInstruction(hp3, hp4) and
                       (hp4.typ=ait_instruction) and

                       GetNextInstruction(hp4, hp5) and
                       (hp3.typ=ait_label) and
                       (taicpu(hp2).oper[0]^.ref^.symbol=tai_label(hp5).labsym) then
                      begin
                        DebugMsg('Peephole SbiJmpJmp2Sbi performed',p);

                        tai_label(hp3).labsym.decrefs;
                        tai_label(hp5).labsym.decrefs;

                        AsmL.remove(hp1);
                        taicpu(hp1).Free;

                        AsmL.remove(hp2);
                        taicpu(hp2).Free;

                        result:=true;
                      end;
                  end;
              end;
          end;
      end;
    end;


  procedure TCpuAsmOptimizer.PeepHoleOptPass2;
    begin
    end;

begin
  casmoptimizer:=TCpuAsmOptimizer;
End.
