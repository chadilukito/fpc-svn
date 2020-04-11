{

    Copyright (c) 2008 by Florian Klaempfl
    Member of the Free Pascal development team

    This unit implements the code generator for the Z80

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
unit cgcpu;

{$i fpcdefs.inc}

  interface

    uses
       globtype,symtype,symdef,
       cgbase,cgutils,cgobj,
       aasmbase,aasmcpu,aasmtai,aasmdata,
       parabase,
       cpubase,cpuinfo,node,cg64f32,rgcpu;

    type

      { tcgz80 }

      tcgz80 = class(tcg)
        { true, if the next arithmetic operation should modify the flags }
        cgsetflags : boolean;
        procedure init_register_allocators;override;
        procedure done_register_allocators;override;

        function getaddressregister(list:TAsmList):TRegister;override;

        function GetOffsetReg64(const r,rhi: TRegister;ofs : shortint): TRegister;override;

        procedure a_load_const_cgpara(list : TAsmList;size : tcgsize;a : tcgint;const paraloc : TCGPara);override;
        procedure a_load_ref_cgpara(list : TAsmList;size : tcgsize;const r : treference;const cgpara : TCGPara);override;
        procedure a_loadaddr_ref_cgpara(list : TAsmList;const r : treference;const paraloc : TCGPara);override;
        procedure a_load_reg_cgpara(list : TAsmList; size : tcgsize;r : tregister; const cgpara : tcgpara);override;

        procedure a_call_name(list : TAsmList;const s : string; weak: boolean);override;
        procedure a_call_reg(list : TAsmList;reg: tregister);override;

        procedure a_op_const_reg(list : TAsmList; Op: TOpCG; size: TCGSize; a: tcgint; reg: TRegister); override;
        procedure a_op_reg_reg(list: TAsmList; Op: TOpCG; size: TCGSize; src, dst : TRegister); override;

        { move instructions }
        procedure a_load_const_reg(list : TAsmList; size: tcgsize; a : tcgint;reg : tregister);override;
        procedure a_load_const_ref(list : TAsmList;size : tcgsize;a : tcgint;const ref : treference);override;
        procedure a_load_reg_ref(list : TAsmList; fromsize, tosize: tcgsize; reg : tregister;const ref : treference);override;
        procedure a_load_ref_reg(list : TAsmList; fromsize, tosize : tcgsize;const Ref : treference;reg : tregister);override;
        procedure a_load_reg_reg(list : TAsmList; fromsize, tosize : tcgsize;reg1,reg2 : tregister);override;

        { fpu move instructions }
        procedure a_loadfpu_reg_reg(list: TAsmList; fromsize, tosize: tcgsize; reg1, reg2: tregister); override;
        procedure a_loadfpu_ref_reg(list: TAsmList; fromsize, tosize: tcgsize; const ref: treference; reg: tregister); override;
        procedure a_loadfpu_reg_ref(list: TAsmList; fromsize, tosize: tcgsize; reg: tregister; const ref: treference); override;

        {  comparison operations }
        procedure a_cmp_const_reg_label(list : TAsmList;size : tcgsize;cmp_op : topcmp;a : tcgint;reg : tregister;
          l : tasmlabel);override;
        procedure a_cmp_reg_reg_label(list : TAsmList;size : tcgsize;cmp_op : topcmp;reg1,reg2 : tregister;l : tasmlabel); override;

        procedure a_jmp_name(list : TAsmList;const s : string); override;
        procedure a_jmp_always(list : TAsmList;l: tasmlabel); override;
        procedure a_jmp_flags(list : TAsmList;const f : TResFlags;l: tasmlabel); override;

        procedure g_flags2reg(list: TAsmList; size: TCgSize; const f: TResFlags; reg: TRegister); override;

        procedure g_stackpointer_alloc(list : TAsmList;localsize : longint);override;
        procedure g_proc_entry(list : TAsmList;localsize : longint;nostackframe:boolean);override;
        procedure g_proc_exit(list : TAsmList;parasize : longint;nostackframe:boolean); override;

        procedure a_loadaddr_ref_reg(list : TAsmList;const ref : treference;r : tregister);override;

        procedure g_concatcopy(list : TAsmList;const source,dest : treference;len : tcgint);override;
        procedure g_concatcopy_move(list : TAsmList;const source,dest : treference;len : tcgint);

        procedure g_overflowcheck(list: TAsmList; const l: tlocation; def: tdef); override;

        procedure g_save_registers(list : TAsmList);override;
        procedure g_restore_registers(list : TAsmList);override;

        procedure a_jmp_cond(list : TAsmList;cond : TOpCmp;l: tasmlabel);
        procedure fixref(list : TAsmList;var ref : treference);
        function normalize_ref(list : TAsmList;ref : treference;
          tmpreg : tregister) : treference;

        procedure emit_mov(list: TAsmList;reg2: tregister; reg1: tregister);

        procedure a_adjust_sp(list: TAsmList; value: longint);

        procedure make_simple_ref(list:TAsmList;var ref: treference);

      protected
        procedure a_op_reg_reg_internal(list: TAsmList; Op: TOpCG; size: TCGSize; src, srchi, dst, dsthi: TRegister);
        procedure a_op_const_reg_internal(list : TAsmList; Op: TOpCG; size: TCGSize; a: tcgint; reg, reghi: TRegister);
        procedure maybegetcpuregister(list : tasmlist; reg : tregister);
      end;

      tcg64fz80 = class(tcg64f32)
        procedure a_op64_reg_reg(list : TAsmList;op:TOpCG;size : tcgsize;regsrc,regdst : tregister64);override;
        procedure a_op64_const_reg(list : TAsmList;op:TOpCG;size : tcgsize;value : int64;reg : tregister64);override;
      end;

    function GetByteLoc(const loc : tlocation;nr :  byte) : tlocation;

    procedure create_codegen;

    const
      TOpCG2AsmOp: Array[topcg] of TAsmOp = (A_NONE,A_LD,A_ADD,A_AND,A_NONE,
                            A_NONE,A_NONE,A_NONE,A_NEG,A_CPL,A_OR,
                            A_SRA,A_SLA,A_SRL,A_SUB,A_XOR,A_RLCA,A_RRCA);
  implementation

    uses
       globals,verbose,systems,cutils,
       fmodule,
       symconst,symsym,symtable,
       tgobj,rgobj,
       procinfo,cpupi,
       paramgr;


    function use_push(const cgpara:tcgpara):boolean;
      begin
        result:=(not paramanager.use_fixed_stack) and
                assigned(cgpara.location) and
                (cgpara.location^.loc=LOC_REFERENCE) and
                (cgpara.location^.reference.index=NR_STACK_POINTER_REG);
      end;


    procedure tcgz80.init_register_allocators;
      begin
        inherited init_register_allocators;
        rg[R_INTREGISTER]:=trgintcpu.create(R_INTREGISTER,R_SUBWHOLE,
            [RS_A,RS_B,RS_C,RS_D,RS_E,RS_H,RS_L],first_int_imreg,[]);
      end;


    procedure tcgz80.done_register_allocators;
      begin
        rg[R_INTREGISTER].free;
        // rg[R_ADDRESSREGISTER].free;
        inherited done_register_allocators;
      end;


    function tcgz80.getaddressregister(list: TAsmList): TRegister;
      begin
       Result:=getintregister(list,OS_ADDR);
      end;


    function tcgz80.GetOffsetReg64(const r, rhi: TRegister; ofs: shortint): TRegister;
      var
        i: Integer;
      begin
        if ofs>=4 then
          begin
            result:=rhi;
            dec(ofs,4);
          end
        else
          result:=r;
        for i:=1 to ofs do
          result:=GetNextReg(result);
      end;


    procedure tcgz80.a_load_reg_cgpara(list : TAsmList;size : tcgsize;r : tregister;const cgpara : tcgpara);

      procedure load_para_loc(r : TRegister;paraloc : PCGParaLocation);
        var
          ref : treference;
        begin
          paramanager.allocparaloc(list,paraloc);
          case paraloc^.loc of
             LOC_REGISTER,LOC_CREGISTER:
               a_load_reg_reg(list,paraloc^.size,paraloc^.size,r,paraloc^.register);
             LOC_REFERENCE,LOC_CREFERENCE:
               begin
                  reference_reset_base(ref,paraloc^.reference.index,paraloc^.reference.offset,ctempposinvalid,2,[]);
                  a_load_reg_ref(list,paraloc^.size,paraloc^.size,r,ref);
               end;
             else
               internalerror(2002071004);
          end;
        end;

      var
        i, i2 : longint;
        hp : PCGParaLocation;

      begin
        if use_push(cgpara) then
          begin
            case tcgsize2size[cgpara.Size] of
              1:
                begin
                  cgpara.check_simple_location;
                  getcpuregister(list,NR_A);
                  a_load_reg_reg(list,OS_8,OS_8,r,NR_A);
                  list.concat(taicpu.op_reg(A_PUSH,NR_AF));
                  list.concat(taicpu.op_reg(A_INC,NR_SP));
                  ungetcpuregister(list,NR_A);
                end;
              else
                internalerror(2020040801);
            end;
{            if tcgsize2size[cgpara.Size] > 2 then
              begin
                if tcgsize2size[cgpara.Size] <> 4 then
                  internalerror(2013031101);
                if cgpara.location^.Next = nil then
                  begin
                    if tcgsize2size[cgpara.location^.size] <> 4 then
                      internalerror(2013031101);
                  end
                else
                  begin
                    if tcgsize2size[cgpara.location^.size] <> 2 then
                      internalerror(2013031101);
                    if tcgsize2size[cgpara.location^.Next^.size] <> 2 then
                      internalerror(2013031101);
                    if cgpara.location^.Next^.Next <> nil then
                      internalerror(2013031101);
                  end;

                if tcgsize2size[cgpara.size]>cgpara.alignment then
                  pushsize:=cgpara.size
                else
                  pushsize:=int_cgsize(cgpara.alignment);
                pushsize2 := int_cgsize(tcgsize2size[pushsize] - 2);
                list.concat(taicpu.op_reg(A_PUSH,TCgsize2opsize[pushsize2],makeregsize(list,GetNextReg(r),pushsize2)));
                list.concat(taicpu.op_reg(A_PUSH,S_W,makeregsize(list,r,OS_16)));
              end
            else
              begin
                cgpara.check_simple_location;
                if tcgsize2size[cgpara.location^.size]>cgpara.alignment then
                  pushsize:=cgpara.location^.size
                else
                  pushsize:=int_cgsize(cgpara.alignment);
                list.concat(taicpu.op_reg(A_PUSH,TCgsize2opsize[pushsize],makeregsize(list,r,pushsize)));
              end;}

          end
        else
          begin
            if not(tcgsize2size[cgpara.Size] in [1..4]) then
              internalerror(2014011101);

            hp:=cgpara.location;

            i:=0;
            while i<tcgsize2size[cgpara.Size] do
              begin
                if not(assigned(hp)) then
                  internalerror(2014011102);

                inc(i, tcgsize2size[hp^.Size]);

                if hp^.Loc=LOC_REGISTER then
                  begin
                    load_para_loc(r,hp);
                    hp:=hp^.Next;
                    r:=GetNextReg(r);
                  end
                else
                  begin
                    load_para_loc(r,hp);

                    for i2:=1 to tcgsize2size[hp^.Size] do
                      r:=GetNextReg(r);

                    hp:=hp^.Next;
                  end;
              end;
            if assigned(hp) then
              internalerror(2014011103);
          end;
      end;


    procedure tcgz80.a_load_const_cgpara(list : TAsmList;size : tcgsize;a : tcgint;const paraloc : TCGPara);
      var
        i : longint;
        hp : PCGParaLocation;
        ref: treference;
      begin
        if not(tcgsize2size[paraloc.Size] in [1..4]) then
          internalerror(2014011101);

        if use_push(paraloc) then
          begin
            case tcgsize2size[paraloc.Size] of
               1:
                 begin
                   getcpuregister(list,NR_A);
                   a_load_const_reg(list,OS_8,a,NR_A);
                   list.Concat(taicpu.op_reg(A_PUSH,NR_AF));
                   list.Concat(taicpu.op_reg(A_INC,NR_SP));
                   ungetcpuregister(list,NR_A);
                 end;
               2:
                 begin
                   getcpuregister(list,NR_IY);
                   list.Concat(taicpu.op_reg_const(A_LD,NR_IY,a));
                   list.Concat(taicpu.op_reg(A_PUSH,NR_IY));
                   ungetcpuregister(list,NR_IY);
                 end;
               4:
                 begin
                   getcpuregister(list,NR_IY);
                   list.Concat(taicpu.op_reg_const(A_LD,NR_IY,Word(a shr 16)));
                   list.Concat(taicpu.op_reg(A_PUSH,NR_IY));
                   list.Concat(taicpu.op_reg_const(A_LD,NR_IY,Word(a)));
                   list.Concat(taicpu.op_reg(A_PUSH,NR_IY));
                   ungetcpuregister(list,NR_IY);
                 end;
               else
                 internalerror(2020040701);
            end;
          end
        else
          begin
            hp:=paraloc.location;

            i:=1;
            while i<=tcgsize2size[paraloc.Size] do
              begin
                if not(assigned(hp)) then
                  internalerror(2014011105);
                 //paramanager.allocparaloc(list,hp);
                 case hp^.loc of
                   LOC_REGISTER,LOC_CREGISTER:
                     begin
                       if (tcgsize2size[hp^.size]<>1) or
                         (hp^.shiftval<>0) then
                         internalerror(2015041101);
                       a_load_const_reg(list,hp^.size,(a shr (8*(i-1))) and $ff,hp^.register);

                       inc(i,tcgsize2size[hp^.size]);
                       hp:=hp^.Next;
                     end;
                   LOC_REFERENCE,LOC_CREFERENCE:
                     begin
                       reference_reset(ref,paraloc.alignment,[]);
                       ref.base:=hp^.reference.index;
                       ref.offset:=hp^.reference.offset;
                       a_load_const_ref(list,hp^.size,a shr (8*(i-1)),ref);

                       inc(i,tcgsize2size[hp^.size]);
                       hp:=hp^.Next;
                     end;
                   else
                     internalerror(2002071004);
                end;
              end;
          end;
      end;


    procedure tcgz80.a_load_ref_cgpara(list : TAsmList;size : tcgsize;const r : treference;const cgpara : TCGPara);

        procedure pushdata(paraloc:pcgparalocation;ofs:tcgint);
        var
          pushsize : tcgsize;
          opsize : topsize;
          tmpreg   : tregister;
          href,tmpref: treference;
        begin
          if not assigned(paraloc) then
            exit;
          if (paraloc^.loc<>LOC_REFERENCE) or
             (paraloc^.reference.index<>NR_STACK_POINTER_REG) or
             (tcgsize2size[paraloc^.size]>4) then
            internalerror(200501162);
          { Pushes are needed in reverse order, add the size of the
            current location to the offset where to load from. This
            prevents wrong calculations for the last location when
            the size is not a power of 2 }
          if assigned(paraloc^.next) then
            pushdata(paraloc^.next,ofs+tcgsize2size[paraloc^.size]);
          { Push the data starting at ofs }
          href:=r;
          inc(href.offset,ofs);
          {if tcgsize2size[paraloc^.size]>cgpara.alignment then}
            pushsize:=paraloc^.size
          {else
            pushsize:=int_cgsize(cgpara.alignment)};
          {Writeln(pushsize);}
          case tcgsize2size[pushsize] of
            1:
              begin
                tmpreg:=getintregister(list,OS_8);
                a_load_ref_reg(list,paraloc^.size,pushsize,href,tmpreg);
                getcpuregister(list,NR_A);
                a_load_reg_reg(list,OS_8,OS_8,tmpreg,NR_A);
                list.concat(taicpu.op_reg(A_PUSH,NR_AF));
                list.concat(taicpu.op_reg(A_INC,NR_SP));
                ungetcpuregister(list,NR_A);
              end;
            else
              internalerror(2020040803);
          end;
          //if tcgsize2size[paraloc^.size]<cgpara.alignment then
          //  begin
          //    tmpreg:=getintregister(list,pushsize);
          //    a_load_ref_reg(list,paraloc^.size,pushsize,href,tmpreg);
          //    list.concat(taicpu.op_reg(A_PUSH,opsize,tmpreg));
          //  end
          //else
          //  begin
          //    make_simple_ref(list,href);
          //    if tcgsize2size[pushsize] > 2 then
          //      begin
          //        tmpref := href;
          //        Inc(tmpref.offset, 2);
          //        list.concat(taicpu.op_ref(A_PUSH,TCgsize2opsize[int_cgsize(tcgsize2size[pushsize]-2)],tmpref));
          //      end;
          //    list.concat(taicpu.op_ref(A_PUSH,opsize,href));
          //  end;
        end;

      var
        tmpref, ref: treference;
        location: pcgparalocation;
        sizeleft: tcgint;
      begin
        { cgpara.size=OS_NO requires a copy on the stack }
        if use_push(cgpara) then
          begin
            { Record copy? }
            if (cgpara.size in [OS_NO,OS_F64]) or (size=OS_NO) then
              begin
                internalerror(2020040802);
                //cgpara.check_simple_location;
                //len:=align(cgpara.intsize,cgpara.alignment);
                //g_stackpointer_alloc(list,len);
                //reference_reset_base(href,NR_STACK_POINTER_REG,0,ctempposinvalid,4,[]);
                //g_concatcopy(list,r,href,len);
              end
            else
              begin
                if tcgsize2size[cgpara.size]<>tcgsize2size[size] then
                  internalerror(200501161);
                { We need to push the data in reverse order,
                  therefor we use a recursive algorithm }
                pushdata(cgpara.location,0);
              end
          end
        else
          begin
            location := cgpara.location;
            tmpref := r;
            sizeleft := cgpara.intsize;
            while assigned(location) do
              begin
                paramanager.allocparaloc(list,location);
                case location^.loc of
                  LOC_REGISTER,LOC_CREGISTER:
                    a_load_ref_reg(list,location^.size,location^.size,tmpref,location^.register);
                  LOC_REFERENCE:
                    begin
                      reference_reset_base(ref,location^.reference.index,location^.reference.offset,ctempposinvalid,cgpara.alignment,[]);
                      { doubles in softemu mode have a strange order of registers and references }
                      if location^.size=OS_32 then
                        g_concatcopy(list,tmpref,ref,4)
                      else
                        begin
                          g_concatcopy(list,tmpref,ref,sizeleft);
                          if assigned(location^.next) then
                            internalerror(2005010710);
                        end;
                    end;
                  LOC_VOID:
                    begin
                      // nothing to do
                    end;
                  else
                    internalerror(2002081103);
                end;
                inc(tmpref.offset,tcgsize2size[location^.size]);
                dec(sizeleft,tcgsize2size[location^.size]);
                location := location^.next;
              end;
          end;
      end;


    procedure tcgz80.a_loadaddr_ref_cgpara(list : TAsmList;const r : treference;const paraloc : TCGPara);
      var
        tmpreg: tregister;
      begin
        tmpreg:=getaddressregister(list);
        a_loadaddr_ref_reg(list,r,tmpreg);
        a_load_reg_cgpara(list,OS_ADDR,tmpreg,paraloc);
      end;


    procedure tcgz80.a_call_name(list : TAsmList;const s : string; weak: boolean);
      var
        sym: TAsmSymbol;
      begin
        if weak then
          sym:=current_asmdata.WeakRefAsmSymbol(s,AT_FUNCTION)
        else
          sym:=current_asmdata.RefAsmSymbol(s,AT_FUNCTION);

        list.concat(taicpu.op_sym(A_CALL,sym));

        include(current_procinfo.flags,pi_do_call);
      end;


    procedure tcgz80.a_call_reg(list : TAsmList;reg: tregister);
      var
        l : TAsmLabel;
        ref : treference;
      begin
        current_asmdata.getjumplabel(l);
        reference_reset(ref,0,[]);
        ref.symbol:=l;
        list.concat(taicpu.op_ref_reg(A_LD,ref,reg));
        list.concat(tai_const.Create_8bit($CD));
        list.concat(tai_label.Create(l));
        include(current_procinfo.flags,pi_do_call);
      end;


     procedure tcgz80.a_op_const_reg(list : TAsmList; Op: TOpCG; size: TCGSize; a: tcgint; reg: TRegister);
       begin
         if not(size in [OS_S8,OS_8,OS_S16,OS_16,OS_S32,OS_32]) then
           internalerror(2012102403);
         a_op_const_reg_internal(list,Op,size,a,reg,NR_NO);
       end;


     procedure tcgz80.a_op_reg_reg(list: TAsmList; Op: TOpCG; size: TCGSize; src, dst : TRegister);
       begin
         if not(size in [OS_S8,OS_8,OS_S16,OS_16,OS_S32,OS_32]) then
           internalerror(2012102401);
         a_op_reg_reg_internal(list,Op,size,src,NR_NO,dst,NR_NO);
       end;


     procedure tcgz80.a_op_reg_reg_internal(list : TAsmList; Op: TOpCG; size: TCGSize; src, srchi, dst, dsthi: TRegister);
       var
         i : integer;

       procedure NextSrcDst;
         begin
           if i=5 then
             begin
               dst:=dsthi;
               src:=srchi;
             end
           else
             begin
               dst:=GetNextReg(dst);
               src:=GetNextReg(src);
             end;
         end;

       var
         tmpreg,tmpreg2: tregister;
         instr : taicpu;
         l1,l2 : tasmlabel;

      begin
         case op of
           OP_ADD:
             begin
               getcpuregister(list,NR_A);
               a_load_reg_reg(list,OS_8,OS_8,dst,NR_A);
               list.concat(taicpu.op_reg_reg(A_ADD,NR_A,src));
               a_load_reg_reg(list,OS_8,OS_8,NR_A,dst);
               if size in [OS_S16,OS_16,OS_S32,OS_32,OS_S64,OS_64] then
                 begin
                   for i:=2 to tcgsize2size[size] do
                     begin
                       NextSrcDst;
                       a_load_reg_reg(list,OS_8,OS_8,dst,NR_A);
                       list.concat(taicpu.op_reg_reg(A_ADC,NR_A,src));
                       a_load_reg_reg(list,OS_8,OS_8,NR_A,dst);
                     end;
                 end;
               ungetcpuregister(list,NR_A);
             end;

           OP_SUB:
             begin
               getcpuregister(list,NR_A);
               a_load_reg_reg(list,OS_8,OS_8,dst,NR_A);
               list.concat(taicpu.op_reg_reg(A_SUB,NR_A,src));
               a_load_reg_reg(list,OS_8,OS_8,NR_A,dst);
               if size in [OS_S16,OS_16,OS_S32,OS_32,OS_S64,OS_64] then
                 begin
                   for i:=2 to tcgsize2size[size] do
                     begin
                       NextSrcDst;
                       a_load_reg_reg(list,OS_8,OS_8,dst,NR_A);
                       list.concat(taicpu.op_reg_reg(A_SBC,NR_A,src));
                       a_load_reg_reg(list,OS_8,OS_8,NR_A,dst);
                     end;
                 end;
               ungetcpuregister(list,NR_A);
             end;

           OP_NEG:
             begin
               getcpuregister(list,NR_A);
               if tcgsize2size[size]>=2 then
                 begin
                   tmpreg:=GetNextReg(src);
                   tmpreg2:=GetNextReg(dst);
                   for i:=2 to tcgsize2size[size] do
                     begin
                       a_load_reg_reg(list,OS_8,OS_8,tmpreg,NR_A);
                       list.concat(taicpu.op_none(A_CPL));
                       a_load_reg_reg(list,OS_8,OS_8,NR_A,tmpreg2);
                       if i<>tcgsize2size[size] then
                         begin
                           if i=5 then
                             begin
                               tmpreg:=srchi;
                               tmpreg2:=dsthi;
                             end
                           else
                             begin
                               tmpreg:=GetNextReg(tmpreg);
                               tmpreg2:=GetNextReg(tmpreg2);
                             end;
                         end;
                     end;
                 end;
               a_load_reg_reg(list,OS_8,OS_8,src,NR_A);
               list.concat(taicpu.op_none(A_NEG));
               a_load_reg_reg(list,OS_8,OS_8,NR_A,dst);
               if tcgsize2size[size]>=2 then
                 begin
                   tmpreg2:=GetNextReg(dst);
                   for i:=2 to tcgsize2size[size] do
                     begin
                       a_load_reg_reg(list,OS_8,OS_8,tmpreg2,NR_A);
                       list.concat(taicpu.op_reg_const(A_SBC,NR_A,-1));
                       a_load_reg_reg(list,OS_8,OS_8,NR_A,tmpreg2);
                       if i<>tcgsize2size[size] then
                         begin
                           if i=5 then
                             begin
                               tmpreg2:=dsthi;
                             end
                           else
                             begin
                               tmpreg2:=GetNextReg(tmpreg2);
                             end;
                         end;
                     end;
                 end;
               ungetcpuregister(list,NR_A);
             end;

           OP_NOT:
             begin
               getcpuregister(list,NR_A);
               for i:=1 to tcgsize2size[size] do
                 begin
                   a_load_reg_reg(list,OS_8,OS_8,src,NR_A);
                   list.concat(taicpu.op_none(A_CPL));
                   a_load_reg_reg(list,OS_8,OS_8,NR_A,dst);
                   if i<>tcgsize2size[size] then
                     NextSrcDst;
                 end;
               ungetcpuregister(list,NR_A);
             end;

           OP_MUL,OP_IMUL:
             { special stuff, needs separate handling inside code
               generator                                          }
             internalerror(2017032604);

           OP_DIV,OP_IDIV:
             { special stuff, needs separate handling inside code
               generator                                          }
             internalerror(2017032604);

           OP_SHR,OP_SHL,OP_SAR,OP_ROL,OP_ROR:
             begin
               current_asmdata.getjumplabel(l1);
               current_asmdata.getjumplabel(l2);
               getcpuregister(list,NR_B);
               emit_mov(list,NR_B,src);
               list.concat(taicpu.op_reg(A_INC,NR_B));
               list.concat(taicpu.op_reg(A_DEC,NR_B));
               a_jmp_flags(list,F_E,l2);
               if size in [OS_S16,OS_16,OS_S32,OS_32,OS_S64,OS_64] then
                 case op of
                   OP_ROL:
                     begin
                       list.concat(taicpu.op_reg(A_RRC,GetOffsetReg64(dst,dsthi,tcgsize2size[size]-1)));
                       list.concat(taicpu.op_reg(A_RLC,GetOffsetReg64(dst,dsthi,tcgsize2size[size]-1)));
                     end;
                   OP_ROR:
                     begin
                       list.concat(taicpu.op_reg(A_RLC,dst));
                       list.concat(taicpu.op_reg(A_RRC,dst));
                     end;
                 end;
               cg.a_label(list,l1);
               case op of
                 OP_SHL:
                   list.concat(taicpu.op_reg(A_SLA,dst));
                 OP_SHR:
                   list.concat(taicpu.op_reg(A_SRL,GetOffsetReg64(dst,dsthi,tcgsize2size[size]-1)));
                 OP_SAR:
                   list.concat(taicpu.op_reg(A_SRA,GetOffsetReg64(dst,dsthi,tcgsize2size[size]-1)));
                 OP_ROL:
                   if size in [OS_8,OS_S8] then
                     list.concat(taicpu.op_reg(A_RLC,dst))
                   else
                     list.concat(taicpu.op_reg(A_RL,dst));
                 OP_ROR:
                   if size in [OS_8,OS_S8] then
                     list.concat(taicpu.op_reg(A_RRC,GetOffsetReg64(dst,dsthi,tcgsize2size[size]-1)))
                   else
                     list.concat(taicpu.op_reg(A_RR,GetOffsetReg64(dst,dsthi,tcgsize2size[size]-1)));
                 else
                   internalerror(2020040903);
               end;
               if size in [OS_S16,OS_16,OS_S32,OS_32,OS_S64,OS_64] then
                 begin
                   for i:=2 to tcgsize2size[size] do
                     begin
                       case op of
                         OP_ROR,
                         OP_SHR,
                         OP_SAR:
                           list.concat(taicpu.op_reg(A_RR,GetOffsetReg64(dst,dsthi,tcgsize2size[size]-i)));
                         OP_ROL,
                         OP_SHL:
                           list.concat(taicpu.op_reg(A_RL,GetOffsetReg64(dst,dsthi,i-1)));
                         else
                           internalerror(2020040904);
                       end;
                   end;
                 end;
               instr:=taicpu.op_sym(A_DJNZ,l1);
               instr.is_jmp:=true;
               list.concat(instr);
               ungetcpuregister(list,NR_B);
               cg.a_label(list,l2);
             end;

           OP_AND,OP_OR,OP_XOR:
             begin
               getcpuregister(list,NR_A);
               for i:=1 to tcgsize2size[size] do
                 begin
                   a_load_reg_reg(list,OS_8,OS_8,dst,NR_A);
                   list.concat(taicpu.op_reg_reg(topcg2asmop[op],NR_A,src));
                   a_load_reg_reg(list,OS_8,OS_8,NR_A,dst);
                   if i<>tcgsize2size[size] then
                     NextSrcDst;
                 end;
               ungetcpuregister(list,NR_A);
             end;
           else
             internalerror(2011022004);
         end;
       end;

     procedure tcgz80.a_op_const_reg_internal(list: TAsmList; Op: TOpCG;
      size: TCGSize; a: tcgint; reg, reghi: TRegister);

       var
         i : byte;

      procedure NextReg;
        begin
          if i=4 then
            reg:=reghi
          else
            reg:=GetNextReg(reg);
        end;

      var
        mask : qword;
        shift : byte;
        curvalue : byte;
        tmpop: TAsmOp;
        l1: TAsmLabel;
        instr: taicpu;
        tmpreg : tregister;
        tmpreg64 : tregister64;

       begin
         optimize_op_const(size,op,a);
         mask:=$ff;
         shift:=0;
         case op of
           OP_NONE:
             begin
               { Opcode is optimized away }
             end;
           OP_MOVE:
             begin
               { Optimized, replaced with a simple load }
               a_load_const_reg(list,size,a,reg);
             end;
           OP_AND:
             begin
               curvalue:=a and mask;
               for i:=1 to tcgsize2size[size] do
                 begin
                   case curvalue of
                     0:
                       list.concat(taicpu.op_reg_const(A_LD,reg,0));
                     $ff:
                       {nothing};
                     else
                       begin
                         getcpuregister(list,NR_A);
                         emit_mov(list,NR_A,reg);
                         list.concat(taicpu.op_reg_const(A_AND,NR_A,curvalue));
                         emit_mov(list,reg,NR_A);
                         ungetcpuregister(list,NR_A);
                       end;
                   end;
                   if i<>tcgsize2size[size] then
                     begin
                       NextReg;
                       mask:=mask shl 8;
                       inc(shift,8);
                       curvalue:=(qword(a) and mask) shr shift;
                     end;
                 end;
             end;
           OP_OR:
             begin
               curvalue:=a and mask;
               for i:=1 to tcgsize2size[size] do
                 begin
                   case curvalue of
                     0:
                       {nothing};
                     $ff:
                       list.concat(taicpu.op_reg_const(A_LD,reg,$ff));
                     else
                       begin
                         getcpuregister(list,NR_A);
                         emit_mov(list,NR_A,reg);
                         list.concat(taicpu.op_reg_const(A_OR,NR_A,curvalue));
                         emit_mov(list,reg,NR_A);
                         ungetcpuregister(list,NR_A);
                       end;
                   end;
                   if i<>tcgsize2size[size] then
                     begin
                       NextReg;
                       mask:=mask shl 8;
                       inc(shift,8);
                       curvalue:=(qword(a) and mask) shr shift;
                     end;
                 end;
             end;
           OP_XOR:
             begin
               curvalue:=a and mask;
               for i:=1 to tcgsize2size[size] do
                 begin
                   case curvalue of
                     0:
                       {nothing};
                     $ff:
                       begin
                         getcpuregister(list,NR_A);
                         emit_mov(list,NR_A,reg);
                         list.concat(taicpu.op_none(A_CPL));
                         emit_mov(list,reg,NR_A);
                         ungetcpuregister(list,NR_A);
                       end;
                     else
                       begin
                         getcpuregister(list,NR_A);
                         emit_mov(list,NR_A,reg);
                         list.concat(taicpu.op_reg_const(A_XOR,NR_A,curvalue));
                         emit_mov(list,reg,NR_A);
                         ungetcpuregister(list,NR_A);
                       end;
                   end;
                   if i<>tcgsize2size[size] then
                     begin
                       NextReg;
                       mask:=mask shl 8;
                       inc(shift,8);
                       curvalue:=(qword(a) and mask) shr shift;
                     end;
                 end;
             end;
           OP_SHR,OP_SHL,OP_SAR,OP_ROL,OP_ROR:
             begin
               if size in [OS_64,OS_S64] then
                 a:=a and 63
               else
                 a:=a and 31;
               if a<>0 then
                 begin
                   if a>1 then
                     begin
                       current_asmdata.getjumplabel(l1);
                       getcpuregister(list,NR_B);
                       list.concat(taicpu.op_reg_const(A_LD,NR_B,a));
                     end;
                   if size in [OS_S16,OS_16,OS_S32,OS_32,OS_S64,OS_64] then
                     case op of
                       OP_ROL:
                         begin
                           list.concat(taicpu.op_reg(A_RRC,GetOffsetReg64(reg,reghi,tcgsize2size[size]-1)));
                           list.concat(taicpu.op_reg(A_RLC,GetOffsetReg64(reg,reghi,tcgsize2size[size]-1)));
                         end;
                       OP_ROR:
                         begin
                           list.concat(taicpu.op_reg(A_RLC,reg));
                           list.concat(taicpu.op_reg(A_RRC,reg));
                         end;
                     end;
                   if a>1 then
                     cg.a_label(list,l1);
                   case op of
                     OP_SHL:
                       list.concat(taicpu.op_reg(A_SLA,reg));
                     OP_SHR:
                       list.concat(taicpu.op_reg(A_SRL,GetOffsetReg64(reg,reghi,tcgsize2size[size]-1)));
                     OP_SAR:
                       list.concat(taicpu.op_reg(A_SRA,GetOffsetReg64(reg,reghi,tcgsize2size[size]-1)));
                     OP_ROL:
                       if size in [OS_8,OS_S8] then
                         list.concat(taicpu.op_reg(A_RLC,reg))
                       else
                         list.concat(taicpu.op_reg(A_RL,reg));
                     OP_ROR:
                       if size in [OS_8,OS_S8] then
                         list.concat(taicpu.op_reg(A_RRC,GetOffsetReg64(reg,reghi,tcgsize2size[size]-1)))
                       else
                         list.concat(taicpu.op_reg(A_RR,GetOffsetReg64(reg,reghi,tcgsize2size[size]-1)));
                     else
                       internalerror(2020040903);
                   end;
                   if size in [OS_S16,OS_16,OS_S32,OS_32,OS_S64,OS_64] then
                     begin
                       for i:=2 to tcgsize2size[size] do
                         begin
                           case op of
                             OP_ROR,
                             OP_SHR,
                             OP_SAR:
                               list.concat(taicpu.op_reg(A_RR,GetOffsetReg64(reg,reghi,tcgsize2size[size]-i)));
                             OP_ROL,
                             OP_SHL:
                               list.concat(taicpu.op_reg(A_RL,GetOffsetReg64(reg,reghi,i-1)));
                             else
                               internalerror(2020040904);
                           end;
                       end;
                     end;
                   if a>1 then
                     begin
                       instr:=taicpu.op_sym(A_DJNZ,l1);
                       instr.is_jmp:=true;
                       list.concat(instr);
                       ungetcpuregister(list,NR_B);
                     end;
                 end;
             end;
           OP_ADD:
             begin
               curvalue:=a and mask;
               tmpop:=A_NONE;
               for i:=1 to tcgsize2size[size] do
                 begin
                   if (tmpop=A_NONE) and (curvalue=1) and (i=tcgsize2size[size]) then
                     tmpop:=A_INC
                   else if (tmpop=A_NONE) and (curvalue<>0) then
                     tmpop:=A_ADD
                   else if tmpop=A_ADD then
                     tmpop:=A_ADC;
                   case tmpop of
                     A_NONE:
                       {nothing};
                     A_INC:
                       list.concat(taicpu.op_reg(tmpop,reg));
                     A_ADD,A_ADC:
                       begin
                         getcpuregister(list,NR_A);
                         emit_mov(list,NR_A,reg);
                         list.concat(taicpu.op_reg_const(tmpop,NR_A,curvalue));
                         emit_mov(list,reg,NR_A);
                         ungetcpuregister(list,NR_A);
                       end;
                     else
                       internalerror(2020040901);
                   end;
                   if i<>tcgsize2size[size] then
                     begin
                       NextReg;
                       mask:=mask shl 8;
                       inc(shift,8);
                       curvalue:=(qword(a) and mask) shr shift;
                     end;
                 end;
             end;
           OP_SUB:
             begin
               curvalue:=a and mask;
               tmpop:=A_NONE;
               for i:=1 to tcgsize2size[size] do
                 begin
                   if (tmpop=A_NONE) and (curvalue=1) and (i=tcgsize2size[size]) then
                     tmpop:=A_DEC
                   else if (tmpop=A_NONE) and (curvalue<>0) then
                     tmpop:=A_SUB
                   else if tmpop=A_ADD then
                     tmpop:=A_SBC;
                   case tmpop of
                     A_NONE:
                       {nothing};
                     A_DEC:
                       list.concat(taicpu.op_reg(tmpop,reg));
                     A_SUB,A_SBC:
                       begin
                         getcpuregister(list,NR_A);
                         emit_mov(list,NR_A,reg);
                         list.concat(taicpu.op_reg_const(tmpop,NR_A,curvalue));
                         emit_mov(list,reg,NR_A);
                         ungetcpuregister(list,NR_A);
                       end;
                     else
                       internalerror(2020040902);
                   end;
                   if i<>tcgsize2size[size] then
                     begin
                       NextReg;
                       mask:=mask shl 8;
                       inc(shift,8);
                       curvalue:=(qword(a) and mask) shr shift;
                     end;
                 end;
             end;
         else
           begin
             if size in [OS_64,OS_S64] then
               begin
                 tmpreg64.reglo:=getintregister(list,OS_32);
                 tmpreg64.reghi:=getintregister(list,OS_32);
                 cg64.a_load64_const_reg(list,a,tmpreg64);
                 cg64.a_op64_reg_reg(list,op,size,tmpreg64,joinreg64(reg,reghi));
               end
             else
               begin
{$if 0}
                 { code not working yet }
                 if (op=OP_SAR) and (a=31) and (size in [OS_32,OS_S32]) then
                   begin
                     tmpreg:=reg;
                     for i:=1 to 4 do
                       begin
                         list.concat(taicpu.op_reg_reg(A_MOV,tmpreg,NR_R1));
                         tmpreg:=GetNextReg(tmpreg);
                       end;
                   end
                 else
{$endif}
                   begin
                     tmpreg:=getintregister(list,size);
                     a_load_const_reg(list,size,a,tmpreg);
                     a_op_reg_reg(list,op,size,tmpreg,reg);
                   end;
               end;
           end;
       end;
     end;


     procedure tcgz80.a_load_const_reg(list : TAsmList; size: tcgsize; a : tcgint;reg : tregister);
       var
         mask : qword;
         shift : byte;
         i : byte;
       begin
         mask:=$ff;
         shift:=0;
         for i:=tcgsize2size[size] downto 1 do
           begin
             list.Concat(taicpu.op_reg_const(A_LD,reg,(qword(a) and mask) shr shift));
             if i<>1 then
               begin
                 mask:=mask shl 8;
                 inc(shift,8);
                 reg:=GetNextReg(reg);
               end;
           end;
       end;


     procedure tcgz80.a_load_const_ref(list: TAsmList; size: tcgsize; a: tcgint; const ref: treference);
       var
         mask : qword;
         shift : byte;
         href: treference;
         i: Integer;
       begin
         mask:=$ff;
         shift:=0;
         href:=ref;
         if (href.base=NR_NO) and (href.index<>NR_NO) then
           begin
             href.base:=href.index;
             href.index:=NR_NO;
           end;
         if not assigned(href.symbol) and
           ((href.base=NR_IX) or (href.base=NR_IY) or
            ((href.base=NR_HL) and (size in [OS_8,OS_S8]) and (href.offset=0))) then
           begin
             for i:=tcgsize2size[size] downto 1 do
               begin
                 list.Concat(taicpu.op_ref_const(A_LD,href,(qword(a) and mask) shr shift));
                 if i<>1 then
                   begin
                     mask:=mask shl 8;
                     inc(shift,8);
                     inc(href.offset);
                   end;
               end;
           end
         else
           inherited;
       end;


    procedure tcgz80.maybegetcpuregister(list:tasmlist;reg : tregister);
      begin
        { allocate the register only, if a cpu register is passed }
        if getsupreg(reg)<first_int_imreg then
          getcpuregister(list,reg);
      end;


    function tcgz80.normalize_ref(list:TAsmList;ref: treference;tmpreg : tregister) : treference;

      var
        tmpref : treference;
        l : tasmlabel;
      begin
        Result:=ref;
//
//         if ref.addressmode<>AM_UNCHANGED then
//           internalerror(2011021701);
//
//        { Be sure to have a base register }
//        if (ref.base=NR_NO) then
//          begin
//            { only symbol+offset? }
//            if ref.index=NR_NO then
//              exit;
//            ref.base:=ref.index;
//            ref.index:=NR_NO;
//          end;
//
//        { can we take advantage of adiw/sbiw? }
//        if (current_settings.cputype>=cpu_avr2) and not(assigned(ref.symbol)) and (ref.offset<>0) and (ref.offset>=-63) and (ref.offset<=63) and
//          ((tmpreg=NR_R24) or (tmpreg=NR_R26) or (tmpreg=NR_R28) or (tmpreg=NR_R30)) and (ref.base<>NR_NO) then
//          begin
//            maybegetcpuregister(list,tmpreg);
//            emit_mov(list,tmpreg,ref.base);
//            maybegetcpuregister(list,GetNextReg(tmpreg));
//            emit_mov(list,GetNextReg(tmpreg),GetNextReg(ref.base));
//            if ref.index<>NR_NO then
//              begin
//                list.concat(taicpu.op_reg_reg(A_ADD,tmpreg,ref.index));
//                list.concat(taicpu.op_reg_reg(A_ADC,GetNextReg(tmpreg),GetNextReg(ref.index)));
//              end;
//            if ref.offset>0 then
//              list.concat(taicpu.op_reg_const(A_ADIW,tmpreg,ref.offset))
//            else
//              list.concat(taicpu.op_reg_const(A_SBIW,tmpreg,-ref.offset));
//            ref.offset:=0;
//            ref.base:=tmpreg;
//            ref.index:=NR_NO;
//          end
//        else if assigned(ref.symbol) or (ref.offset<>0) then
//          begin
//            reference_reset(tmpref,0,[]);
//            tmpref.symbol:=ref.symbol;
//            tmpref.offset:=ref.offset;
//            if assigned(ref.symbol) and (ref.symbol.typ in [AT_FUNCTION,AT_LABEL]) then
//              tmpref.refaddr:=addr_lo8_gs
//            else
//              tmpref.refaddr:=addr_lo8;
//            maybegetcpuregister(list,tmpreg);
//            list.concat(taicpu.op_reg_ref(A_LDI,tmpreg,tmpref));
//
//            if assigned(ref.symbol) and (ref.symbol.typ in [AT_FUNCTION,AT_LABEL]) then
//              tmpref.refaddr:=addr_hi8_gs
//            else
//              tmpref.refaddr:=addr_hi8;
//            maybegetcpuregister(list,GetNextReg(tmpreg));
//            list.concat(taicpu.op_reg_ref(A_LDI,GetNextReg(tmpreg),tmpref));
//
//            if (ref.base<>NR_NO) then
//              begin
//                list.concat(taicpu.op_reg_reg(A_ADD,tmpreg,ref.base));
//                list.concat(taicpu.op_reg_reg(A_ADC,GetNextReg(tmpreg),GetNextReg(ref.base)));
//              end;
//            if (ref.index<>NR_NO) then
//              begin
//                list.concat(taicpu.op_reg_reg(A_ADD,tmpreg,ref.index));
//                list.concat(taicpu.op_reg_reg(A_ADC,GetNextReg(tmpreg),GetNextReg(ref.index)));
//              end;
//            ref.symbol:=nil;
//            ref.offset:=0;
//            ref.base:=tmpreg;
//            ref.index:=NR_NO;
//          end
//        else if (ref.base<>NR_NO) and (ref.index<>NR_NO) then
//          begin
//            maybegetcpuregister(list,tmpreg);
//            emit_mov(list,tmpreg,ref.base);
//            maybegetcpuregister(list,GetNextReg(tmpreg));
//            emit_mov(list,GetNextReg(tmpreg),GetNextReg(ref.base));
//            list.concat(taicpu.op_reg_reg(A_ADD,tmpreg,ref.index));
//            list.concat(taicpu.op_reg_reg(A_ADC,GetNextReg(tmpreg),GetNextReg(ref.index)));
//            ref.base:=tmpreg;
//            ref.index:=NR_NO;
//          end
//        else if (ref.base<>NR_NO) then
//          begin
//            maybegetcpuregister(list,tmpreg);
//            emit_mov(list,tmpreg,ref.base);
//            maybegetcpuregister(list,GetNextReg(tmpreg));
//            emit_mov(list,GetNextReg(tmpreg),GetNextReg(ref.base));
//            ref.base:=tmpreg;
//            ref.index:=NR_NO;
//          end
//        else if (ref.index<>NR_NO) then
//          begin
//            maybegetcpuregister(list,tmpreg);
//            emit_mov(list,tmpreg,ref.index);
//            maybegetcpuregister(list,GetNextReg(tmpreg));
//            emit_mov(list,GetNextReg(tmpreg),GetNextReg(ref.index));
//            ref.base:=tmpreg;
//            ref.index:=NR_NO;
//          end;
        Result:=ref;
      end;


     procedure tcgz80.a_load_reg_ref(list : TAsmList; fromsize, tosize: tcgsize; reg : tregister;const ref : treference);
       var
         href : treference;
         i : integer;
       begin
         href:=Ref;
         { ensure, href.base contains a valid register if there is any register used }
         if href.base=NR_NO then
           begin
             href.base:=href.index;
             href.index:=NR_NO;
           end;

         if (tcgsize2size[fromsize]>32) or (tcgsize2size[tosize]>32) or (fromsize=OS_NO) or (tosize=OS_NO) then
           internalerror(2011021307);
         if tcgsize2size[fromsize]>tcgsize2size[tosize] then
           internalerror(2020040802);

         if (fromsize=tosize) or (fromsize in [OS_8,OS_16,OS_32]) then
           begin
             getcpuregister(list,NR_A);
             for i:=1 to tcgsize2size[fromsize] do
               begin
                 a_load_reg_reg(list,OS_8,OS_8,reg,NR_A);
                 list.concat(taicpu.op_ref_reg(A_LD,href,NR_A));
                 if i<>tcgsize2size[fromsize] then
                   reg:=GetNextReg(reg);
                 if i<>tcgsize2size[tosize] then
                   inc(href.offset);
               end;
             for i:=tcgsize2size[fromsize]+1 to tcgsize2size[tosize] do
               begin
                 if i=(tcgsize2size[fromsize]+1) then
                   list.concat(taicpu.op_reg_const(A_LD,NR_A,0));
                 list.concat(taicpu.op_ref_reg(A_LD,href,NR_A));
                 if i<>tcgsize2size[tosize] then
                   begin
                     inc(href.offset);
                     reg:=GetNextReg(reg);
                   end;
               end;
             ungetcpuregister(list,NR_A);
           end
         else
           begin
             getcpuregister(list,NR_A);
             for i:=1 to tcgsize2size[fromsize] do
               begin
                 a_load_reg_reg(list,OS_8,OS_8,reg,NR_A);
                 list.concat(taicpu.op_ref_reg(A_LD,href,NR_A));
                 if i<>tcgsize2size[fromsize] then
                   reg:=GetNextReg(reg);
                 if i<>tcgsize2size[tosize] then
                   inc(href.offset);
               end;
             list.concat(taicpu.op_none(A_RLA));
             list.concat(taicpu.op_reg_reg(A_SBC,NR_A,NR_A));
             for i:=tcgsize2size[fromsize]+1 to tcgsize2size[tosize] do
               begin
                 list.concat(taicpu.op_ref_reg(A_LD,href,NR_A));
                 if i<>tcgsize2size[tosize] then
                   begin
                     inc(href.offset);
                     reg:=GetNextReg(reg);
                   end;
               end;
             ungetcpuregister(list,NR_A);
           end;
       end;


     procedure tcgz80.a_load_ref_reg(list : TAsmList; fromsize, tosize : tcgsize;
       const Ref : treference;reg : tregister);
       var
         href : treference;
         i : integer;
       begin
         href:=Ref;
         { ensure, href.base contains a valid register if there is any register used }
         if href.base=NR_NO then
           begin
             href.base:=href.index;
             href.index:=NR_NO;
           end;

         if (tcgsize2size[fromsize]>32) or (tcgsize2size[tosize]>32) or (fromsize=OS_NO) or (tosize=OS_NO) then
           internalerror(2011021307);
         if tcgsize2size[fromsize]>tcgsize2size[tosize] then
           internalerror(2020040804);

         if (tosize=fromsize) or (fromsize in [OS_8,OS_16,OS_32]) then
           begin
             getcpuregister(list,NR_A);
             for i:=1 to tcgsize2size[fromsize] do
               begin
                 list.concat(taicpu.op_reg_ref(A_LD,NR_A,href));
                 a_load_reg_reg(list,OS_8,OS_8,NR_A,reg);

                 if i<>tcgsize2size[fromsize] then
                   inc(href.offset);
                 if i<>tcgsize2size[tosize] then
                   reg:=GetNextReg(reg);
               end;
             ungetcpuregister(list,NR_A);
             for i:=tcgsize2size[fromsize]+1 to tcgsize2size[tosize] do
               begin
                 list.concat(taicpu.op_reg_const(A_LD,reg,0));
                 if i<>tcgsize2size[tosize] then
                   reg:=GetNextReg(reg);
               end;
           end
         else
           begin
             getcpuregister(list,NR_A);
             for i:=1 to tcgsize2size[fromsize] do
               begin
                 list.concat(taicpu.op_reg_ref(A_LD,NR_A,href));
                 a_load_reg_reg(list,OS_8,OS_8,NR_A,reg);

                 if i<>tcgsize2size[fromsize] then
                   inc(href.offset);
                 if i<>tcgsize2size[tosize] then
                   reg:=GetNextReg(reg);
               end;
             list.concat(taicpu.op_none(A_RLA));
             list.concat(taicpu.op_reg_reg(A_SBC,NR_A,NR_A));
             for i:=tcgsize2size[fromsize]+1 to tcgsize2size[tosize] do
               begin
                 emit_mov(list,reg,NR_A);
                 if i<>tcgsize2size[tosize] then
                   reg:=GetNextReg(reg);
               end;
             ungetcpuregister(list,NR_A);
           end;
       end;


     procedure tcgz80.a_load_reg_reg(list : TAsmList; fromsize, tosize : tcgsize;reg1,reg2 : tregister);
       var
         conv_done: boolean;
         tmpreg : tregister;
         i : integer;
       begin
         if (tcgsize2size[fromsize]>32) or (tcgsize2size[tosize]>32) or (fromsize=OS_NO) or (tosize=OS_NO) then
           internalerror(2011021310);
         if tcgsize2size[fromsize]>tcgsize2size[tosize] then
           fromsize:=tosize;

         if (tosize=fromsize) or (fromsize in [OS_8,OS_16,OS_32]) then
           begin
             if reg1<>reg2 then
               for i:=1 to tcgsize2size[fromsize] do
                 begin
                   emit_mov(list,reg2,reg1);
                   if i<>tcgsize2size[fromsize] then
                     reg1:=GetNextReg(reg1);
                   if i<>tcgsize2size[tosize] then
                     reg2:=GetNextReg(reg2);
                 end
             else
               for i:=1 to tcgsize2size[fromsize] do
                 if i<>tcgsize2size[tosize] then
                   reg2:=GetNextReg(reg2);
             for i:=tcgsize2size[fromsize]+1 to tcgsize2size[tosize] do
               begin
                 list.Concat(taicpu.op_reg_const(A_LD,reg2,0));
                 if i<>tcgsize2size[tosize] then
                   reg2:=GetNextReg(reg2);
               end
           end
         else
           begin
             if reg1<>reg2 then
               for i:=1 to tcgsize2size[fromsize]-1 do
                 begin
                   emit_mov(list,reg2,reg1);
                   reg1:=GetNextReg(reg1);
                   reg2:=GetNextReg(reg2);
                 end
             else
               for i:=1 to tcgsize2size[fromsize]-1 do
                 reg2:=GetNextReg(reg2);
             emit_mov(list,reg2,reg1);
             getcpuregister(list,NR_A);
             emit_mov(list,NR_A,reg2);
             reg2:=GetNextReg(reg2);
             list.concat(taicpu.op_none(A_RLA));
             list.concat(taicpu.op_reg_reg(A_SBC,NR_A,NR_A));
             for i:=tcgsize2size[fromsize]+1 to tcgsize2size[tosize] do
               begin
                 emit_mov(list,reg2,NR_A);
                 if i<>tcgsize2size[tosize] then
                   reg2:=GetNextReg(reg2);
               end;
             ungetcpuregister(list,NR_A);
           end;
       end;


     procedure tcgz80.a_loadfpu_reg_reg(list: TAsmList; fromsize,tosize: tcgsize; reg1, reg2: tregister);
       begin
         internalerror(2012010702);
       end;


     procedure tcgz80.a_loadfpu_ref_reg(list: TAsmList; fromsize,tosize: tcgsize; const ref: treference; reg: tregister);
       begin
         internalerror(2012010703);
       end;


     procedure tcgz80.a_loadfpu_reg_ref(list: TAsmList; fromsize, tosize: tcgsize; reg: tregister; const ref: treference);
       begin
         internalerror(2012010704);
       end;


    {  comparison operations }
    procedure tcgz80.a_cmp_const_reg_label(list : TAsmList;size : tcgsize;
      cmp_op : topcmp;a : tcgint;reg : tregister;l : tasmlabel);
      var
        swapped : boolean;
        tmpreg : tregister;
        i : byte;
      begin
        list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: a_cmp_const_reg_label')));
        //if a=0 then
        //  begin
        //    swapped:=false;
        //    { swap parameters? }
        //    case cmp_op of
        //      OC_GT:
        //        begin
        //          swapped:=true;
        //          cmp_op:=OC_LT;
        //        end;
        //      OC_LTE:
        //        begin
        //          swapped:=true;
        //          cmp_op:=OC_GTE;
        //        end;
        //      OC_BE:
        //        begin
        //          swapped:=true;
        //          cmp_op:=OC_AE;
        //        end;
        //      OC_A:
        //        begin
        //          swapped:=true;
        //          cmp_op:=OC_B;
        //        end;
        //    end;
        //
        //    if swapped then
        //      list.concat(taicpu.op_reg_reg(A_CP,NR_R1,reg))
        //    else
        //      list.concat(taicpu.op_reg_reg(A_CP,reg,NR_R1));
        //
        //    for i:=2 to tcgsize2size[size] do
        //      begin
        //        reg:=GetNextReg(reg);
        //        if swapped then
        //          list.concat(taicpu.op_reg_reg(A_CPC,NR_R1,reg))
        //        else
        //          list.concat(taicpu.op_reg_reg(A_CPC,reg,NR_R1));
        //      end;
        //
        //    a_jmp_cond(list,cmp_op,l);
        //  end
        //else
        //  inherited a_cmp_const_reg_label(list,size,cmp_op,a,reg,l);
      end;


    procedure tcgz80.a_cmp_reg_reg_label(list : TAsmList;size : tcgsize;
      cmp_op : topcmp;reg1,reg2 : tregister;l : tasmlabel);
      var
        swapped : boolean;
        tmpreg : tregister;
        i : byte;
      begin
        list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: a_cmp_reg_reg_label')));
        //swapped:=false;
        //{ swap parameters? }
        //case cmp_op of
        //  OC_GT:
        //    begin
        //      swapped:=true;
        //      cmp_op:=OC_LT;
        //    end;
        //  OC_LTE:
        //    begin
        //      swapped:=true;
        //      cmp_op:=OC_GTE;
        //    end;
        //  OC_BE:
        //    begin
        //      swapped:=true;
        //      cmp_op:=OC_AE;
        //    end;
        //  OC_A:
        //    begin
        //      swapped:=true;
        //      cmp_op:=OC_B;
        //    end;
        //end;
        //if swapped then
        //  begin
        //    tmpreg:=reg1;
        //    reg1:=reg2;
        //    reg2:=tmpreg;
        //  end;
        //list.concat(taicpu.op_reg_reg(A_CP,reg2,reg1));
        //
        //for i:=2 to tcgsize2size[size] do
        //  begin
        //    reg1:=GetNextReg(reg1);
        //    reg2:=GetNextReg(reg2);
        //    list.concat(taicpu.op_reg_reg(A_CPC,reg2,reg1));
        //  end;
        //
        //a_jmp_cond(list,cmp_op,l);
      end;


    procedure tcgz80.a_jmp_name(list : TAsmList;const s : string);
      var
        ai : taicpu;
      begin
        ai:=taicpu.op_sym(A_JP,current_asmdata.RefAsmSymbol(s,AT_FUNCTION));
        ai.is_jmp:=true;
        list.concat(ai);
      end;


    procedure tcgz80.a_jmp_always(list : TAsmList;l: tasmlabel);
      var
        ai : taicpu;
      begin
        ai:=taicpu.op_sym(A_JP,l);
        ai.is_jmp:=true;
        list.concat(ai);
      end;


    procedure tcgz80.a_jmp_flags(list : TAsmList;const f : TResFlags;l: tasmlabel);
      var
        ai : taicpu;
      begin
        ai:=taicpu.op_cond_sym(A_JP,flags_to_cond(f),l);
        ai.is_jmp:=true;
        list.concat(ai);
      end;


    procedure tcgz80.g_flags2reg(list: TAsmList; size: TCgSize; const f: TResFlags; reg: TRegister);
      var
        l : TAsmLabel;
        tmpflags : TResFlags;
      begin
        list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: g_flags2reg')));
        current_asmdata.getjumplabel(l);
        {
        if flags_to_cond(f) then
          begin
            tmpflags:=f;
            inverse_flags(tmpflags);
            emit_mov(reg,NR_R1);
            a_jmp_flags(list,tmpflags,l);
            list.concat(taicpu.op_reg_const(A_LDI,reg,1));
          end
        else
        }
          begin
            //list.concat(taicpu.op_reg_const(A_LDI,reg,1));
            //a_jmp_flags(list,f,l);
            //emit_mov(list,reg,NR_R1);
          end;
        cg.a_label(list,l);
      end;


    procedure tcgz80.g_stackpointer_alloc(list: TAsmList; localsize: longint);
      begin
        if localsize>0 then
          begin
            list.Concat(taicpu.op_reg_const(A_LD,NR_HL,-localsize));
            list.Concat(taicpu.op_reg_reg(A_ADD,NR_HL,NR_SP));
            list.Concat(taicpu.op_reg_reg(A_LD,NR_SP,NR_HL));
          end;
      end;


    procedure tcgz80.a_adjust_sp(list : TAsmList; value : longint);
      var
        i : integer;
      begin
        //case value of
        //  0:
        //    ;
        //  {-14..-1:
        //    begin
        //      if ((-value) mod 2)<>0 then
        //        list.concat(taicpu.op_reg(A_PUSH,NR_R0));
        //      for i:=1 to (-value) div 2 do
        //        list.concat(taicpu.op_const(A_RCALL,0));
        //    end;
        //  1..7:
        //    begin
        //      for i:=1 to value do
        //        list.concat(taicpu.op_reg(A_POP,NR_R0));
        //    end;}
        //  else
        //    begin
        //      list.concat(taicpu.op_reg_const(A_SUBI,NR_R28,lo(word(-value))));
        //      list.concat(taicpu.op_reg_const(A_SBCI,NR_R29,hi(word(-value))));
        //      // get SREG
        //      list.concat(taicpu.op_reg_const(A_IN,NR_R0,NIO_SREG));
        //
        //      // block interrupts
        //      list.concat(taicpu.op_none(A_CLI));
        //
        //      // write high SP
        //      list.concat(taicpu.op_const_reg(A_OUT,NIO_SP_HI,NR_R29));
        //
        //      // release interrupts
        //      list.concat(taicpu.op_const_reg(A_OUT,NIO_SREG,NR_R0));
        //
        //      // write low SP
        //      list.concat(taicpu.op_const_reg(A_OUT,NIO_SP_LO,NR_R28));
        //    end;
        //end;
      end;


    procedure tcgz80.make_simple_ref(list: TAsmList; var ref: treference);
      begin
      end;


    procedure tcgz80.g_proc_entry(list : TAsmList;localsize : longint;nostackframe:boolean);
      var
        regsize,stackmisalignment: longint;
      begin
        regsize:=0;
        stackmisalignment:=0;
        { save old framepointer }
        if not nostackframe then
          begin
            { return address }
            inc(stackmisalignment,2);
            list.concat(tai_regalloc.alloc(current_procinfo.framepointer,nil));
            if current_procinfo.framepointer=NR_FRAME_POINTER_REG then
              begin
                { push <frame_pointer> }
                inc(stackmisalignment,2);
                include(rg[R_INTREGISTER].preserved_by_proc,RS_FRAME_POINTER_REG);
                list.concat(Taicpu.op_reg(A_PUSH,NR_FRAME_POINTER_REG));
                { Return address and FP are both on stack }
                current_asmdata.asmcfi.cfa_def_cfa_offset(list,2*2);
                current_asmdata.asmcfi.cfa_offset(list,NR_FRAME_POINTER_REG,-(2*2));
                if current_procinfo.procdef.proctypeoption<>potype_exceptfilter then
                  begin
                    list.concat(Taicpu.op_reg_const(A_LD,NR_FRAME_POINTER_REG,0));
                    list.concat(Taicpu.op_reg_reg(A_ADD,NR_FRAME_POINTER_REG,NR_STACK_POINTER_REG))
                  end
                else
                  begin
                    internalerror(2020040301);
                    (*push_regs;
                    gen_load_frame_for_exceptfilter(list);
                    { Need only as much stack space as necessary to do the calls.
                      Exception filters don't have own local vars, and temps are 'mapped'
                      to the parent procedure.
                      maxpushedparasize is already aligned at least on x86_64. }
                    localsize:=current_procinfo.maxpushedparasize;*)
                  end;
                current_asmdata.asmcfi.cfa_def_cfa_register(list,NR_FRAME_POINTER_REG);
              end
            else
              begin
                CGmessage(cg_d_stackframe_omited);
              end;

            { allocate stackframe space }
            if (localsize<>0) or
               ((target_info.stackalign>sizeof(pint)) and
                (stackmisalignment <> 0) and
                ((pi_do_call in current_procinfo.flags) or
                 (po_assembler in current_procinfo.procdef.procoptions))) then
              begin
                if target_info.stackalign>sizeof(pint) then
                  localsize := align(localsize+stackmisalignment,target_info.stackalign)-stackmisalignment;
                g_stackpointer_alloc(list,localsize);
                if current_procinfo.framepointer=NR_STACK_POINTER_REG then
                  current_asmdata.asmcfi.cfa_def_cfa_offset(list,regsize+localsize+sizeof(pint));
                current_procinfo.final_localsize:=localsize;
              end
          end;
      end;


    procedure tcgz80.g_proc_exit(list : TAsmList;parasize : longint;nostackframe:boolean);
      var
        regs : tcpuregisterset;
        reg : TSuperRegister;
        LocalSize : longint;
      begin
        { every byte counts for Z80, so if a subroutine is marked as non-returning, we do
          not generate any exit code, so we really trust the noreturn directive
        }
        if po_noreturn in current_procinfo.procdef.procoptions then
          exit;

        { remove stackframe }
        if not nostackframe then
          begin
            stacksize:=current_procinfo.calc_stackframe_size;
            if (target_info.stackalign>4) and
               ((stacksize <> 0) or
                (pi_do_call in current_procinfo.flags) or
                { can't detect if a call in this case -> use nostackframe }
                { if you (think you) know what you are doing              }
                (po_assembler in current_procinfo.procdef.procoptions)) then
              stacksize := align(stacksize+sizeof(aint),target_info.stackalign) - sizeof(aint);
            if (current_procinfo.framepointer=NR_STACK_POINTER_REG) then
              begin
                internalerror(2020040302);
                {if (stacksize<>0) then
                  cg.a_op_const_reg(list,OP_ADD,OS_ADDR,stacksize,current_procinfo.framepointer);}
              end
            else
              begin
                list.Concat(taicpu.op_reg_reg(A_LD,NR_STACK_POINTER_REG,NR_FRAME_POINTER_REG));
                list.Concat(taicpu.op_reg(A_POP,NR_FRAME_POINTER_REG));
              end;
            list.concat(tai_regalloc.dealloc(current_procinfo.framepointer,nil));
          end;

        list.concat(taicpu.op_none(A_RET));
      end;


    procedure tcgz80.a_loadaddr_ref_reg(list : TAsmList;const ref : treference;r : tregister);
      var
        tmpref : treference;
      begin
        if assigned(ref.symbol) or (ref.offset<>0) then
          begin
            reference_reset(tmpref,0,[]);
            tmpref.symbol:=ref.symbol;
            tmpref.offset:=ref.offset;

            tmpref.refaddr:=addr_lo8;
            list.concat(taicpu.op_reg_ref(A_LD,r,tmpref));

            tmpref.refaddr:=addr_hi8;
            list.concat(taicpu.op_reg_ref(A_LD,GetNextReg(r),tmpref));

            if (ref.base<>NR_NO) then
              begin
                list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: a_loadaddr_ref_reg with symbol and ref.base')));
                //list.concat(taicpu.op_reg_reg(A_ADD,r,ref.base));
                //list.concat(taicpu.op_reg_reg(A_ADC,GetNextReg(r),GetNextReg(ref.base)));
              end;
            if (ref.index<>NR_NO) then
              begin
                list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: a_loadaddr_ref_reg with symbol and ref.index')));
                //list.concat(taicpu.op_reg_reg(A_ADD,r,ref.index));
                //list.concat(taicpu.op_reg_reg(A_ADC,GetNextReg(r),GetNextReg(ref.index)));
              end;
          end
        else
          list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: a_loadaddr_ref_reg')));
        //else if (ref.base<>NR_NO)then
        //  begin
        //    emit_mov(list,r,ref.base);
        //    emit_mov(list,GetNextReg(r),GetNextReg(ref.base));
        //    if (ref.index<>NR_NO) then
        //      begin
        //        list.concat(taicpu.op_reg_reg(A_ADD,r,ref.index));
        //        list.concat(taicpu.op_reg_reg(A_ADC,GetNextReg(r),GetNextReg(ref.index)));
        //      end;
        //  end
        //else if (ref.index<>NR_NO) then
        //  begin
        //    emit_mov(list,r,ref.index);
        //    emit_mov(list,GetNextReg(r),GetNextReg(ref.index));
        //  end;
      end;


    procedure tcgz80.fixref(list : TAsmList;var ref : treference);
      begin
        internalerror(2011021320);
      end;


    procedure tcgz80.g_concatcopy_move(list : TAsmList;const source,dest : treference;len : tcgint);
      var
        paraloc1,paraloc2,paraloc3 : TCGPara;
        pd : tprocdef;
      begin
        pd:=search_system_proc('MOVE');
        paraloc1.init;
        paraloc2.init;
        paraloc3.init;
        {$warning TODO: implement!!!}
        //paramanager.getintparaloc(list,pd,1,paraloc1);
        //paramanager.getintparaloc(list,pd,2,paraloc2);
        //paramanager.getintparaloc(list,pd,3,paraloc3);
        a_load_const_cgpara(list,OS_SINT,len,paraloc3);
        a_loadaddr_ref_cgpara(list,dest,paraloc2);
        a_loadaddr_ref_cgpara(list,source,paraloc1);
        paramanager.freecgpara(list,paraloc3);
        paramanager.freecgpara(list,paraloc2);
        paramanager.freecgpara(list,paraloc1);
        alloccpuregisters(list,R_INTREGISTER,paramanager.get_volatile_registers_int(pocall_default));
        a_call_name_static(list,'FPC_MOVE');
        dealloccpuregisters(list,R_INTREGISTER,paramanager.get_volatile_registers_int(pocall_default));
        paraloc3.done;
        paraloc2.done;
        paraloc1.done;
      end;


    procedure tcgz80.g_concatcopy(list : TAsmList;const source,dest : treference;len : tcgint);
      var
        countreg,tmpreg : tregister;
        srcref,dstref : treference;
        copysize,countregsize : tcgsize;
        l : TAsmLabel;
        i : longint;
        SrcQuickRef, DestQuickRef : Boolean;
      begin
        if (len=1) and (not assigned(source.symbol) and
            ((source.base=NR_IX) or (source.base=NR_IY) or
             ((source.base=NR_HL) and (source.offset=0)))) and
           (not assigned(dest.symbol) and
            ((dest.base=NR_IX) or (dest.base=NR_IY) or
             ((dest.base=NR_HL) and (dest.offset=0)))) then
          begin
            tmpreg:=getintregister(list,OS_8);
            list.concat(taicpu.op_reg_ref(A_LD,tmpreg,source));
            list.concat(taicpu.op_ref_reg(A_LD,dest,tmpreg));
          end
        else
          list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: g_concatcopy')));
        //if len>16 then
        //  begin
        //    current_asmdata.getjumplabel(l);
        //
        //    reference_reset(srcref,source.alignment,source.volatility);
        //    reference_reset(dstref,dest.alignment,source.volatility);
        //    srcref.base:=NR_R30;
        //    srcref.addressmode:=AM_POSTINCREMENT;
        //    dstref.base:=NR_R26;
        //    dstref.addressmode:=AM_POSTINCREMENT;
        //
        //    copysize:=OS_8;
        //    if len<256 then
        //      countregsize:=OS_8
        //    else if len<65536 then
        //      countregsize:=OS_16
        //    else
        //      internalerror(2011022007);
        //    countreg:=getintregister(list,countregsize);
        //    a_load_const_reg(list,countregsize,len,countreg);
        //    a_loadaddr_ref_reg(list,source,NR_R30);
        //
        //    { only base or index register in dest? }
        //    if ((dest.addressmode=AM_UNCHANGED) and (dest.offset=0) and not(assigned(dest.symbol))) and
        //      ((dest.base<>NR_NO) xor (dest.index<>NR_NO)) then
        //      begin
        //        if dest.base<>NR_NO then
        //          tmpreg:=dest.base
        //        else if dest.index<>NR_NO then
        //          tmpreg:=dest.index
        //        else
        //          internalerror(2016112001);
        //      end
        //    else
        //      begin
        //        tmpreg:=getaddressregister(list);
        //        a_loadaddr_ref_reg(list,dest,tmpreg);
        //      end;
        //
        //    { X is used for spilling code so we can load it
        //      only by a push/pop sequence, this can be
        //      optimized later on by the peephole optimizer
        //    }
        //    list.concat(taicpu.op_reg(A_PUSH,tmpreg));
        //    list.concat(taicpu.op_reg(A_PUSH,GetNextReg(tmpreg)));
        //    list.concat(taicpu.op_reg(A_POP,NR_R27));
        //    list.concat(taicpu.op_reg(A_POP,NR_R26));
        //    cg.a_label(list,l);
        //    list.concat(taicpu.op_reg_ref(GetLoad(srcref),NR_R0,srcref));
        //    list.concat(taicpu.op_ref_reg(GetStore(dstref),dstref,NR_R0));
        //    list.concat(taicpu.op_reg(A_DEC,countreg));
        //    a_jmp_flags(list,F_NE,l);
        //    // keep registers alive
        //    list.concat(taicpu.op_reg_reg(A_MOV,countreg,countreg));
        //  end
        //else
        //  begin
        //    SrcQuickRef:=false;
        //    DestQuickRef:=false;
        //    if not((source.addressmode=AM_UNCHANGED) and
        //           (source.symbol=nil) and
        //           ((source.base=NR_R28) or
        //            (source.base=NR_R30)) and
        //            (source.Index=NR_NO) and
        //            (source.Offset in [0..64-len])) and
        //      not((source.Base=NR_NO) and (source.Index=NR_NO)) then
        //      srcref:=normalize_ref(list,source,NR_R30)
        //    else
        //      begin
        //        SrcQuickRef:=true;
        //        srcref:=source;
        //      end;
        //
        //    if not((dest.addressmode=AM_UNCHANGED) and
        //           (dest.symbol=nil) and
        //           ((dest.base=NR_R28) or
        //            (dest.base=NR_R30)) and
        //            (dest.Index=NR_No) and
        //            (dest.Offset in [0..64-len])) and
        //      not((dest.Base=NR_NO) and (dest.Index=NR_NO)) then
        //      begin
        //        if not(SrcQuickRef) then
        //          begin
        //            { only base or index register in dest? }
        //            if ((dest.addressmode=AM_UNCHANGED) and (dest.offset=0) and not(assigned(dest.symbol))) and
        //              ((dest.base<>NR_NO) xor (dest.index<>NR_NO)) then
        //              begin
        //                if dest.base<>NR_NO then
        //                  tmpreg:=dest.base
        //                else if dest.index<>NR_NO then
        //                  tmpreg:=dest.index
        //                else
        //                  internalerror(2016112002);
        //              end
        //            else
        //              tmpreg:=getaddressregister(list);
        //
        //            dstref:=normalize_ref(list,dest,tmpreg);
        //
        //            { X is used for spilling code so we can load it
        //              only by a push/pop sequence, this can be
        //              optimized later on by the peephole optimizer
        //            }
        //            list.concat(taicpu.op_reg(A_PUSH,tmpreg));
        //            list.concat(taicpu.op_reg(A_PUSH,GetNextReg(tmpreg)));
        //            list.concat(taicpu.op_reg(A_POP,NR_R27));
        //            list.concat(taicpu.op_reg(A_POP,NR_R26));
        //            dstref.base:=NR_R26;
        //          end
        //        else
        //          dstref:=normalize_ref(list,dest,NR_R30);
        //      end
        //    else
        //      begin
        //        DestQuickRef:=true;
        //        dstref:=dest;
        //      end;
        //
        //    for i:=1 to len do
        //      begin
        //        if not(SrcQuickRef) and (i<len) then
        //          srcref.addressmode:=AM_POSTINCREMENT
        //        else
        //          srcref.addressmode:=AM_UNCHANGED;
        //
        //        if not(DestQuickRef) and (i<len) then
        //          dstref.addressmode:=AM_POSTINCREMENT
        //        else
        //          dstref.addressmode:=AM_UNCHANGED;
        //
        //        list.concat(taicpu.op_reg_ref(GetLoad(srcref),NR_R0,srcref));
        //        list.concat(taicpu.op_ref_reg(GetStore(dstref),dstref,NR_R0));
        //
        //        if SrcQuickRef then
        //          inc(srcref.offset);
        //        if DestQuickRef then
        //          inc(dstref.offset);
        //      end;
        //    if not(SrcQuickRef) then
        //      begin
        //        ungetcpuregister(list,srcref.base);
        //        ungetcpuregister(list,GetNextReg(srcref.base));
        //      end;
        //  end;
      end;


    procedure tcgz80.g_overflowCheck(list : TAsmList;const l : tlocation;def : tdef);
      var
        hl : tasmlabel;
        ai : taicpu;
        cond : TAsmCond;
      begin
        list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: g_overflowCheck')));
        //if not(cs_check_overflow in current_settings.localswitches) then
        // exit;
        //current_asmdata.getjumplabel(hl);
        //if not ((def.typ=pointerdef) or
        //       ((def.typ=orddef) and
        //        (torddef(def).ordtype in [u64bit,u16bit,u32bit,u8bit,uchar,
        //                                  pasbool8,pasbool16,pasbool32,pasbool64]))) then
        //  cond:=C_VC
        //else
        //  cond:=C_CC;
        //ai:=Taicpu.Op_Sym(A_BRxx,hl);
        //ai.SetCondition(cond);
        //ai.is_jmp:=true;
        //list.concat(ai);
        //
        //a_call_name(list,'FPC_OVERFLOW',false);
        //a_label(list,hl);
      end;


    procedure tcgz80.g_save_registers(list: TAsmList);
      begin
        { this is done by the entry code }
      end;


    procedure tcgz80.g_restore_registers(list: TAsmList);
      begin
        { this is done by the exit code }
      end;


    procedure tcgz80.a_jmp_cond(list : TAsmList;cond : TOpCmp;l: tasmlabel);
      var
        ai1,ai2 : taicpu;
        hl : TAsmLabel;
      begin
        list.Concat(tai_comment.Create(strpnew('WARNING! not implemented: a_jmp_cond')));
        //ai1:=Taicpu.Op_sym(A_BRxx,l);
        //ai1.is_jmp:=true;
        //hl:=nil;
        //case cond of
        //  OC_EQ:
        //    ai1.SetCondition(C_EQ);
        //  OC_GT:
        //    begin
        //      { emulate GT }
        //      current_asmdata.getjumplabel(hl);
        //      ai2:=Taicpu.Op_Sym(A_BRxx,hl);
        //      ai2.SetCondition(C_EQ);
        //      ai2.is_jmp:=true;
        //      list.concat(ai2);
        //
        //      ai1.SetCondition(C_GE);
        //    end;
        //  OC_LT:
        //    ai1.SetCondition(C_LT);
        //  OC_GTE:
        //    ai1.SetCondition(C_GE);
        //  OC_LTE:
        //    begin
        //      { emulate LTE }
        //      ai2:=Taicpu.Op_Sym(A_BRxx,l);
        //      ai2.SetCondition(C_EQ);
        //      ai2.is_jmp:=true;
        //      list.concat(ai2);
        //
        //      ai1.SetCondition(C_LT);
        //    end;
        //  OC_NE:
        //    ai1.SetCondition(C_NE);
        //  OC_BE:
        //    begin
        //      { emulate BE }
        //      ai2:=Taicpu.Op_Sym(A_BRxx,l);
        //      ai2.SetCondition(C_EQ);
        //      ai2.is_jmp:=true;
        //      list.concat(ai2);
        //
        //      ai1.SetCondition(C_LO);
        //    end;
        //  OC_B:
        //    ai1.SetCondition(C_LO);
        //  OC_AE:
        //    ai1.SetCondition(C_SH);
        //  OC_A:
        //    begin
        //      { emulate A (unsigned GT) }
        //      current_asmdata.getjumplabel(hl);
        //      ai2:=Taicpu.Op_Sym(A_BRxx,hl);
        //      ai2.SetCondition(C_EQ);
        //      ai2.is_jmp:=true;
        //      list.concat(ai2);
        //
        //      ai1.SetCondition(C_SH);
        //    end;
        //  else
        //    internalerror(2011082501);
        //end;
        //list.concat(ai1);
        //if assigned(hl) then
        //  a_label(list,hl);
      end;


    procedure tcgz80.emit_mov(list: TAsmList;reg2: tregister; reg1: tregister);
      var
         instr: taicpu;
      begin
       instr:=taicpu.op_reg_reg(A_LD,reg2,reg1);
       list.Concat(instr);
       { Notify the register allocator that we have written a move instruction so
         it can try to eliminate it. }
       add_move_instruction(instr);
      end;


    procedure tcg64fz80.a_op64_reg_reg(list : TAsmList;op:TOpCG;size : tcgsize;regsrc,regdst : tregister64);
      begin
         if not(size in [OS_S64,OS_64]) then
           internalerror(2012102402);
         tcgz80(cg).a_op_reg_reg_internal(list,Op,size,regsrc.reglo,regsrc.reghi,regdst.reglo,regdst.reghi);
      end;


    procedure tcg64fz80.a_op64_const_reg(list : TAsmList;op:TOpCG;size : tcgsize;value : int64;reg : tregister64);
      begin
        tcgz80(cg).a_op_const_reg_internal(list,Op,size,value,reg.reglo,reg.reghi);
      end;


    function GetByteLoc(const loc : tlocation; nr : byte) : tlocation;
      var
        i : Integer;
      begin
        Result:=loc;
        Result.size:=OS_8;
        case loc.loc of
          LOC_REFERENCE,LOC_CREFERENCE:
            inc(Result.reference.offset,nr);
          LOC_REGISTER,LOC_CREGISTER:
            begin
              if nr>=4 then
                Result.register:=Result.register64.reghi;
              nr:=nr mod 4;
              for i:=1 to nr do
                Result.register:=GetNextReg(Result.register);
            end;
          LOC_CONSTANT:
            if loc.size in [OS_64,OS_S64] then
              Result.value:=(Result.value64 shr (nr*8)) and $ff
            else
              Result.value:=(Result.value shr (nr*8)) and $ff;
          else
            Internalerror(2019020902);
        end;
      end;


    procedure create_codegen;
      begin
        cg:=tcgz80.create;
        cg64:=tcg64fz80.create;
      end;

end.
