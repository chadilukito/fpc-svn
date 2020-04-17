{
    Copyright (c) 2006 by Florian Klaempfl

    Contains the base types for the AVR

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
{# Base unit for processor information. This unit contains
   enumerations of registers, opcodes, sizes, and other
   such things which are processor specific.
}
unit cpubase;

{$i fpcdefs.inc}

  interface

    uses
      cutils,cclasses,
      globtype,globals,
      cpuinfo,
      aasmbase,
      cgbase
      ;


{*****************************************************************************
                                Assembler Opcodes
*****************************************************************************}

    type
      TAsmOp={$i z80op.inc}


      { This should define the array of instructions as string }
      op2strtable=array[tasmop] of string[4];

    const
      { First value of opcode enumeration }
      firstop = low(tasmop);
      { Last value of opcode enumeration  }
      lastop  = high(tasmop);

      std_op2str:op2strtable={$i z80stdopnames.inc}

      { call/reg instructions are not considered as jmp instructions for the usage cases of
        this set }
      jmp_instructions = [A_JP,A_JR,A_DJNZ];
      call_jmp_instructions = [A_CALL]+jmp_instructions;

{*****************************************************************************
                                  Registers
*****************************************************************************}

    type
      { Number of registers used for indexing in tables }
      tregisterindex=0..{$i rz80nor.inc}-1;

    const
      { Available Superregisters }
      {$i rz80sup.inc}

      { No Subregisters }
      R_SUBWHOLE = R_SUBL;

      { Available Registers }
      {$i rz80con.inc}

      { Integer Super registers first and last }
      first_int_supreg = RS_A;
      first_int_imreg = $20;

      { Float Super register first and last }
      first_fpu_supreg    = RS_INVALID;
      first_fpu_imreg     = 0;

      { MM Super register first and last }
      first_mm_supreg    = RS_INVALID;
      first_mm_imreg     = 0;

      regnumber_count_bsstart = 32;

      regnumber_table : array[tregisterindex] of tregister = (
        {$i rz80num.inc}
      );

      regstabs_table : array[tregisterindex] of shortint = (
        {$i rz80sta.inc}
      );

      regdwarf_table : array[tregisterindex] of shortint = (
        {$i rz80dwa.inc}
      );
      { registers which may be destroyed by calls }
      VOLATILE_INTREGISTERS = [RS_A,RS_B,RS_C,RS_D,RS_E,RS_H,RS_L];
      VOLATILE_FPUREGISTERS = [];

    type
      totherregisterset = set of tregisterindex;

{*****************************************************************************
                                Conditions
*****************************************************************************}

    type
      TAsmCond=(C_None,
        C_NZ,C_Z,C_NC,C_C,C_PO,C_PE,C_P,C_M
      );

    const
      cond2str : array[TAsmCond] of string[2]=('',
        'nz','z','nc','c','po','pe','p','m'
      );

      uppercond2str : array[TAsmCond] of string[2]=('',
        'NZ','Z','NC','C','PO','PE','P','M'
      );

{*****************************************************************************
                                   Flags
*****************************************************************************}

    type
      TResFlags = (F_NotPossible,F_NE,F_E,F_NC,F_C,F_PO,F_PE,F_P,F_M);


{*****************************************************************************
                                 Constants
*****************************************************************************}

    const
      max_operands = 4;

      maxintregs = 15;
      maxfpuregs = 0;
      maxaddrregs = 0;

{*****************************************************************************
                                Operand Sizes
*****************************************************************************}

    type
      topsize = (S_NO,
        S_B,S_W,S_L,S_BW,S_BL,S_WL,
        S_IS,S_IL,S_IQ,
        S_FS,S_FL,S_FX,S_D,S_Q,S_FV,S_FXX
      );

{*****************************************************************************
                                 Constants
*****************************************************************************}

    const
      firstsaveintreg = RS_INVALID;
      lastsaveintreg  = RS_INVALID;
      firstsavefpureg = RS_INVALID;
      lastsavefpureg  = RS_INVALID;
      firstsavemmreg  = RS_INVALID;
      lastsavemmreg   = RS_INVALID;

{*****************************************************************************
                          Default generic sizes
*****************************************************************************}

      { Defines the default address size for a processor, }
      OS_ADDR = OS_16;
      { the natural int size for a processor,
        has to match osuinttype/ossinttype as initialized in psystem,
        initially, this was OS_16/OS_S16 on avr, but experience has
        proven that it is better to make it 8 Bit thus having the same
        size as a register.
      }
      OS_INT = OS_8;
      OS_SINT = OS_S8;
      { the maximum float size for a processor,           }
      OS_FLOAT = OS_F64;
      { the size of a vector register for a processor     }
      OS_VECTOR = OS_M32;

{*****************************************************************************
                          Generic Register names
*****************************************************************************}

      { Stack pointer register }
      NR_STACK_POINTER_REG = NR_SP;
      RS_STACK_POINTER_REG = RS_SP;
      { Frame pointer register }
      RS_FRAME_POINTER_REG = RS_IX;
      NR_FRAME_POINTER_REG = NR_IX;
      { Register for addressing absolute data in a position independant way,
        such as in PIC code. The exact meaning is ABI specific. For
        further information look at GCC source : PIC_OFFSET_TABLE_REGNUM
      }
      NR_PIC_OFFSET_REG = NR_INVALID;
      { Results are returned in this register (32-bit values) }
      NR_FUNCTION_RETURN_REG = NR_L;
      RS_FUNCTION_RETURN_REG = RS_L;
      { Low part of 64bit return value }
      NR_FUNCTION_RETURN64_LOW_REG = NR_L;
      RS_FUNCTION_RETURN64_LOW_REG = RS_L;
      { High part of 64bit return value }
      NR_FUNCTION_RETURN64_HIGH_REG = NR_C;
      RS_FUNCTION_RETURN64_HIGH_REG = RS_C;
      { The value returned from a function is available in this register }
      NR_FUNCTION_RESULT_REG = NR_FUNCTION_RETURN_REG;
      RS_FUNCTION_RESULT_REG = RS_FUNCTION_RETURN_REG;
      { The lowh part of 64bit value returned from a function }
      NR_FUNCTION_RESULT64_LOW_REG = NR_FUNCTION_RETURN64_LOW_REG;
      RS_FUNCTION_RESULT64_LOW_REG = RS_FUNCTION_RETURN64_LOW_REG;
      { The high part of 64bit value returned from a function }
      NR_FUNCTION_RESULT64_HIGH_REG = NR_FUNCTION_RETURN64_HIGH_REG;
      RS_FUNCTION_RESULT64_HIGH_REG = RS_FUNCTION_RETURN64_HIGH_REG;

      NR_FPU_RESULT_REG = NR_NO;

      NR_MM_RESULT_REG  = NR_NO;

      NR_RETURN_ADDRESS_REG = NR_FUNCTION_RETURN_REG;

      { Offset where the parent framepointer is pushed }
      PARENT_FRAMEPOINTER_OFFSET = 0;

      NR_DEFAULTFLAGS = NR_F;
      RS_DEFAULTFLAGS = RS_F;

{*****************************************************************************
                       GCC /ABI linking information
*****************************************************************************}

    const
      { Registers which must be saved when calling a routine declared as
        cppdecl, cdecl, stdcall, safecall, palmossyscall. The registers
        saved should be the ones as defined in the target ABI and / or GCC.

        This value can be deduced from the CALLED_USED_REGISTERS array in the
        GCC source.
      }
      { on avr, gen_entry/gen_exit code saves/restores registers, so
        we don't need this array }
      saved_standard_registers : array[0..0] of tsuperregister =
        (RS_INVALID);
      { Required parameter alignment when calling a routine declared as
        stdcall and cdecl. The alignment value should be the one defined
        by GCC or the target ABI.

        The value of this constant is equal to the constant
        PARM_BOUNDARY / BITS_PER_UNIT in the GCC source.
      }
      std_param_align = 4;

      saved_address_registers : array[0..0] of tsuperregister = (RS_INVALID);
      saved_mm_registers : array[0..0] of tsuperregister = (RS_INVALID);

{*****************************************************************************
                                  Helpers
*****************************************************************************}

    { Returns the tcgsize corresponding with the size of reg.}
    function reg_cgsize(const reg: tregister) : tcgsize;
    function cgsize2subreg(regtype: tregistertype; s:Tcgsize):Tsubregister;
    procedure inverse_flags(var f: TResFlags);
    function flags_to_cond(const f: TResFlags) : TAsmCond;
    function findreg_by_number(r:Tregister):tregisterindex;
    function std_regnum_search(const s:string):Tregister;
    function std_regname(r:Tregister):string;

    function inverse_cond(const c: TAsmCond): TAsmCond; {$ifdef USEINLINE}inline;{$endif USEINLINE}
    function conditions_equal(const c1, c2: TAsmCond): boolean; {$ifdef USEINLINE}inline;{$endif USEINLINE}

    { Checks if Subset is a subset of c (e.g. "less than" is a subset of "less than or equal" }
    function condition_in(const Subset, c: TAsmCond): Boolean;

    function dwarf_reg(r:tregister):byte;
    function dwarf_reg_no_error(r:tregister):shortint;
    function eh_return_data_regno(nr: longint): longint;

    function GetHigh(const r : TRegister) : TRegister;

    { returns the next virtual register }
    function GetNextReg(const r : TRegister) : TRegister;

    { returns the last virtual register }
    function GetLastReg(const r : TRegister) : TRegister;

    { returns the register with the offset of ofs of a continuous set of register starting with r }
    function GetOffsetReg(const r : TRegister;ofs : shortint) : TRegister;
    { returns the register with the offset of ofs of a continuous set of register starting with r and being continued with rhi }
    function GetOffsetReg64(const r,rhi: TRegister;ofs : shortint): TRegister;

    function is_calljmp(o:tasmop):boolean;{$ifdef USEINLINE}inline;{$endif USEINLINE}

  implementation

    uses
      rgBase,verbose;


    const
      std_regname_table : TRegNameTable = (
        {$i rz80std.inc}
      );

      regnumber_index : array[tregisterindex] of tregisterindex = (
        {$i rz80rni.inc}
      );

      std_regname_index : array[tregisterindex] of tregisterindex = (
        {$i rz80sri.inc}
      );


    function cgsize2subreg(regtype: tregistertype; s:Tcgsize):Tsubregister;
      begin
        case s of
          OS_8,OS_S8:
            cgsize2subreg:=R_SUBL;
          OS_16,OS_S16:
            cgsize2subreg:=R_SUBW;
          OS_32,OS_S32:
            cgsize2subreg:=R_SUBD;
          OS_64,OS_S64:
            cgsize2subreg:=R_SUBQ;
          OS_NO:
            { error message should have been thrown already before, so avoid only
              an internal error }
            cgsize2subreg:=R_SUBNONE;
          else
            internalerror(200301231);
        end;
      end;


    function reg_cgsize(const reg: tregister): tcgsize;
      begin
        case getregtype(reg) of
          R_INTREGISTER :
            reg_cgsize:=OS_8;
          R_ADDRESSREGISTER :
            reg_cgsize:=OS_16;
          else
            internalerror(2011021905);
          end;
        end;


    procedure inverse_flags(var f: TResFlags);
      const
        inv_flags: array[TResFlags] of TResFlags =
          (F_NotPossible,F_E,F_NE,F_C,F_NC,F_PE,F_PO,F_M,F_P);
      begin
        f:=inv_flags[f];
      end;


    function flags_to_cond(const f: TResFlags) : TAsmCond;
      const
        flag_2_cond: array[F_NE..F_M] of TAsmCond =
          (C_NZ,C_Z,C_NC,C_C,C_PO,C_PE,C_P,C_M);
      begin
        if f=F_NotPossible then
          internalerror(2011022101);
        if f>high(flag_2_cond) then
          internalerror(200112301);
        result:=flag_2_cond[f];
      end;


    function findreg_by_number(r:Tregister):tregisterindex;
      begin
        result:=rgBase.findreg_by_number_table(r,regnumber_index);
      end;


    function std_regnum_search(const s:string):Tregister;
      begin
        result:=regnumber_table[findreg_by_name_table(s,std_regname_table,std_regname_index)];
      end;


    function std_regname(r:Tregister):string;
      var
        p : tregisterindex;
      begin
        p:=findreg_by_number_table(r,regnumber_index);
        if p<>0 then
          result:=std_regname_table[p]
        else
          result:=generic_regname(r);
      end;


    function inverse_cond(const c: TAsmCond): TAsmCond; {$ifdef USEINLINE}inline;{$endif USEINLINE}
      const
        inverse: array[TAsmCond] of TAsmCond=(C_None,
          C_Z,C_NZ,C_C,C_NC,C_PE,C_PO,C_M,C_P);
      begin
        result := inverse[c];
      end;


    function conditions_equal(const c1, c2: TAsmCond): boolean; {$ifdef USEINLINE}inline;{$endif USEINLINE}
      begin
        result := c1 = c2;
      end;


    { Checks if Subset is a subset of c (e.g. "less than" is a subset of "less than or equal" }
    function condition_in(const Subset, c: TAsmCond): Boolean;
      begin
        Result := {(c.cond = C_None) or} conditions_equal(Subset, c);

        { TODO: Can a PowerPC programmer please update this procedure to
          actually detect subsets? Thanks. [Kit] }
      end;


    function rotl(d : dword;b : byte) : dword;
      begin
         result:=(d shr (32-b)) or (d shl b);
      end;


    function dwarf_reg(r:tregister):byte;
      var
        reg : shortint;
      begin
        reg:=regdwarf_table[findreg_by_number(r)];
        if reg=-1 then
          internalerror(200603251);
        result:=reg;
      end;


    function dwarf_reg_no_error(r:tregister):shortint;
      begin
        result:=regdwarf_table[findreg_by_number(r)];
      end;


    function eh_return_data_regno(nr: longint): longint;
      begin
        result:=-1;
      end;


    function GetHigh(const r : TRegister) : TRegister;
      begin
        result:=TRegister(longint(r)+1)
      end;


    function GetNextReg(const r: TRegister): TRegister;
      begin
        result:=TRegister(longint(r)+1);
      end;


    function GetLastReg(const r: TRegister): TRegister;
      begin
        result:=TRegister(longint(r)-1);
      end;


    function GetOffsetReg(const r: TRegister;ofs : shortint): TRegister;
      begin
        result:=TRegister(longint(r)+ofs);
      end;


    function GetOffsetReg64(const r,rhi: TRegister;ofs : shortint): TRegister;
      begin
        if ofs>3 then
          result:=TRegister(longint(rhi)+ofs-4)
        else
          result:=TRegister(longint(r)+ofs);
      end;


    function is_calljmp(o:tasmop):boolean;{$ifdef USEINLINE}inline;{$endif USEINLINE}
      begin
        is_calljmp:= o in call_jmp_instructions;
      end;


end.
