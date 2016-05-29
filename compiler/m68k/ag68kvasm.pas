{
    Copyright (c) 2016 by the Free Pascal development team

    This unit is the VASM assembler writer for 68k

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

unit ag68kvasm;

{$i fpcdefs.inc}

  interface

    uses
       aasmbase,systems,
       aasmtai,aasmdata,
       aggas,ag68kgas,
       cpubase,cgutils,
       globtype;

  type
    tm68kvasm = class(Tm68kGNUassembler)
      constructor create(info: pasminfo; smart: boolean); override;
      function MakeCmdLine: TCmdStr; override;
    end;

  implementation

    uses
       cutils,cfileutl,globals,verbose,
       cgbase,
       assemble,script,
       itcpugas,cpuinfo,
       aasmcpu;


{****************************************************************************}
{                         VASM m68k Assembler writer                         }
{****************************************************************************}


    constructor tm68kvasm.create(info: pasminfo; smart: boolean);
      begin
        inherited;
        InstrWriter := Tm68kInstrWriter.create(self);
      end;

    function tm68kvasm.MakeCmdLine: TCmdStr;
      var
        objtype: string;
      begin
        result:=asminfo^.asmcmd;

        case target_info.system of
          system_m68k_amiga: objtype:='-Fhunk';
          system_m68k_atari: objtype:='-Fvobj'; // fix me?
          system_m68k_linux: objtype:='-Felf';
        else
          internalerror(2016052601);
        end;

        if (target_info.system = system_m68k_amiga) then 
          begin
            Replace(result,'$ASM',maybequoted(ScriptFixFileName(Unix2AmigaPath(AsmFileName))));
            Replace(result,'$OBJ',maybequoted(ScriptFixFileName(Unix2AmigaPath(ObjFileName))));
          end
        else
          begin
            Replace(result,'$ASM',maybequoted(ScriptFixFileName(AsmFileName)));
            Replace(result,'$OBJ',maybequoted(ScriptFixFileName(ObjFileName)));
          end;
        Replace(result,'$ARCH','-m'+GasCpuTypeStr[current_settings.cputype]);
        Replace(result,'$OTYPE',objtype);
        Replace(result,'$EXTRAOPT',asmextraopt);
      end;



{*****************************************************************************
                                  Initialize
*****************************************************************************}

  const
    as_m68k_vasm_info : tasminfo =
       (
         id     : as_m68k_vasm;

         idtxt  : 'VASM';
         asmbin : 'vasmm68k_std';
         asmcmd:  '-quiet -elfregs -gas $OTYPE $ARCH -o $OBJ $EXTRAOPT $ASM';
         supported_targets : [system_m68k_amiga,system_m68k_atari,system_m68k_linux];
         flags : [af_needar,af_smartlink_sections];
         labelprefix : '.L';
         comment : '# ';
         dollarsign: '$';
       );

begin
  RegisterAssembler(as_m68k_vasm_info,tm68kvasm);
end.
