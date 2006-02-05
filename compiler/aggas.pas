{
    Copyright (c) 1998-2006 by the Free Pascal team

    This unit implements the generic part of the GNU assembler
    (v2.8 or later) writer

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
{ Base unit for writing GNU assembler output.
}
unit aggas;

{$i fpcdefs.inc}

interface

    uses
{$IFDEF USE_SYSUTILS}
      SysUtils,
{$ELSE USE_SYSUTILS}
      dos,
{$ENDIF USE_SYSUTILS}
      cclasses,
      globtype,globals,
      aasmbase,aasmtai,aasmcpu,
      assemble;


    type
      {# This is a derived class which is used to write
         GAS styled assembler.

         The WriteInstruction() method must be overriden
         to write a single instruction to the assembler
         file.
      }
      TGNUAssembler=class(texternalassembler)
      protected
        function sectionname(atype:tasmsectiontype;const aname:string):string;virtual;
        procedure WriteSection(atype:tasmsectiontype;const aname:string);
        procedure WriteExtraHeader;virtual;
        procedure WriteInstruction(hp: tai);  virtual; abstract;
      public
        procedure WriteTree(p:TAAsmoutput);override;
        procedure WriteAsmList;override;
      private
        setcount: longint;
        procedure WriteDecodedSleb128(a: aint);
        procedure WriteDecodedUleb128(a: aword);
        function NextSetLabel: string;
      end;

implementation

    uses
      cutils,systems,
      fmodule,finput,verbose,
      itcpugas
      ;

    const
      line_length = 70;

    var
      CurrSecType  : TAsmSectionType; { last section type written }
      lastfileinfo : tfileposinfo;
      infile,
      lastinfile   : tinputfile;
      symendcount  : longint;

    type
{$ifdef cpuextended}
      t80bitarray = array[0..9] of byte;
{$endif cpuextended}
      t64bitarray = array[0..7] of byte;
      t32bitarray = array[0..3] of byte;

{****************************************************************************}
{                          Support routines                                  }
{****************************************************************************}

   function fixline(s:string):string;
   {
     return s with all leading and ending spaces and tabs removed
   }
     var
       i,j,k : integer;
     begin
       i:=length(s);
       while (i>0) and (s[i] in [#9,' ']) do
        dec(i);
       j:=1;
       while (j<i) and (s[j] in [#9,' ']) do
        inc(j);
       for k:=j to i do
        if s[k] in [#0..#31,#127..#255] then
         s[k]:='.';
       fixline:=Copy(s,j,i-j+1);
     end;

    function single2str(d : single) : string;
      var
         hs : string;
      begin
         str(d,hs);
      { replace space with + }
         if hs[1]=' ' then
          hs[1]:='+';
         single2str:='0d'+hs
      end;

    function double2str(d : double) : string;
      var
         hs : string;
      begin
         str(d,hs);
      { replace space with + }
         if hs[1]=' ' then
          hs[1]:='+';
         double2str:='0d'+hs
      end;

    function extended2str(e : extended) : string;
      var
         hs : string;
      begin
         str(e,hs);
      { replace space with + }
         if hs[1]=' ' then
          hs[1]:='+';
         extended2str:='0d'+hs
      end;


  { convert floating point values }
  { to correct endian             }
  procedure swap64bitarray(var t: t64bitarray);
    var
     b: byte;
    begin
      b:= t[7];
      t[7] := t[0];
      t[0] := b;

      b := t[6];
      t[6] := t[1];
      t[1] := b;

      b:= t[5];
      t[5] := t[2];
      t[2] := b;

      b:= t[4];
      t[4] := t[3];
      t[3] := b;
   end;


   procedure swap32bitarray(var t: t32bitarray);
    var
     b: byte;
    begin
      b:= t[1];
      t[1]:= t[2];
      t[2]:= b;

      b:= t[0];
      t[0]:= t[3];
      t[3]:= b;
    end;


    const
      ait_const2str : array[aitconst_128bit..aitconst_indirect_symbol] of string[20]=(
        #9'.fixme128'#9,#9'.quad'#9,#9'.long'#9,#9'.short'#9,#9'.byte'#9,
        #9'.sleb128'#9,#9'.uleb128'#9,
        #9'.rva'#9,#9'.indirect_symbol'#9
      );

{****************************************************************************}
{                          GNU Assembler writer                              }
{****************************************************************************}

    function TGNUAssembler.NextSetLabel: string;
      begin
        inc(setcount);
        result := target_asm.labelprefix+'$set$'+tostr(setcount);
      end;

    function TGNUAssembler.sectionname(atype:tasmsectiontype;const aname:string):string;
      const
        secnames : array[tasmsectiontype] of string[13] = ('',
{$warning TODO .rodata not yet working}
          '.text','.data','.data','.bss','.threadvar',
          'common',
          '.note',
          '__TEXT', { stubs }
          '.stab','.stabstr',
          '.idata$2','.idata$4','.idata$5','.idata$6','.idata$7','.edata',
          '.eh_frame',
          '.debug_frame','.debug_info','.debug_line','.debug_abbrev',
          'fpc.resptrs',
          '.toc'
        );
        secnames_pic : array[tasmsectiontype] of string[13] = ('',
          '.text','.data.rel','.data.rel','.bss','.threadvar',
          'common',
          '.note',
          '__TEXT', { stubs }
          '.stab','.stabstr',
          '.idata$2','.idata$4','.idata$5','.idata$6','.idata$7','.edata',
          '.eh_frame',
          '.debug_frame','.debug_info','.debug_line','.debug_abbrev',
          'fpc.resptrs',
          '.toc'
        );
      var
        secname : string;
      begin
        if (cs_create_pic in aktmoduleswitches) and
           not(target_info.system in [system_powerpc_darwin,system_i386_darwin]) then
          secname:=secnames_pic[atype]
        else
          secname:=secnames[atype];

        if (atype=sec_threadvar) and
          (target_info.system=system_i386_win32) then
          secname:='.tls';

        if use_smartlink_section and
           (aname<>'') then
          result:=secname+'.'+aname
        else
          result:=secname;
      end;


    procedure TGNUAssembler.WriteSection(atype:tasmsectiontype;const aname:string);
      var
        s : string;
      begin
        AsmLn;
        case target_info.system of
         system_i386_OS2,
         system_i386_EMX : ;
         system_powerpc_darwin :
           begin
             if atype=sec_stub then
               AsmWrite('.section ');
           end;
         else
          AsmWrite('.section ');
        end;
        s:=sectionname(atype,aname);
        AsmWrite(s);
        case atype of
          sec_fpc :
            AsmWrite(', "a", @progbits');
          sec_stub :
            begin
              if target_info.system=system_powerpc_darwin then
                AsmWrite(',__symbol_stub1,symbol_stubs,pure_instructions,16');
            end;
        end;
        AsmLn;
        CurrSecType:=atype;
      end;


    procedure TGNUAssembler.WriteDecodedUleb128(a: aword);
      var
        b: byte;
      begin
        repeat
          b := a and $7f;
          a := a shr 7;
          if (a <> 0) then
            b := b or $80;
          AsmWrite(tostr(b));
          if (a <> 0) then
            AsmWrite(',')
          else
            break;
        until false;
      end;


    procedure TGNUAssembler.WriteDecodedSleb128(a: aint);
      var
        b, size: byte;
        neg, more: boolean;
      begin
        more := true;
        neg := a < 0;
        size := sizeof(a)*8;
        repeat
          b := a and $7f;
          a := a shr 7;
          if (neg) then
            a := a or -(1 shl (size - 7));
          if (((a = 0) and
               (b and $40 = 0)) or
              ((a = -1) and
               (b and $40 <> 0))) then
            more := false
          else
            b := b or $80;
          AsmWrite(tostr(b));
          if (more) then
            AsmWrite(',')
          else
            break;
        until false;
      end;


    procedure TGNUAssembler.WriteTree(p:TAAsmoutput);

    function needsObject(hp : tai_symbol) : boolean;
      begin
        needsObject :=
            (
              assigned(hp.next) and
               (tai_symbol(hp.next).typ in [ait_const,ait_datablock,
                ait_real_32bit,ait_real_64bit,ait_real_80bit,ait_comp_64bit])
            ) or
            (hp.sym.typ=AT_DATA);

      end;

    var
      ch       : char;
      hp       : tai;
      hp1      : tailineinfo;
      consttype : taiconst_type;
      s,t      : string;
      i,pos,l  : longint;
      InlineLevel : longint;
      last_align : longint;
      co       : comp;
      sin      : single;
      d        : double;
{$ifdef cpuextended}
      e        : extended;
{$endif cpuextended}
      do_line  : boolean;

      sepChar : char;
      nextdwarffileidx : longint;
    begin
      if not assigned(p) then
       exit;

       nextdwarffileidx:=1;

      last_align := 2;
      InlineLevel:=0;
      { lineinfo is only needed for al_procedures (PFV) }
      do_line:=(cs_asm_source in aktglobalswitches) or
               ((cs_lineinfo in aktmoduleswitches)
                 and (p=asmlist[al_procedures]));
      hp:=tai(p.first);
      while assigned(hp) do
       begin
         if not(hp.typ in SkipLineInfo) then
          begin
            hp1 := hp as tailineinfo;
            aktfilepos:=hp1.fileinfo;
             { no line info for inlined code }
             if do_line and (inlinelevel=0) then
              begin
                { load infile }
                if lastfileinfo.fileindex<>hp1.fileinfo.fileindex then
                 begin
                   infile:=current_module.sourcefiles.get_file(hp1.fileinfo.fileindex);
                   if assigned(infile) then
                    begin
                      { open only if needed !! }
                      if (cs_asm_source in aktglobalswitches) then
                       infile.open;
                    end;
                   { avoid unnecessary reopens of the same file !! }
                   lastfileinfo.fileindex:=hp1.fileinfo.fileindex;
                   { be sure to change line !! }
                   lastfileinfo.line:=-1;
                 end;
              { write source }
                if (cs_asm_source in aktglobalswitches) and
                   assigned(infile) then
                 begin
                   if (infile<>lastinfile) then
                     begin
                       AsmWriteLn(target_asm.comment+'['+infile.name^+']');
                       if assigned(lastinfile) then
                         lastinfile.close;
                     end;
                   if (hp1.fileinfo.line<>lastfileinfo.line) and
                      ((hp1.fileinfo.line<infile.maxlinebuf) or (InlineLevel>0)) then
                     begin
                       if (hp1.fileinfo.line<>0) and
                          ((infile.linebuf^[hp1.fileinfo.line]>=0) or (InlineLevel>0)) then
                         AsmWriteLn(target_asm.comment+'['+tostr(hp1.fileinfo.line)+'] '+
                           fixline(infile.GetLineStr(hp1.fileinfo.line)));
                       { set it to a negative value !
                       to make that is has been read already !! PM }
                       if (infile.linebuf^[hp1.fileinfo.line]>=0) then
                         infile.linebuf^[hp1.fileinfo.line]:=-infile.linebuf^[hp1.fileinfo.line]-1;
                     end;
                 end;
                lastfileinfo:=hp1.fileinfo;
                lastinfile:=infile;
              end;
          end;

         case hp.typ of

           ait_comment :
             Begin
               AsmWrite(target_asm.comment);
               AsmWritePChar(tai_comment(hp).str);
               AsmLn;
             End;

           ait_regalloc :
             begin
               if (cs_asm_regalloc in aktglobalswitches) then
                 begin
                   AsmWrite(#9+target_asm.comment+'Register ');
                   repeat
                     AsmWrite(gas_regname(Tai_regalloc(hp).reg));
                     if (hp.next=nil) or
                        (tai(hp.next).typ<>ait_regalloc) or
                        (tai_regalloc(hp.next).ratype<>tai_regalloc(hp).ratype) then
                       break;
                     hp:=tai(hp.next);
                     AsmWrite(',');
                   until false;
                   AsmWrite(' ');
                   AsmWriteLn(regallocstr[tai_regalloc(hp).ratype]);
                 end;
             end;

           ait_tempalloc :
             begin
               if (cs_asm_tempalloc in aktglobalswitches) then
                 begin
{$ifdef EXTDEBUG}
                   if assigned(tai_tempalloc(hp).problem) then
                     AsmWriteLn(target_asm.comment+'Temp '+tostr(tai_tempalloc(hp).temppos)+','+
                       tostr(tai_tempalloc(hp).tempsize)+' '+tai_tempalloc(hp).problem^)
                   else
{$endif EXTDEBUG}
                     AsmWriteLn(target_asm.comment+'Temp '+tostr(tai_tempalloc(hp).temppos)+','+
                       tostr(tai_tempalloc(hp).tempsize)+' '+tempallocstr[tai_tempalloc(hp).allocation]);
                 end;
             end;

           ait_align :
             begin
               if tai_align(hp).aligntype>1 then
                 begin
                   if target_info.system <> system_powerpc_darwin then
                     begin
                       AsmWrite(#9'.balign '+tostr(tai_align(hp).aligntype));
                       if tai_align(hp).use_op then
                        AsmWrite(','+tostr(tai_align(hp).fillop))
                     end
                   else
                     begin
                       { darwin as only supports .align }
                       if not ispowerof2(tai_align(hp).aligntype,i) then
                         internalerror(2003010305);
                       AsmWrite(#9'.align '+tostr(i));
                       last_align := i;
                     end;
                   AsmLn;
                 end;
             end;

           ait_section :
             begin
               if tai_section(hp).sectype<>sec_none then
                 WriteSection(tai_section(hp).sectype,tai_section(hp).name^)
               else
                 begin
{$ifdef EXTDEBUG}
                   AsmWrite(target_asm.comment);
                   AsmWriteln(' sec_none');
{$endif EXTDEBUG}
                end;
             end;

           ait_datablock :
             begin
               if target_info.system=system_powerpc_darwin then
                 begin
                   {On Mac OS X you can't have common symbols in a shared
                    library, since those are in the TEXT section and the text section is
                    read-only in shared libraries (so it can be shared among different
                    processes). The alternate code creates some kind of common symbols in
                    the data segment. The generic code no longer uses common symbols, but
                    this doesn't work on Mac OS X as well.}
                   if tai_datablock(hp).is_global then
                     begin
                       asmwrite('.globl ');
                       asmwriteln(tai_datablock(hp).sym.name);
                       asmwriteln('.data');
                       asmwrite('.zerofill __DATA, __common, ');
                       asmwrite(tai_datablock(hp).sym.name);
                       asmwriteln(', '+tostr(tai_datablock(hp).size)+','+tostr(last_align));
                       if not(CurrSecType in [sec_data,sec_none]) then
                         writesection(CurrSecType,'');
                     end
                   else
                     begin
                       asmwrite(#9'.lcomm'#9);
                       asmwrite(tai_datablock(hp).sym.name);
                       asmwrite(','+tostr(tai_datablock(hp).size));
                       asmwrite(','+tostr(last_align));
                       asmwriteln('');
                     end
                 end
               else
                 begin
                   if Tai_datablock(hp).is_global then
                     begin
                       asmwrite(#9'.globl ');
                       asmwriteln(Tai_datablock(hp).sym.name);
                     end;
                   if (tf_needs_symbol_type in target_info.flags) then
                     asmwriteln(#9'.type '+Tai_datablock(hp).sym.name+',@object');
                   if (tf_needs_symbol_size in target_info.flags) and (tai_datablock(hp).size > 0) then
                     asmwriteln(#9'.size '+Tai_datablock(hp).sym.name+','+tostr(Tai_datablock(hp).size));
                   asmwrite(Tai_datablock(hp).sym.name);
                   asmwriteln(':');
                   asmwriteln(#9'.zero '+tostr(Tai_datablock(hp).size));
                 end;
             end;

           ait_const:
             begin
               consttype:=tai_const(hp).consttype;
               case consttype of
{$ifndef cpu64bit}
                 aitconst_128bit :
                    begin
                      internalerror(200404291);
                    end;

                 aitconst_64bit :
                    begin
                      if assigned(tai_const(hp).sym) then
                        internalerror(200404292);
                      AsmWrite(ait_const2str[aitconst_32bit]);
                      if target_info.endian = endian_little then
                        begin
                          AsmWrite(tostr(longint(lo(tai_const(hp).value))));
                          AsmWrite(',');
                          AsmWrite(tostr(longint(hi(tai_const(hp).value))));
                        end
                      else
                        begin
                          AsmWrite(tostr(longint(hi(tai_const(hp).value))));
                          AsmWrite(',');
                          AsmWrite(tostr(longint(lo(tai_const(hp).value))));
                        end;
                      AsmLn;
                    end;
{$endif cpu64bit}
                 aitconst_uleb128bit,
                 aitconst_sleb128bit,
{$ifdef cpu64bit}
                 aitconst_128bit,
                 aitconst_64bit,
{$endif cpu64bit}
                 aitconst_32bit,
                 aitconst_16bit,
                 aitconst_8bit,
                 aitconst_rva_symbol,
                 aitconst_indirect_symbol :
                   begin
                     if (target_info.system in [system_powerpc_darwin,system_i386_darwin]) and
                        (tai_const(hp).consttype in [aitconst_uleb128bit,aitconst_sleb128bit]) then
                       begin
                         AsmWrite(ait_const2str[aitconst_8bit]);
                         case tai_const(hp).consttype of
                           aitconst_uleb128bit:
                             WriteDecodedUleb128(aword(tai_const(hp).value));
                           aitconst_sleb128bit:
                             WriteDecodedSleb128(aint(tai_const(hp).value));
                         end
                       end
                     else
                       begin
                         AsmWrite(ait_const2str[tai_const(hp).consttype]);
                         l:=0;
                         t := '';
                         repeat
                           if assigned(tai_const(hp).sym) then
                             begin
                               if assigned(tai_const(hp).endsym) then
                                 begin
                                   if (target_info.system in [system_powerpc_darwin,system_i386_darwin]) then
                                     begin
                                       s := NextSetLabel;
                                       t := #9'.set '+s+','+tai_const(hp).endsym.name+'-'+tai_const(hp).sym.name;
                                     end
                                   else
                                     s:=tai_const(hp).endsym.name+'-'+tai_const(hp).sym.name
                                  end
                               else
                                 s:=tai_const(hp).sym.name;
                               if tai_const(hp).value<>0 then
                                 s:=s+tostr_with_plus(tai_const(hp).value);
                             end
                           else
                             s:=tostr(tai_const(hp).value);
                           AsmWrite(s);
                           inc(l,length(s));
                           { Values with symbols are written on a single line to improve
                             reading of the .s file (PFV) }
                           if assigned(tai_const(hp).sym) or
                              not(CurrSecType in [sec_data,sec_rodata]) or
                              (l>line_length) or
                              (hp.next=nil) or
                              (tai(hp.next).typ<>ait_const) or
                              (tai_const(hp.next).consttype<>consttype) or
                              assigned(tai_const(hp.next).sym) then
                             break;
                           hp:=tai(hp.next);
                           AsmWrite(',');
                         until false;
                         if (t <> '') then
                           begin
                             AsmLn;
                             AsmWrite(t);
                           end;
                       end;
                      AsmLn;
                   end;
                 end;
             end;

{$ifdef cpuextended}
           ait_real_80bit :
             begin
               if do_line then
                AsmWriteLn(target_asm.comment+'value: '+extended2str(tai_real_80bit(hp).value));
             { Make sure e is a extended type, bestreal could be
               a different type (bestreal) !! (PFV) }
               e:=tai_real_80bit(hp).value;
               AsmWrite(#9'.byte'#9);
               for i:=0 to 9 do
                begin
                  if i<>0 then
                   AsmWrite(',');
                  AsmWrite(tostr(t80bitarray(e)[i]));
                end;
               AsmLn;
             end;
{$endif cpuextended}

           ait_real_64bit :
             begin
               if do_line then
                AsmWriteLn(target_asm.comment+'value: '+double2str(tai_real_64bit(hp).value));
               d:=tai_real_64bit(hp).value;
               { swap the values to correct endian if required }
               if source_info.endian <> target_info.endian then
                 swap64bitarray(t64bitarray(d));
               AsmWrite(#9'.byte'#9);
{$ifdef arm}
{ on a real arm cpu, it's already hi/lo swapped }
{$ifndef cpuarm}
               if tai_real_64bit(hp).formatoptions=fo_hiloswapped then
                 begin
                   for i:=4 to 7 do
                     begin
                       if i<>4 then
                         AsmWrite(',');
                       AsmWrite(tostr(t64bitarray(d)[i]));
                     end;
                   for i:=0 to 3 do
                     begin
                       AsmWrite(',');
                       AsmWrite(tostr(t64bitarray(d)[i]));
                     end;
                 end
               else
{$endif cpuarm}
{$endif arm}
                 begin
                   for i:=0 to 7 do
                     begin
                       if i<>0 then
                         AsmWrite(',');
                       AsmWrite(tostr(t64bitarray(d)[i]));
                     end;
                 end;
               AsmLn;
             end;

           ait_real_32bit :
             begin
               if do_line then
                AsmWriteLn(target_asm.comment+'value: '+single2str(tai_real_32bit(hp).value));
               sin:=tai_real_32bit(hp).value;
               { swap the values to correct endian if required }
               if source_info.endian <> target_info.endian then
                 swap32bitarray(t32bitarray(sin));
               AsmWrite(#9'.byte'#9);
               for i:=0 to 3 do
                begin
                  if i<>0 then
                   AsmWrite(',');
                  AsmWrite(tostr(t32bitarray(sin)[i]));
                end;
               AsmLn;
             end;

           ait_comp_64bit :
             begin
               if do_line then
                AsmWriteLn(target_asm.comment+'value: '+extended2str(tai_comp_64bit(hp).value));
               AsmWrite(#9'.byte'#9);
{$ifdef FPC}
               co:=comp(tai_comp_64bit(hp).value);
{$else}
               co:=tai_comp_64bit(hp).value;
{$endif}
               { swap the values to correct endian if required }
               if source_info.endian <> target_info.endian then
                 swap64bitarray(t64bitarray(co));
               for i:=0 to 7 do
                begin
                  if i<>0 then
                   AsmWrite(',');
                  AsmWrite(tostr(t64bitarray(co)[i]));
                end;
               AsmLn;
             end;

           ait_string :
             begin
               pos:=0;
               for i:=1 to tai_string(hp).len do
                begin
                  if pos=0 then
                   begin
                     AsmWrite(#9'.ascii'#9'"');
                     pos:=20;
                   end;
                  ch:=tai_string(hp).str[i-1];
                  case ch of
                     #0, {This can't be done by range, because a bug in FPC}
                #1..#31,
             #128..#255 : s:='\'+tostr(ord(ch) shr 6)+tostr((ord(ch) and 63) shr 3)+tostr(ord(ch) and 7);
                    '"' : s:='\"';
                    '\' : s:='\\';
                  else
                   s:=ch;
                  end;
                  AsmWrite(s);
                  inc(pos,length(s));
                  if (pos>line_length) or (i=tai_string(hp).len) then
                   begin
                     AsmWriteLn('"');
                     pos:=0;
                   end;
                end;
             end;

           ait_label :
             begin
               if (tai_label(hp).l.is_used) then
                begin
                  if tai_label(hp).l.defbind=AB_GLOBAL then
                   begin
                     AsmWrite('.globl'#9);
                     AsmWriteLn(tai_label(hp).l.name);
                   end;
                  AsmWrite(tai_label(hp).l.name);
                  AsmWriteLn(':');
                end;
             end;

           ait_symbol :
             begin
               if tai_symbol(hp).is_global then
                begin
                  AsmWrite('.globl'#9);
                  AsmWriteLn(tai_symbol(hp).sym.name);
                end;
               if (target_info.system = system_powerpc64_linux) and
                 (tai_symbol(hp).sym.typ = AT_FUNCTION) then
                 begin
                   AsmWriteLn('.section "opd", "aw"');
                   AsmWriteLn('.align 3');
                   AsmWriteLn(tai_symbol(hp).sym.name + ':');
                   AsmWriteLn('.quad .' + tai_symbol(hp).sym.name + ', .TOC.@tocbase, 0');
                   AsmWriteLn('.previous');
                   AsmWriteLn('.size ' + tai_symbol(hp).sym.name + ', 24');
                   AsmWriteLn('.globl .' + tai_symbol(hp).sym.name);
                   AsmWriteLn('.type .' + tai_symbol(hp).sym.name + ', @function');
                   { the dotted name is the name of the actual function entry }
                   AsmWrite('.');
                 end
               else
                 begin
                   if (target_info.system <> system_arm_linux) then
                     begin
                       sepChar := '@';
                     end
                   else
                     begin
                       sepChar := '#';
                     end;

                   if (tf_needs_symbol_type in target_info.flags) then
                     begin
                       AsmWrite(#9'.type'#9 + tai_symbol(hp).sym.name);
                       if (needsObject(tai_symbol(hp))) then
                         begin
                           AsmWriteLn(',' + sepChar + 'object');
                         end
                       else
                         begin
                           AsmWriteLn(',' + sepChar + 'function');
                         end;
                     end;
                   if (tf_needs_symbol_size in target_info.flags) and (tai_symbol(hp).sym.size > 0) then begin
                     AsmWriteLn(#9'.size'#9 + tai_symbol(hp).sym.name + ', ' + tostr(tai_symbol(hp).sym.size));
                   end;
                 end;
               AsmWriteLn(tai_symbol(hp).sym.name + ':');
             end;

           ait_symbol_end :
             begin
               if tf_needs_symbol_size in target_info.flags then
                begin
                  s:=target_asm.labelprefix+'e'+tostr(symendcount);
                  inc(symendcount);
                  AsmWriteLn(s+':');
                  AsmWrite(#9'.size'#9);
                  if (target_info.system = system_powerpc64_linux) and (tai_symbol_end(hp).sym.typ = AT_FUNCTION) then
                    AsmWrite('.');
                  AsmWrite(tai_symbol_end(hp).sym.name);
                  AsmWrite(', '+s+' - ');
                  if (target_info.system = system_powerpc64_linux) and (tai_symbol_end(hp).sym.typ = AT_FUNCTION) then
                     AsmWrite('.');
                  AsmWriteLn(tai_symbol_end(hp).sym.name);
                end;
             end;

           ait_instruction :
             begin
               WriteInstruction(hp);
             end;

           ait_stab :
             begin
               if assigned(tai_stab(hp).str) then
                 begin
                   AsmWrite(#9'.'+stabtypestr[tai_stab(hp).stabtype]+' ');
                   AsmWritePChar(tai_stab(hp).str);
                   AsmLn;
                 end;
             end;

           ait_file :
             begin
               tai_file(hp).idx:=nextdwarffileidx;
               inc(nextdwarffileidx);
               AsmWrite(#9'.file '+tostr(tai_file(hp).idx)+' "');

               AsmWritePChar(tai_file(hp).str);
               AsmWrite('"');
               AsmLn;
             end;

           ait_loc :
             begin
               AsmWrite(#9'.loc '+tostr(tai_loc(hp).fileentry.idx)+' '+tostr(tai_loc(hp).line)+' '+tostr(tai_loc(hp).column));
               AsmLn;
             end;

           ait_force_line,
           ait_function_name : ;

           ait_cutobject :
             begin
               if SmartAsm then
                begin
                { only reset buffer if nothing has changed }
                  if AsmSize=AsmStartSize then
                   AsmClear
                  else
                   begin
                     AsmClose;
                     DoAssemble;
                     AsmCreate(tai_cutobject(hp).place);
                   end;
                { avoid empty files }
                  while assigned(hp.next) and (tai(hp.next).typ in [ait_cutobject,ait_section,ait_comment]) do
                   begin
                     if tai(hp.next).typ=ait_section then
                       CurrSecType:=tai_section(hp.next).sectype;
                     hp:=tai(hp.next);
                   end;
                  if CurrSecType<>sec_none then
                    WriteSection(CurrSecType,'');
                  AsmStartSize:=AsmSize;

                  { reset dwarf file index }
                  nextdwarffileidx:=1;
                end;
             end;

           ait_marker :
             if tai_marker(hp).kind=InlineStart then
               inc(InlineLevel)
             else if tai_marker(hp).kind=InlineEnd then
               dec(InlineLevel);

           ait_directive :
             begin
               AsmWrite('.'+directivestr[tai_directive(hp).directive]+' ');
               if assigned(tai_directive(hp).name) then
                 AsmWrite(tai_directive(hp).name^);
               AsmLn;
             end;

           else
             internalerror(2006012201);
         end;
         hp:=tai(hp.next);
       end;
    end;


    procedure TGNUAssembler.WriteExtraHeader;

      begin
      end;

    procedure TGNUAssembler.WriteAsmList;
    var
      p:dirstr;
      n:namestr;
      e:extstr;
      hal : tasmlist;
    begin
{$ifdef EXTDEBUG}
      if assigned(current_module.mainsource) then
       Comment(V_Debug,'Start writing gas-styled assembler output for '+current_module.mainsource^);
{$endif}

      CurrSecType:=sec_none;
      FillChar(lastfileinfo,sizeof(lastfileinfo),0);
      LastInfile:=nil;

      if assigned(current_module.mainsource) then
{$IFDEF USE_SYSUTILS}
      begin
       p := SplitPath(current_module.mainsource^);
       n := SplitName(current_module.mainsource^);
       e := SplitExtension(current_module.mainsource^);
      end
{$ELSE USE_SYSUTILS}
       fsplit(current_module.mainsource^,p,n,e)
{$ENDIF USE_SYSUTILS}
      else
       begin
         p:=inputdir;
         n:=inputfile;
         e:=inputextension;
       end;
    { to get symify to work }
      AsmWriteLn(#9'.file "'+FixFileName(n+e)+'"');
      WriteExtraHeader;
      AsmStartSize:=AsmSize;
      symendcount:=0;

      for hal:=low(Tasmlist) to high(Tasmlist) do
        begin
          AsmWriteLn(target_asm.comment+'Begin asmlist '+TasmlistStr[hal]);
          writetree(asmlist[hal]);
          AsmWriteLn(target_asm.comment+'End asmlist '+TasmlistStr[hal]);
        end;

      AsmLn;
{$ifdef EXTDEBUG}
      if assigned(current_module.mainsource) then
       Comment(V_Debug,'Done writing gas-styled assembler output for '+current_module.mainsource^);
{$endif EXTDEBUG}
    end;

end.
