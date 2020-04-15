{
    Copyright (c) 1998-2020 by Jonas Maebe and Florian Klaempfl, members of the Free Pascal
    Development Team

    This unit implements an ARM optimizer object used commonly for ARM and AAarch64

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

Unit aoptarm;

{$i fpcdefs.inc}

{ $define DEBUG_PREREGSCHEDULER}
{ $define DEBUG_AOPTCPU}

Interface

uses
  cgbase, cgutils, cpubase, aasmtai, aasmcpu,aopt, aoptobj;

Type
  { while ARM and AAarch64 look not very similar at a first glance,
    several optimizations can be shared between both }
  TARMAsmOptimizer = class(TAsmOptimizer)
    procedure DebugMsg(const s : string; p : tai);

    function RemoveSuperfluousMove(const p: tai; movp: tai; const optimizer: string): boolean;
    function GetNextInstructionUsingReg(Current: tai; out Next: tai; reg: TRegister): Boolean;

    function OptPass1UXTB(var p: tai): Boolean;
  End;

  function MatchInstruction(const instr: tai; const op: TCommonAsmOps; const cond: TAsmConds; const postfix: TOpPostfixes): boolean;
  function MatchInstruction(const instr: tai; const op: TAsmOp; const cond: TAsmConds; const postfix: TOpPostfixes): boolean;
{$ifdef AARCH64}
  function MatchInstruction(const instr: tai; const op: TAsmOps; const postfix: TOpPostfixes): boolean;
{$endif AARCH64}
  function MatchInstruction(const instr: tai; const op: TAsmOp; const postfix: TOpPostfixes): boolean;

  function RefsEqual(const r1, r2: treference): boolean;

  function MatchOperand(const oper: TOper; const reg: TRegister): boolean; inline;
  function MatchOperand(const oper1: TOper; const oper2: TOper): boolean; inline;

Implementation

  uses
    cutils,verbose,globtype,globals,
    systems,
    cpuinfo,
    cgobj,procinfo,
    aasmbase,aasmdata;


{$ifdef DEBUG_AOPTCPU}
  procedure TARMAsmOptimizer.DebugMsg(const s: string;p : tai);
    begin
      asml.insertbefore(tai_comment.Create(strpnew(s)), p);
    end;
{$else DEBUG_AOPTCPU}
  procedure TARMAsmOptimizer.DebugMsg(const s: string;p : tai);inline;
    begin
    end;
{$endif DEBUG_AOPTCPU}

  function MatchInstruction(const instr: tai; const op: TCommonAsmOps; const cond: TAsmConds; const postfix: TOpPostfixes): boolean;
    begin
      result :=
        (instr.typ = ait_instruction) and
        ((op = []) or ((ord(taicpu(instr).opcode)<256) and (taicpu(instr).opcode in op))) and
        ((cond = []) or (taicpu(instr).condition in cond)) and
        ((postfix = []) or (taicpu(instr).oppostfix in postfix));
    end;


  function MatchInstruction(const instr: tai; const op: TAsmOp; const cond: TAsmConds; const postfix: TOpPostfixes): boolean;
    begin
      result :=
        (instr.typ = ait_instruction) and
        (taicpu(instr).opcode = op) and
        ((cond = []) or (taicpu(instr).condition in cond)) and
        ((postfix = []) or (taicpu(instr).oppostfix in postfix));
    end;


{$ifdef AARCH64}
  function MatchInstruction(const instr: tai; const op: TAsmOps; const postfix: TOpPostfixes): boolean;
    begin
      result :=
        (instr.typ = ait_instruction) and
        ((op = []) or (taicpu(instr).opcode in op)) and
        ((postfix = []) or (taicpu(instr).oppostfix in postfix));
    end;
{$endif AARCH64}

  function MatchInstruction(const instr: tai; const op: TAsmOp; const postfix: TOpPostfixes): boolean;
    begin
      result :=
        (instr.typ = ait_instruction) and
        (taicpu(instr).opcode = op) and
        ((postfix = []) or (taicpu(instr).oppostfix in postfix));
    end;


  function MatchOperand(const oper: TOper; const reg: TRegister): boolean; inline;
    begin
      result := (oper.typ = top_reg) and (oper.reg = reg);
    end;


  function RefsEqual(const r1, r2: treference): boolean;
    begin
      refsequal :=
        (r1.offset = r2.offset) and
        (r1.base = r2.base) and
        (r1.index = r2.index) and (r1.scalefactor = r2.scalefactor) and
        (r1.symbol=r2.symbol) and (r1.refaddr = r2.refaddr) and
        (r1.relsymbol = r2.relsymbol) and
{$ifdef ARM}
        (r1.signindex = r2.signindex) and
{$endif ARM}
        (r1.shiftimm = r2.shiftimm) and
        (r1.addressmode = r2.addressmode) and
        (r1.shiftmode = r2.shiftmode) and
        (r1.volatility=[]) and
        (r2.volatility=[]);
    end;


  function MatchOperand(const oper1: TOper; const oper2: TOper): boolean; inline;
    begin
      result := oper1.typ = oper2.typ;

      if result then
        case oper1.typ of
          top_const:
            Result:=oper1.val = oper2.val;
          top_reg:
            Result:=oper1.reg = oper2.reg;
          top_conditioncode:
            Result:=oper1.cc = oper2.cc;
          top_realconst:
            Result:=oper1.val_real = oper2.val_real;
          top_ref:
            Result:=RefsEqual(oper1.ref^, oper2.ref^);
          else Result:=false;
        end
    end;


  function TARMAsmOptimizer.GetNextInstructionUsingReg(Current: tai;
    Out Next: tai; reg: TRegister): Boolean;
    begin
      Next:=Current;
      repeat
        Result:=GetNextInstruction(Next,Next);
      until not (Result) or
            not(cs_opt_level3 in current_settings.optimizerswitches) or
            (Next.typ<>ait_instruction) or
            RegInInstruction(reg,Next) or
            is_calljmp(taicpu(Next).opcode)
{$ifdef ARM}
            or RegModifiedByInstruction(NR_PC,Next);
{$endif ARM}
    end;


  function TARMAsmOptimizer.RemoveSuperfluousMove(const p: tai; movp: tai; const optimizer: string):boolean;
    var
      alloc,
      dealloc : tai_regalloc;
      hp1 : tai;
    begin
      Result:=false;
      if MatchInstruction(movp, A_MOV, [taicpu(p).condition], [PF_None]) and
        { We can't optimize if there is a shiftop }
        (taicpu(movp).ops=2) and
        MatchOperand(taicpu(movp).oper[1]^, taicpu(p).oper[0]^.reg) and
        { don't mess with moves to fp }
        (taicpu(movp).oper[0]^.reg<>current_procinfo.framepointer) and
        { the destination register of the mov might not be used beween p and movp }
        not(RegUsedBetween(taicpu(movp).oper[0]^.reg,p,movp)) and
{$ifdef ARM}
        { cb[n]z are thumb instructions which require specific registers, with no wide forms }
        (taicpu(p).opcode<>A_CBZ) and
        (taicpu(p).opcode<>A_CBNZ) and
        {There is a special requirement for MUL and MLA, oper[0] and oper[1] are not allowed to be the same}
        not (
          (taicpu(p).opcode in [A_MLA, A_MUL]) and
          (taicpu(p).oper[1]^.reg = taicpu(movp).oper[0]^.reg) and
          (current_settings.cputype < cpu_armv6)
        ) and
{$endif ARM}
        { Take care to only do this for instructions which REALLY load to the first register.
          Otherwise
            str reg0, [reg1]
            mov reg2, reg0
          will be optimized to
            str reg2, [reg1]
        }
        RegLoadedWithNewValue(taicpu(p).oper[0]^.reg, p) then
        begin
          dealloc:=FindRegDeAlloc(taicpu(p).oper[0]^.reg,tai(movp.Next));
          if assigned(dealloc) then
            begin
              DebugMsg('Peephole '+optimizer+' removed superfluous mov', movp);
              result:=true;

              { taicpu(p).oper[0]^.reg is not used anymore, try to find its allocation
                and remove it if possible }
              asml.Remove(dealloc);
              alloc:=FindRegAllocBackward(taicpu(p).oper[0]^.reg,tai(p.previous));
              if assigned(alloc) then
                begin
                  asml.Remove(alloc);
                  alloc.free;
                  dealloc.free;
                end
              else
                asml.InsertAfter(dealloc,p);

              { try to move the allocation of the target register }
              GetLastInstruction(movp,hp1);
              alloc:=FindRegAlloc(taicpu(movp).oper[0]^.reg,tai(hp1.Next));
              if assigned(alloc) then
                begin
                  asml.Remove(alloc);
                  asml.InsertBefore(alloc,p);
                  { adjust used regs }
                  IncludeRegInUsedRegs(taicpu(movp).oper[0]^.reg,UsedRegs);
                end;

              { finally get rid of the mov }
              taicpu(p).loadreg(0,taicpu(movp).oper[0]^.reg);
              { Remove preindexing and postindexing for LDR in some cases.
                For example:
                  ldr	reg2,[reg1, xxx]!
                  mov reg1,reg2
                must be translated to:
                  ldr	reg1,[reg1, xxx]

                Preindexing must be removed there, since the same register is used as the base and as the target.
                Such case is not allowed for ARM CPU and produces crash. }
              if (taicpu(p).opcode = A_LDR) and (taicpu(p).oper[1]^.typ = top_ref)
                and (taicpu(movp).oper[0]^.reg = taicpu(p).oper[1]^.ref^.base)
              then
                taicpu(p).oper[1]^.ref^.addressmode:=AM_OFFSET;
              asml.remove(movp);
              movp.free;
            end;
        end;
    end;


  function TARMAsmOptimizer.OptPass1UXTB(var p : tai) : Boolean;
    var
      hp1, hp2: tai;
    begin
      Result:=false;
      {
        change
        uxtb reg2,reg1
        strb reg2,[...]
        dealloc reg2
        to
        strb reg1,[...]
      }
      if MatchInstruction(p, taicpu(p).opcode, [C_None], [PF_None]) and
        (taicpu(p).ops=2) and
        GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
        MatchInstruction(hp1, A_STR, [C_None], [PF_B]) and
        assigned(FindRegDealloc(taicpu(p).oper[0]^.reg,tai(hp1.Next))) and
        { the reference in strb might not use reg2 }
        not(RegInRef(taicpu(p).oper[0]^.reg,taicpu(hp1).oper[1]^.ref^)) and
        { reg1 might not be modified inbetween }
        not(RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp1)) then
        begin
          DebugMsg('Peephole UxtbStrb2Strb done', p);
          taicpu(hp1).loadReg(0,taicpu(p).oper[1]^.reg);
          GetNextInstruction(p,hp2);
          asml.remove(p);
          p.free;
          p:=hp2;
          result:=true;
        end
      {
        change
        uxtb reg2,reg1
        uxth reg3,reg2
        dealloc reg2
        to
        uxtb reg3,reg1
      }
      else if MatchInstruction(p, A_UXTB, [C_None], [PF_None]) and
        (taicpu(p).ops=2) and
        GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
        MatchInstruction(hp1, A_UXTH, [C_None], [PF_None]) and
        (taicpu(hp1).ops = 2) and
        MatchOperand(taicpu(hp1).oper[1]^, taicpu(p).oper[0]^.reg) and
        RegEndofLife(taicpu(p).oper[0]^.reg,taicpu(hp1)) and
        { reg1 might not be modified inbetween }
        not(RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp1)) then
        begin
          DebugMsg('Peephole UxtbUxth2Uxtb done', p);
          AllocRegBetween(taicpu(hp1).oper[0]^.reg,p,hp1,UsedRegs);
          taicpu(p).loadReg(0,taicpu(hp1).oper[0]^.reg);
          asml.remove(hp1);
          hp1.free;
          result:=true;
        end
      {
        change
        uxtb reg2,reg1
        uxtb reg3,reg2
        dealloc reg2
        to
        uxtb reg3,reg1
      }
      else if MatchInstruction(p, A_UXTB, [C_None], [PF_None]) and
        (taicpu(p).ops=2) and
        GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
        MatchInstruction(hp1, A_UXTB, [C_None], [PF_None]) and
        (taicpu(hp1).ops = 2) and
        MatchOperand(taicpu(hp1).oper[1]^, taicpu(p).oper[0]^.reg) and
        RegEndofLife(taicpu(p).oper[0]^.reg,taicpu(hp1)) and
        { reg1 might not be modified inbetween }
        not(RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp1)) then
        begin
          DebugMsg('Peephole UxtbUxtb2Uxtb done', p);
          AllocRegBetween(taicpu(hp1).oper[0]^.reg,p,hp1,UsedRegs);
          taicpu(p).loadReg(0,taicpu(hp1).oper[0]^.reg);
          asml.remove(hp1);
          hp1.free;
          result:=true;
        end
      {
        change
        uxtb reg2,reg1
        and reg3,reg2,#0x*FF
        dealloc reg2
        to
        uxtb reg3,reg1
      }
      else if MatchInstruction(p, A_UXTB, [C_None], [PF_None]) and
        (taicpu(p).ops=2) and
        GetNextInstructionUsingReg(p,hp1,taicpu(p).oper[0]^.reg) and
        MatchInstruction(hp1, A_AND, [C_None], [PF_None]) and
        (taicpu(hp1).ops=3) and
        (taicpu(hp1).oper[2]^.typ=top_const) and
        ((taicpu(hp1).oper[2]^.val and $FF)=$FF) and
        MatchOperand(taicpu(hp1).oper[1]^, taicpu(p).oper[0]^.reg) and
        RegEndofLife(taicpu(p).oper[0]^.reg,taicpu(hp1)) and
        { reg1 might not be modified inbetween }
        not(RegModifiedBetween(taicpu(p).oper[1]^.reg,p,hp1)) then
        begin
          DebugMsg('Peephole UxtbAndImm2Uxtb done', p);
          taicpu(hp1).opcode:=A_UXTB;
          taicpu(hp1).ops:=2;
          taicpu(hp1).loadReg(1,taicpu(p).oper[1]^.reg);
          GetNextInstruction(p,hp2);
          asml.remove(p);
          p.free;
          p:=hp2;
          result:=true;
        end
      else if GetNextInstructionUsingReg(p, hp1, taicpu(p).oper[0]^.reg) and
        RemoveSuperfluousMove(p, hp1, 'UxtbMov2Data') then
        Result:=true;
    end;


end.

