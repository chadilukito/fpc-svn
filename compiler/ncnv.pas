{
    Copyright (c) 2000-2002 by Florian Klaempfl

    Type checking and register allocation for type converting nodes

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
unit ncnv;

{$i fpcdefs.inc}

interface

    uses
       node,
       symtype,
       defutil,defcmp,
       nld
       ;

    type
       ttypeconvnode = class(tunarynode)
          totypedef   : tdef;
          totypedefderef : tderef;
          convtype : tconverttype;
          constructor create(node : tnode;def:tdef);virtual;
          constructor create_explicit(node : tnode;def:tdef);
          constructor create_internal(node : tnode;def:tdef);
          constructor create_proc_to_procvar(node : tnode);
          constructor ppuload(t:tnodetype;ppufile:tcompilerppufile);override;
          procedure ppuwrite(ppufile:tcompilerppufile);override;
          procedure buildderefimpl;override;
          procedure derefimpl;override;
          function dogetcopy : tnode;override;
          procedure printnodeinfo(var t : text);override;
          function pass_1 : tnode;override;
          function pass_typecheck:tnode;override;
          function simplify:tnode; override;
          procedure mark_write;override;
          function docompare(p: tnode) : boolean; override;
          function assign_allowed:boolean;
          procedure second_call_helper(c : tconverttype);
       private
          function typecheck_int_to_int : tnode;
          function typecheck_cord_to_pointer : tnode;
          function typecheck_chararray_to_string : tnode;
          function typecheck_string_to_chararray : tnode;
          function typecheck_string_to_string : tnode;
          function typecheck_char_to_string : tnode;
          function typecheck_char_to_chararray : tnode;
          function typecheck_int_to_real : tnode;
          function typecheck_int_to_string : tnode;
          function typecheck_real_to_real : tnode;
          function typecheck_real_to_currency : tnode;
          function typecheck_cchar_to_pchar : tnode;
          function typecheck_cstring_to_pchar : tnode;
          function typecheck_cstring_to_int : tnode;
          function typecheck_char_to_char : tnode;
          function typecheck_arrayconstructor_to_set : tnode;
          function typecheck_pchar_to_string : tnode;
          function typecheck_interface_to_guid : tnode;
          function typecheck_dynarray_to_openarray : tnode;
          function typecheck_pwchar_to_string : tnode;
          function typecheck_variant_to_dynarray : tnode;
          function typecheck_dynarray_to_variant : tnode;
          function typecheck_call_helper(c : tconverttype) : tnode;
          function typecheck_variant_to_enum : tnode;
          function typecheck_enum_to_variant : tnode;
          function typecheck_proc_to_procvar : tnode;
          function typecheck_variant_to_interface : tnode;
          function typecheck_interface_to_variant : tnode;
          function typecheck_array_2_dynarray : tnode;
       protected
          function first_int_to_int : tnode;virtual;
          function first_cstring_to_pchar : tnode;virtual;
          function first_cstring_to_int : tnode;virtual;
          function first_string_to_chararray : tnode;virtual;
          function first_char_to_string : tnode;virtual;
          function first_nothing : tnode;virtual;
          function first_array_to_pointer : tnode;virtual;
          function first_int_to_real : tnode;virtual;
          function first_real_to_real : tnode;virtual;
          function first_pointer_to_array : tnode;virtual;
          function first_cchar_to_pchar : tnode;virtual;
          function first_bool_to_int : tnode;virtual;
          function first_int_to_bool : tnode;virtual;
          function first_bool_to_bool : tnode;virtual;
          function first_proc_to_procvar : tnode;virtual;
          function first_load_smallset : tnode;virtual;
          function first_cord_to_pointer : tnode;virtual;
          function first_ansistring_to_pchar : tnode;virtual;
          function first_arrayconstructor_to_set : tnode;virtual;
          function first_class_to_intf : tnode;virtual;
          function first_char_to_char : tnode;virtual;
          function first_call_helper(c : tconverttype) : tnode;

          { these wrapper are necessary, because the first_* stuff is called }
          { through a table. Without the wrappers override wouldn't have     }
          { any effect                                                       }
          function _first_int_to_int : tnode;
          function _first_cstring_to_pchar : tnode;
          function _first_cstring_to_int : tnode;
          function _first_string_to_chararray : tnode;
          function _first_char_to_string : tnode;
          function _first_nothing : tnode;
          function _first_array_to_pointer : tnode;
          function _first_int_to_real : tnode;
          function _first_real_to_real: tnode;
          function _first_pointer_to_array : tnode;
          function _first_cchar_to_pchar : tnode;
          function _first_bool_to_int : tnode;
          function _first_int_to_bool : tnode;
          function _first_bool_to_bool : tnode;
          function _first_proc_to_procvar : tnode;
          function _first_load_smallset : tnode;
          function _first_cord_to_pointer : tnode;
          function _first_ansistring_to_pchar : tnode;
          function _first_arrayconstructor_to_set : tnode;
          function _first_class_to_intf : tnode;
          function _first_char_to_char : tnode;

          procedure _second_int_to_int;virtual;
          procedure _second_string_to_string;virtual;
          procedure _second_cstring_to_pchar;virtual;
          procedure _second_cstring_to_int;virtual;
          procedure _second_string_to_chararray;virtual;
          procedure _second_array_to_pointer;virtual;
          procedure _second_pointer_to_array;virtual;
          procedure _second_chararray_to_string;virtual;
          procedure _second_char_to_string;virtual;
          procedure _second_int_to_real;virtual;
          procedure _second_real_to_real;virtual;
          procedure _second_cord_to_pointer;virtual;
          procedure _second_proc_to_procvar;virtual;
          procedure _second_bool_to_int;virtual;
          procedure _second_int_to_bool;virtual;
          procedure _second_bool_to_bool;virtual;
          procedure _second_load_smallset;virtual;
          procedure _second_ansistring_to_pchar;virtual;
          procedure _second_class_to_intf;virtual;
          procedure _second_char_to_char;virtual;
          procedure _second_nothing; virtual;

          procedure second_int_to_int;virtual;abstract;
          procedure second_string_to_string;virtual;abstract;
          procedure second_cstring_to_pchar;virtual;abstract;
          procedure second_cstring_to_int;virtual;abstract;
          procedure second_string_to_chararray;virtual;abstract;
          procedure second_array_to_pointer;virtual;abstract;
          procedure second_pointer_to_array;virtual;abstract;
          procedure second_chararray_to_string;virtual;abstract;
          procedure second_char_to_string;virtual;abstract;
          procedure second_int_to_real;virtual;abstract;
          procedure second_real_to_real;virtual;abstract;
          procedure second_cord_to_pointer;virtual;abstract;
          procedure second_proc_to_procvar;virtual;abstract;
          procedure second_bool_to_int;virtual;abstract;
          procedure second_int_to_bool;virtual;abstract;
          procedure second_bool_to_bool;virtual;abstract;
          procedure second_load_smallset;virtual;abstract;
          procedure second_ansistring_to_pchar;virtual;abstract;
          procedure second_class_to_intf;virtual;abstract;
          procedure second_char_to_char;virtual;abstract;
          procedure second_nothing; virtual;abstract;
       end;
       ttypeconvnodeclass = class of ttypeconvnode;

       tasnode = class(tbinarynode)
          constructor create(l,r : tnode);virtual;
          function pass_1 : tnode;override;
          function pass_typecheck:tnode;override;
          function dogetcopy: tnode;override;
          destructor destroy; override;
          call: tnode;
       end;
       tasnodeclass = class of tasnode;

       tisnode = class(tbinarynode)
          constructor create(l,r : tnode);virtual;
          function pass_1 : tnode;override;
          function pass_typecheck:tnode;override;
          procedure pass_generate_code;override;
       end;
       tisnodeclass = class of tisnode;

    var
       ctypeconvnode : ttypeconvnodeclass;
       casnode : tasnodeclass;
       cisnode : tisnodeclass;

    procedure inserttypeconv(var p:tnode;def:tdef);
    procedure inserttypeconv_internal(var p:tnode;def:tdef);
    procedure arrayconstructor_to_set(var p : tnode);
    procedure insert_varargstypeconv(var p : tnode; iscvarargs: boolean);
    procedure int_to_4cc(var p: tnode);


implementation

   uses
      cclasses,globtype,systems,
      cutils,verbose,globals,widestr,
      symconst,symdef,symsym,symbase,symtable,
      ncon,ncal,nset,nadd,ninl,nmem,nmat,nbas,nutils,
      cgbase,procinfo,
      htypechk,pass_1,cpuinfo;


{*****************************************************************************
                                   Helpers
*****************************************************************************}

    procedure inserttypeconv(var p:tnode;def:tdef);

      begin
        if not assigned(p.resultdef) then
         begin
           typecheckpass(p);
           if codegenerror then
            exit;
         end;

        { don't insert obsolete type conversions }
        if equal_defs(p.resultdef,def) and
           not ((p.resultdef.deftype=setdef) and
                (tsetdef(p.resultdef).settype <>
                 tsetdef(def).settype)) then
         begin
           p.resultdef:=def;
         end
        else
         begin
           p:=ctypeconvnode.create(p,def);
           typecheckpass(p);
         end;
      end;


    procedure inserttypeconv_internal(var p:tnode;def:tdef);

      begin
        if not assigned(p.resultdef) then
         begin
           typecheckpass(p);
           if codegenerror then
            exit;
         end;

        { don't insert obsolete type conversions }
        if equal_defs(p.resultdef,def) and
           not ((p.resultdef.deftype=setdef) and
                (tsetdef(p.resultdef).settype <>
                 tsetdef(def).settype)) then
         begin
           p.resultdef:=def;
         end
        else
         begin
           p:=ctypeconvnode.create_internal(p,def);
           typecheckpass(p);
         end;
      end;


{*****************************************************************************
                    Array constructor to Set Conversion
*****************************************************************************}

    procedure arrayconstructor_to_set(var p : tnode);

      var
        constp      : tsetconstnode;
        buildp,
        p2,p3,p4    : tnode;
        hdef        : tdef;
        constset    : Pconstset;
        constsetlo,
        constsethi  : TConstExprInt;

        procedure update_constsethi(def:tdef);
          begin
            if ((def.deftype=orddef) and
                (torddef(def).high>=constsethi)) then
              begin
                if torddef(def).typ=uwidechar then
                  begin
                    constsethi:=255;
                    if hdef=nil then
                      hdef:=def;
                  end
                else
                  begin
                    constsethi:=torddef(def).high;
                    if hdef=nil then
                      begin
                         if (constsethi>255) or
                            (torddef(def).low<0) then
                           hdef:=u8inttype
                         else
                           hdef:=def;
                      end;
                    if constsethi>255 then
                      constsethi:=255;
                  end;
              end
            else if ((def.deftype=enumdef) and
                    (tenumdef(def).max>=constsethi)) then
              begin
                 if hdef=nil then
                   hdef:=def;
                 constsethi:=tenumdef(def).max;
              end;
          end;

        procedure do_set(pos : longint);
          begin
            if (pos and not $ff)<>0 then
             Message(parser_e_illegal_set_expr);
            if pos>constsethi then
             constsethi:=pos;
            if pos<constsetlo then
             constsetlo:=pos;
            if pos in constset^ then
              Message(parser_e_illegal_set_expr);
            include(constset^,pos);
          end;

      var
        l : Longint;
        lr,hr : TConstExprInt;
        hp : tarrayconstructornode;
      begin
        if p.nodetype<>arrayconstructorn then
          internalerror(200205105);
        new(constset);
        constset^:=[];
        hdef:=nil;
        constsetlo:=0;
        constsethi:=0;
        constp:=csetconstnode.create(nil,hdef);
        constp.value_set:=constset;
        buildp:=constp;
        hp:=tarrayconstructornode(p);
        if assigned(hp.left) then
         begin
           while assigned(hp) do
            begin
              p4:=nil; { will contain the tree to create the set }
            {split a range into p2 and p3 }
              if hp.left.nodetype=arrayconstructorrangen then
               begin
                 p2:=tarrayconstructorrangenode(hp.left).left;
                 p3:=tarrayconstructorrangenode(hp.left).right;
                 tarrayconstructorrangenode(hp.left).left:=nil;
                 tarrayconstructorrangenode(hp.left).right:=nil;
               end
              else
               begin
                 p2:=hp.left;
                 hp.left:=nil;
                 p3:=nil;
               end;
              typecheckpass(p2);
              set_varstate(p2,vs_read,[vsf_must_be_valid]);
              if assigned(p3) then
                begin
                  typecheckpass(p3);
                  set_varstate(p3,vs_read,[vsf_must_be_valid]);
                end;
              if codegenerror then
               break;
              case p2.resultdef.deftype of
                 enumdef,
                 orddef:
                   begin
                      getrange(p2.resultdef,lr,hr);
                      if assigned(p3) then
                       begin
                         { this isn't good, you'll get problems with
                           type t010 = 0..10;
                                ts = set of t010;
                           var  s : ts;b : t010
                           begin  s:=[1,2,b]; end.
                         if is_integer(p3^.resultdef) then
                          begin
                            inserttypeconv(p3,u8bitdef);
                          end;
                         }
                         if assigned(hdef) and not(equal_defs(hdef,p3.resultdef)) then
                           begin
                              aktfilepos:=p3.fileinfo;
                              CGMessage(type_e_typeconflict_in_set);
                           end
                         else
                           begin
                             if (p2.nodetype=ordconstn) and (p3.nodetype=ordconstn) then
                              begin
                                 if not(is_integer(p3.resultdef)) then
                                   hdef:=p3.resultdef
                                 else
                                   begin
                                     inserttypeconv(p3,u8inttype);
                                     inserttypeconv(p2,u8inttype);
                                   end;

                                for l:=tordconstnode(p2).value to tordconstnode(p3).value do
                                  do_set(l);
                                p2.free;
                                p3.free;
                              end
                             else
                              begin
                                update_constsethi(p2.resultdef);
                                inserttypeconv(p2,hdef);

                                update_constsethi(p3.resultdef);
                                inserttypeconv(p3,hdef);

                                if assigned(hdef) then
                                  inserttypeconv(p3,hdef)
                                else
                                  inserttypeconv(p3,u8inttype);
                                p4:=csetelementnode.create(p2,p3);
                              end;
                           end;
                       end
                      else
                       begin
                         { Single value }
                         if p2.nodetype=ordconstn then
                          begin
                            if not(is_integer(p2.resultdef)) then
                              begin
                                { for constant set elements, delphi allows the usage of elements of enumerations which
                                  have value>255 if there is no element with a value > 255 used }
                                if (m_delphi in current_settings.modeswitches) and (p2.resultdef.deftype=enumdef) then
                                  begin
                                    if tordconstnode(p2).value>constsethi then
                                      constsethi:=tordconstnode(p2).value;
                                    if hdef=nil then
                                      hdef:=p2.resultdef;
                                  end
                                else
                                  update_constsethi(p2.resultdef);
                              end;

                            if assigned(hdef) then
                              inserttypeconv(p2,hdef)
                            else
                              inserttypeconv(p2,u8inttype);

                            do_set(tordconstnode(p2).value);
                            p2.free;
                          end
                         else
                          begin
                            update_constsethi(p2.resultdef);

                            if assigned(hdef) then
                              inserttypeconv(p2,hdef)
                            else
                              inserttypeconv(p2,u8inttype);

                            p4:=csetelementnode.create(p2,nil);
                          end;
                       end;
                    end;

                  stringdef :
                    begin
                        { if we've already set elements which are constants }
                        { throw an error                                    }
                        if ((hdef=nil) and assigned(buildp)) or
                          not(is_char(hdef)) then
                          CGMessage(type_e_typeconflict_in_set)
                        else
                         for l:=1 to length(pstring(tstringconstnode(p2).value_str)^) do
                          do_set(ord(pstring(tstringconstnode(p2).value_str)^[l]));
                        if hdef=nil then
                         hdef:=cchartype;
                        p2.free;
                      end;

                    else
                      CGMessage(type_e_ordinal_expr_expected);
              end;
              { insert the set creation tree }
              if assigned(p4) then
               buildp:=caddnode.create(addn,buildp,p4);
              { load next and dispose current node }
              p2:=hp;
              hp:=tarrayconstructornode(tarrayconstructornode(p2).right);
              tarrayconstructornode(p2).right:=nil;
              p2.free;
            end;
           if (hdef=nil) then
            hdef:=u8inttype;
         end
        else
         begin
           { empty set [], only remove node }
           p.free;
         end;
        { set the initial set type }
        constp.resultdef:=tsetdef.create(hdef,constsethi);
        { determine the resultdef for the tree }
        typecheckpass(buildp);
        { set the new tree }
        p:=buildp;
      end;


    procedure insert_varargstypeconv(var p : tnode; iscvarargs: boolean);
      begin
        if not(iscvarargs) and
           (p.nodetype=stringconstn) then
          p:=ctypeconvnode.create_internal(p,cansistringtype)
        else
          case p.resultdef.deftype of
            enumdef :
              p:=ctypeconvnode.create_internal(p,s32inttype);
            arraydef :
              begin
                if is_chararray(p.resultdef) then
                  p:=ctypeconvnode.create_internal(p,charpointertype)
                else
                  if is_widechararray(p.resultdef) then
                    p:=ctypeconvnode.create_internal(p,widecharpointertype)
                else
                  CGMessagePos1(p.fileinfo,type_e_wrong_type_in_array_constructor,p.resultdef.typename);
              end;
            orddef :
              begin
                if is_integer(p.resultdef) and
                   not(is_64bitint(p.resultdef)) then
                  p:=ctypeconvnode.create(p,s32inttype)
                else if is_void(p.resultdef) then
                  CGMessagePos1(p.fileinfo,type_e_wrong_type_in_array_constructor,p.resultdef.typename)
                else if iscvarargs and
                        is_currency(p.resultdef) then
                       p:=ctypeconvnode.create(p,s64floattype);
              end;
            floatdef :
              if not(iscvarargs) then
                begin
                  if not(is_currency(p.resultdef)) then
                    p:=ctypeconvnode.create(p,pbestrealtype^);
                end
              else
                begin
                  if is_constrealnode(p) and
                     not(nf_explicit in p.flags) then
                    MessagePos(p.fileinfo,type_w_double_c_varargs);
                  if (tfloatdef(p.resultdef).typ in [{$ifndef x86_64}s32real,{$endif}s64currency]) or
                     (is_constrealnode(p) and
                      not(nf_explicit in p.flags)) then
                    p:=ctypeconvnode.create(p,s64floattype);
                end;
            procvardef :
              p:=ctypeconvnode.create(p,voidpointertype);
            stringdef:
              if iscvarargs then
                p:=ctypeconvnode.create(p,charpointertype);
            variantdef:
              if iscvarargs then
                CGMessagePos1(p.fileinfo,type_e_wrong_type_in_array_constructor,p.resultdef.typename);
            pointerdef:
              ;
            classrefdef:
              if iscvarargs then
                p:=ctypeconvnode.create(p,voidpointertype);
            objectdef :
              if iscvarargs or
                 is_object(p.resultdef) then
                CGMessagePos1(p.fileinfo,type_e_wrong_type_in_array_constructor,p.resultdef.typename);
            else
              CGMessagePos1(p.fileinfo,type_e_wrong_type_in_array_constructor,p.resultdef.typename);
          end;
        typecheckpass(p);
      end;


    procedure int_to_4cc(var p: tnode);
      var
        srsym: tsym;
        srsymtable: tsymtable;
        inttemp, chararrtemp: ttempcreatenode;
        newblock: tblocknode;
        newstatement: tstatementnode;
      begin
         if (m_mac in current_settings.modeswitches) and
            is_integer(p.resultdef) and
            (p.resultdef.size = 4) then
           begin
             if not searchsym_type('FPC_INTERNAL_FOUR_CHAR_ARRAY',srsym,srsymtable) then
               internalerror(2006101802);
             if (target_info.endian = endian_big) then
               inserttypeconv_internal(p,ttypesym(srsym).typedef)
             else
               begin
                 newblock := internalstatements(newstatement);
                 inttemp := ctempcreatenode.create(p.resultdef,4,tt_persistent,true);
                 chararrtemp := ctempcreatenode.create(ttypesym(srsym).typedef,4,tt_persistent,true);
                 addstatement(newstatement,inttemp);
                 addstatement(newstatement,cassignmentnode.create(
                   ctemprefnode.create(inttemp),p));
                 addstatement(newstatement,chararrtemp);

                 addstatement(newstatement,cassignmentnode.create(
                   cvecnode.create(ctemprefnode.create(chararrtemp),
                     cordconstnode.create(1,u32inttype,false)),
                   ctypeconvnode.create_explicit(
                     cshlshrnode.create(shrn,ctemprefnode.create(inttemp),
                       cordconstnode.create(24,s32inttype,false)),
                     cchartype)));

                 addstatement(newstatement,cassignmentnode.create(
                   cvecnode.create(ctemprefnode.create(chararrtemp),
                     cordconstnode.create(2,u32inttype,false)),
                   ctypeconvnode.create_explicit(
                     cshlshrnode.create(shrn,ctemprefnode.create(inttemp),
                       cordconstnode.create(16,s32inttype,false)),
                     cchartype)));

                 addstatement(newstatement,cassignmentnode.create(
                   cvecnode.create(ctemprefnode.create(chararrtemp),
                     cordconstnode.create(3,u32inttype,false)),
                   ctypeconvnode.create_explicit(
                     cshlshrnode.create(shrn,ctemprefnode.create(inttemp),
                       cordconstnode.create(8,s32inttype,false)),
                     cchartype)));

                 addstatement(newstatement,cassignmentnode.create(
                   cvecnode.create(ctemprefnode.create(chararrtemp),
                     cordconstnode.create(4,u32inttype,false)),
                   ctypeconvnode.create_explicit(
                     ctemprefnode.create(inttemp),cchartype)));

                 addstatement(newstatement,ctempdeletenode.create(inttemp));
                 addstatement(newstatement,ctempdeletenode.create_normal_temp(chararrtemp));
                 addstatement(newstatement,ctemprefnode.create(chararrtemp));
                 p := newblock;
                 typecheckpass(p);
               end;
           end
         else
           internalerror(2006101803);
      end;

{*****************************************************************************
                           TTYPECONVNODE
*****************************************************************************}


    constructor ttypeconvnode.create(node : tnode;def:tdef);

      begin
         inherited create(typeconvn,node);
         convtype:=tc_none;
         totypedef:=def;
         if def=nil then
          internalerror(200103281);
         fileinfo:=node.fileinfo;
      end;


    constructor ttypeconvnode.create_explicit(node : tnode;def:tdef);

      begin
         self.create(node,def);
         include(flags,nf_explicit);
      end;


    constructor ttypeconvnode.create_internal(node : tnode;def:tdef);

      begin
         self.create(node,def);
         { handle like explicit conversions }
         include(flags,nf_explicit);
         include(flags,nf_internal);
      end;


    constructor ttypeconvnode.create_proc_to_procvar(node : tnode);

      begin
         self.create(node,voidtype);
         convtype:=tc_proc_2_procvar;
      end;


    constructor ttypeconvnode.ppuload(t:tnodetype;ppufile:tcompilerppufile);
      begin
        inherited ppuload(t,ppufile);
        ppufile.getderef(totypedefderef);
        convtype:=tconverttype(ppufile.getbyte);
      end;


    procedure ttypeconvnode.ppuwrite(ppufile:tcompilerppufile);
      begin
        inherited ppuwrite(ppufile);
        ppufile.putderef(totypedefderef);
        ppufile.putbyte(byte(convtype));
      end;


    procedure ttypeconvnode.buildderefimpl;
      begin
        inherited buildderefimpl;
        totypedefderef.build(totypedef);
      end;


    procedure ttypeconvnode.derefimpl;
      begin
        inherited derefimpl;
        totypedef:=tdef(totypedefderef.resolve);
      end;


    function ttypeconvnode.dogetcopy : tnode;
      var
         n : ttypeconvnode;
      begin
         n:=ttypeconvnode(inherited dogetcopy);
         n.convtype:=convtype;
         n.totypedef:=totypedef;
         dogetcopy:=n;
      end;

    procedure ttypeconvnode.printnodeinfo(var t : text);
      const
        convtyp2str : array[tconverttype] of pchar = (
          'tc_none',
          'tc_equal',
          'tc_not_possible',
          'tc_string_2_string',
          'tc_char_2_string',
          'tc_char_2_chararray',
          'tc_pchar_2_string',
          'tc_cchar_2_pchar',
          'tc_cstring_2_pchar',
          'tc_cstring_2_int',
          'tc_ansistring_2_pchar',
          'tc_string_2_chararray',
          'tc_chararray_2_string',
          'tc_array_2_pointer',
          'tc_pointer_2_array',
          'tc_int_2_int',
          'tc_int_2_bool',
          'tc_int_2_string',
          'tc_bool_2_bool',
          'tc_bool_2_int',
          'tc_real_2_real',
          'tc_int_2_real',
          'tc_real_2_currency',
          'tc_proc_2_procvar',
          'tc_arrayconstructor_2_set',
          'tc_load_smallset',
          'tc_cord_2_pointer',
          'tc_intf_2_string',
          'tc_intf_2_guid',
          'tc_class_2_intf',
          'tc_char_2_char',
          'tc_normal_2_smallset',
          'tc_dynarray_2_openarray',
          'tc_pwchar_2_string',
          'tc_variant_2_dynarray',
          'tc_dynarray_2_variant',
          'tc_variant_2_enum',
          'tc_enum_2_variant',
          'tc_interface_2_variant',
          'tc_variant_2_interface',
          'tc_array_2_dynarray'
        );
      begin
        inherited printnodeinfo(t);
        write(t,', convtype = ',strpas(convtyp2str[convtype]));
      end;


    function ttypeconvnode.typecheck_cord_to_pointer : tnode;

      var
        t : tnode;

      begin
        result:=nil;
        if left.nodetype=ordconstn then
          begin
            { check if we have a valid pointer constant (JM) }
            if (sizeof(pointer) > sizeof(TConstPtrUInt)) then
              if (sizeof(TConstPtrUInt) = 4) then
                begin
                  if (tordconstnode(left).value < low(longint)) or
                     (tordconstnode(left).value > high(cardinal)) then
                  CGMessage(parser_e_range_check_error);
                end
              else if (sizeof(TConstPtrUInt) = 8) then
                begin
                  if (tordconstnode(left).value < low(int64)) or
                     (tordconstnode(left).value > high(qword)) then
                  CGMessage(parser_e_range_check_error);
                end
              else
                internalerror(2001020801);
            t:=cpointerconstnode.create(TConstPtrUInt(tordconstnode(left).value),resultdef);
            result:=t;
          end
         else
          internalerror(200104023);
      end;


    function ttypeconvnode.typecheck_chararray_to_string : tnode;
      var
        chartype : string[8];
      begin
        if is_widechar(tarraydef(left.resultdef).elementdef) then
          chartype:='widechar'
        else
          chartype:='char';
        result := ccallnode.createinternres(
           'fpc_'+chartype+'array_to_'+tstringdef(resultdef).stringtypname,
           ccallparanode.create(cordconstnode.create(
             ord(tarraydef(left.resultdef).lowrange=0),booltype,false),
           ccallparanode.create(left,nil)),resultdef);
        left := nil;
      end;


    function ttypeconvnode.typecheck_string_to_chararray : tnode;
      var
        arrsize  : aint;
        chartype : string[8];
      begin
        result := nil;
        with tarraydef(resultdef) do
          begin
            if highrange<lowrange then
             internalerror(200501051);
            arrsize := highrange-lowrange+1;
          end;
        if (left.nodetype = stringconstn) and
           (tstringconstnode(left).cst_type=cst_conststring) then
           begin
             { if the array of char is large enough we can use the string
               constant directly. This is handled in ncgcnv }
             if (arrsize>=tstringconstnode(left).len) and
                is_char(tarraydef(resultdef).elementdef) then
               exit;
             { Convert to wide/short/ansistring and call default helper }
             if is_widechar(tarraydef(resultdef).elementdef) then
               inserttypeconv(left,cwidestringtype)
             else
               begin
                 if tstringconstnode(left).len>255 then
                   inserttypeconv(left,cansistringtype)
                 else
                   inserttypeconv(left,cshortstringtype);
               end;
           end;
        if is_widechar(tarraydef(resultdef).elementdef) then
          chartype:='widechar'
        else
          chartype:='char';
        result := ccallnode.createinternres(
          'fpc_'+tstringdef(left.resultdef).stringtypname+
          '_to_'+chartype+'array',ccallparanode.create(left,ccallparanode.create(
          cordconstnode.create(arrsize,s32inttype,true),nil)),resultdef);
        left := nil;
      end;


    function ttypeconvnode.typecheck_string_to_string : tnode;

      var
        procname: string[31];
        stringpara : tcallparanode;

      begin
         result:=nil;
         if left.nodetype=stringconstn then
          begin
             tstringconstnode(left).changestringtype(resultdef);
             result:=left;
             left:=nil;
          end
         else
           begin
             { get the correct procedure name }
             procname := 'fpc_'+tstringdef(left.resultdef).stringtypname+
                         '_to_'+tstringdef(resultdef).stringtypname;

             { create parameter (and remove left node from typeconvnode }
             { since it's reused as parameter)                          }
             stringpara := ccallparanode.create(left,nil);
             left := nil;

             { when converting to shortstrings, we have to pass high(destination) too }
             if (tstringdef(resultdef).string_typ = st_shortstring) then
               stringpara.right := ccallparanode.create(cinlinenode.create(
                 in_high_x,false,self.getcopy),nil);

             { and create the callnode }
             result := ccallnode.createinternres(procname,stringpara,resultdef);
           end;
      end;


    function ttypeconvnode.typecheck_char_to_string : tnode;

      var
         procname: string[31];
         para : tcallparanode;
         hp : tstringconstnode;
         ws : pcompilerwidestring;

      begin
         result:=nil;
         if left.nodetype=ordconstn then
           begin
              if tstringdef(resultdef).string_typ=st_widestring then
               begin
                 initwidestring(ws);
                 if torddef(left.resultdef).typ=uwidechar then
                   concatwidestringchar(ws,tcompilerwidechar(tordconstnode(left).value))
                 else
                   concatwidestringchar(ws,tcompilerwidechar(chr(tordconstnode(left).value)));
                 hp:=cstringconstnode.createwstr(ws);
                 donewidestring(ws);
               end
              else
                begin
                  hp:=cstringconstnode.createstr(chr(tordconstnode(left).value));
                  tstringconstnode(hp).changestringtype(resultdef);
                end;
              result:=hp;
           end
         else
           { shortstrings are handled 'inline' }
           if tstringdef(resultdef).string_typ <> st_shortstring then
             begin
               { create the parameter }
               para := ccallparanode.create(left,nil);
               left := nil;

               { and the procname }
               procname := 'fpc_char_to_' +tstringdef(resultdef).stringtypname;

               { and finally the call }
               result := ccallnode.createinternres(procname,para,resultdef);
             end
           else
             begin
               { create word(byte(char) shl 8 or 1) for litte endian machines }
               { and word(byte(char) or 256) for big endian machines          }
               left := ctypeconvnode.create_internal(left,u8inttype);
               if (target_info.endian = endian_little) then
                 left := caddnode.create(orn,
                   cshlshrnode.create(shln,left,cordconstnode.create(8,s32inttype,false)),
                   cordconstnode.create(1,s32inttype,false))
               else
                 left := caddnode.create(orn,left,
                   cordconstnode.create(1 shl 8,s32inttype,false));
               left := ctypeconvnode.create_internal(left,u16inttype);
               typecheckpass(left);
             end;
      end;


    function ttypeconvnode.typecheck_char_to_chararray : tnode;

      begin
        if resultdef.size <> 1 then
          begin
            { convert first to string, then to chararray }
            inserttypeconv(left,cshortstringtype);
            inserttypeconv(left,resultdef);
            result:=left;
            left := nil;
            exit;
          end;
        result := nil;
      end;


    function ttypeconvnode.typecheck_char_to_char : tnode;

      var
         hp : tordconstnode;

      begin
         result:=nil;
         if left.nodetype=ordconstn then
           begin
             if (torddef(resultdef).typ=uchar) and
                (torddef(left.resultdef).typ=uwidechar) then
              begin
                hp:=cordconstnode.create(
                      ord(unicode2asciichar(tcompilerwidechar(tordconstnode(left).value))),
                      cchartype,true);
                result:=hp;
              end
             else if (torddef(resultdef).typ=uwidechar) and
                     (torddef(left.resultdef).typ=uchar) then
              begin
                hp:=cordconstnode.create(
                      asciichar2unicode(chr(tordconstnode(left).value)),
                      cwidechartype,true);
                result:=hp;
              end
             else
              internalerror(200105131);
             exit;
           end;
      end;


    function ttypeconvnode.typecheck_int_to_int : tnode;
      var
        v : TConstExprInt;
      begin
        result:=nil;
        if left.nodetype=ordconstn then
         begin
           v:=tordconstnode(left).value;
           if is_currency(resultdef) then
             v:=v*10000;
           if (resultdef.deftype=pointerdef) then
             result:=cpointerconstnode.create(TConstPtrUInt(v),resultdef)
           else
             begin
               if is_currency(left.resultdef) then
                 v:=v div 10000;
               result:=cordconstnode.create(v,resultdef,false);
             end;
         end
        else if left.nodetype=pointerconstn then
         begin
           v:=tpointerconstnode(left).value;
           if (resultdef.deftype=pointerdef) then
             result:=cpointerconstnode.create(v,resultdef)
           else
             begin
               if is_currency(resultdef) then
                 v:=v*10000;
               result:=cordconstnode.create(v,resultdef,false);
             end;
         end
        else
         begin
           { multiply by 10000 for currency. We need to use getcopy to pass
             the argument because the current node is always disposed. Only
             inserting the multiply in the left node is not possible because
             it'll get in an infinite loop to convert int->currency }
           if is_currency(resultdef) then
            begin
              result:=caddnode.create(muln,getcopy,cordconstnode.create(10000,resultdef,false));
              include(result.flags,nf_is_currency);
            end
           else if is_currency(left.resultdef) then
            begin
              result:=cmoddivnode.create(divn,getcopy,cordconstnode.create(10000,resultdef,false));
              include(result.flags,nf_is_currency);
            end;
         end;
      end;


    function ttypeconvnode.typecheck_int_to_real : tnode;
      var
        rv : bestreal;
      begin
        result:=nil;
        if left.nodetype=ordconstn then
         begin
           rv:=tordconstnode(left).value;
           if is_currency(resultdef) then
             rv:=rv*10000.0
           else if is_currency(left.resultdef) then
             rv:=rv/10000.0;
           result:=crealconstnode.create(rv,resultdef);
         end
        else
         begin
           { multiply by 10000 for currency. We need to use getcopy to pass
             the argument because the current node is always disposed. Only
             inserting the multiply in the left node is not possible because
             it'll get in an infinite loop to convert int->currency }
           if is_currency(resultdef) then
            begin
              result:=caddnode.create(muln,getcopy,crealconstnode.create(10000.0,resultdef));
              include(result.flags,nf_is_currency);
            end
           else if is_currency(left.resultdef) then
            begin
              result:=caddnode.create(slashn,getcopy,crealconstnode.create(10000.0,resultdef));
              include(result.flags,nf_is_currency);
            end;
         end;
      end;


    function ttypeconvnode.typecheck_real_to_currency : tnode;
      begin
        if not is_currency(resultdef) then
          internalerror(200304221);
        result:=nil;
        left:=caddnode.create(muln,left,crealconstnode.create(10000.0,left.resultdef));
        include(left.flags,nf_is_currency);
        typecheckpass(left);
        { Convert constants directly, else call Round() }
        if left.nodetype=realconstn then
          result:=cordconstnode.create(round(trealconstnode(left).value_real),resultdef,false)
        else
          result:=ccallnode.createinternres('fpc_round_real',
            ccallparanode.create(left,nil),resultdef);
        left:=nil;
      end;


    function ttypeconvnode.typecheck_int_to_string : tnode;
       begin
         if (m_mac in current_settings.modeswitches) and
            is_integer(left.resultdef) and
            (left.resultdef.size = 4) then
           begin
             int_to_4cc(left);
             inserttypeconv(left,resultdef);
             result := left;
             left := nil;
           end
         else
           internalerror(2006101803);
       end;

    function ttypeconvnode.typecheck_real_to_real : tnode;
      begin
         result:=nil;
         if is_currency(left.resultdef) and not(is_currency(resultdef)) then
           begin
             left:=caddnode.create(slashn,left,crealconstnode.create(10000.0,left.resultdef));
             include(left.flags,nf_is_currency);
             typecheckpass(left);
           end
         else
           if is_currency(resultdef) and not(is_currency(left.resultdef)) then
             begin
               left:=caddnode.create(muln,left,crealconstnode.create(10000.0,left.resultdef));
               include(left.flags,nf_is_currency);
               typecheckpass(left);
             end;
      end;


    function ttypeconvnode.typecheck_cchar_to_pchar : tnode;

      begin
         result:=nil;
         if is_pwidechar(resultdef) then
          inserttypeconv(left,cwidestringtype)
         else
          inserttypeconv(left,cshortstringtype);
         { evaluate again, reset resultdef so the convert_typ
           will be calculated again and cstring_to_pchar will
           be used for futher conversion }
         convtype:=tc_none;
         result:=pass_typecheck;
      end;


    function ttypeconvnode.typecheck_cstring_to_pchar : tnode;

      begin
         result:=nil;
         if is_pwidechar(resultdef) then
           inserttypeconv(left,cwidestringtype)
         else
           if is_pchar(resultdef) and
              is_widestring(left.resultdef) then
             inserttypeconv(left,cansistringtype);
      end;


    function ttypeconvnode.typecheck_cstring_to_int : tnode;
      var
        fcc : cardinal;
        pb  : pbyte;
      begin
         result:=nil;
         if left.nodetype<>stringconstn then
           internalerror(200510012);
         if tstringconstnode(left).len=4 then
           begin
             pb:=pbyte(tstringconstnode(left).value_str);
             fcc:=(pb[0] shl 24) or (pb[1] shl 16) or (pb[2] shl 8) or pb[3];
             result:=cordconstnode.create(fcc,u32inttype,false);
           end
         else
           CGMessage2(type_e_illegal_type_conversion,left.resultdef.GetTypeName,resultdef.GetTypeName);
      end;


    function ttypeconvnode.typecheck_arrayconstructor_to_set : tnode;

      var
        hp : tnode;

      begin
        result:=nil;
        if left.nodetype<>arrayconstructorn then
         internalerror(5546);
        { remove typeconv node }
        hp:=left;
        left:=nil;
        { create a set constructor tree }
        arrayconstructor_to_set(hp);
        result:=hp;
      end;


    function ttypeconvnode.typecheck_pchar_to_string : tnode;

      begin
        result := ccallnode.createinternres(
          'fpc_pchar_to_'+tstringdef(resultdef).stringtypname,
          ccallparanode.create(left,nil),resultdef);
        left := nil;
      end;


    function ttypeconvnode.typecheck_interface_to_guid : tnode;

      begin
        if assigned(tobjectdef(left.resultdef).iidguid) then
          result:=cguidconstnode.create(tobjectdef(left.resultdef).iidguid^);
      end;


    function ttypeconvnode.typecheck_dynarray_to_openarray : tnode;

      begin
        { a dynamic array is a pointer to an array, so to convert it to }
        { an open array, we have to dereference it (JM)                 }
        result := ctypeconvnode.create_internal(left,voidpointertype);
        typecheckpass(result);
        { left is reused }
        left := nil;
        result := cderefnode.create(result);
        include(result.flags,nf_no_checkpointer);
        result.resultdef := resultdef;
      end;


    function ttypeconvnode.typecheck_pwchar_to_string : tnode;

      begin
        result := ccallnode.createinternres(
          'fpc_pwidechar_to_'+tstringdef(resultdef).stringtypname,
          ccallparanode.create(left,nil),resultdef);
        left := nil;
      end;


    function ttypeconvnode.typecheck_variant_to_dynarray : tnode;

      begin
        result := ccallnode.createinternres(
          'fpc_variant_to_dynarray',
          ccallparanode.create(caddrnode.create_internal(crttinode.create(tstoreddef(resultdef),initrtti)),
            ccallparanode.create(left,nil)
          ),resultdef);
        typecheckpass(result);
        left:=nil;
      end;


    function ttypeconvnode.typecheck_dynarray_to_variant : tnode;

      begin
        result := ccallnode.createinternres(
          'fpc_dynarray_to_variant',
          ccallparanode.create(caddrnode.create_internal(crttinode.create(tstoreddef(left.resultdef),initrtti)),
            ccallparanode.create(ctypeconvnode.create_explicit(left,voidpointertype),nil)
          ),resultdef);
        typecheckpass(result);
        left:=nil;
      end;


    function ttypeconvnode.typecheck_variant_to_interface : tnode;
      begin
        result := ccallnode.createinternres(
          'fpc_variant_to_interface',
            ccallparanode.create(left,nil)
          ,resultdef);
        typecheckpass(result);
        left:=nil;
      end;


    function ttypeconvnode.typecheck_interface_to_variant : tnode;
      begin
        result := ccallnode.createinternres(
          'fpc_interface_to_variant',
            ccallparanode.create(left,nil)
          ,resultdef);
        typecheckpass(result);
        left:=nil;
      end;


    function ttypeconvnode.typecheck_variant_to_enum : tnode;

      begin
        result := ctypeconvnode.create_internal(left,sinttype);
        result := ctypeconvnode.create_internal(result,resultdef);
        typecheckpass(result);
        { left is reused }
        left := nil;
      end;


    function ttypeconvnode.typecheck_enum_to_variant : tnode;

      begin
        result := ctypeconvnode.create_internal(left,sinttype);
        result := ctypeconvnode.create_internal(result,cvarianttype);
        typecheckpass(result);
        { left is reused }
        left := nil;
      end;


    function ttypeconvnode.typecheck_array_2_dynarray : tnode;
      var
        newstatement : tstatementnode;
        temp         : ttempcreatenode;
        temp2        : ttempcreatenode;
      begin
        { create statements with call to getmem+initialize }
        result:=internalstatements(newstatement);

        { create temp for result }
        temp:=ctempcreatenode.create(resultdef,resultdef.size,tt_persistent,true);
        addstatement(newstatement,temp);

        { get temp for array of lengths }
        temp2:=ctempcreatenode.create(sinttype,sinttype.size,tt_persistent,false);
        addstatement(newstatement,temp2);

        { one dimensional }
        addstatement(newstatement,cassignmentnode.create(
            ctemprefnode.create_offset(temp2,0),
            cordconstnode.create
               (tarraydef(left.resultdef).highrange+1,s32inttype,true)));
        { create call to fpc_dynarr_setlength }
        addstatement(newstatement,ccallnode.createintern('fpc_dynarray_setlength',
            ccallparanode.create(caddrnode.create_internal
                  (ctemprefnode.create(temp2)),
               ccallparanode.create(cordconstnode.create
                  (1,s32inttype,true),
               ccallparanode.create(caddrnode.create_internal
                  (crttinode.create(tstoreddef(resultdef),initrtti)),
               ccallparanode.create(
                 ctypeconvnode.create_internal(
                   ctemprefnode.create(temp),voidpointertype),
                 nil))))

          ));
        addstatement(newstatement,ctempdeletenode.create(temp2));

        { copy ... }
        addstatement(newstatement,cassignmentnode.create(
          ctypeconvnode.create_internal(cderefnode.create(ctypeconvnode.create_internal(ctemprefnode.create(temp),voidpointertype)),left.resultdef),
          left
        ));
        { left is reused }
        left:=nil;
        { the last statement should return the value as
          location and type, this is done be referencing the
          temp and converting it first from a persistent temp to
          normal temp }
        addstatement(newstatement,ctempdeletenode.create_normal_temp(temp));
        addstatement(newstatement,ctemprefnode.create(temp));
      end;


    procedure copyparasym(p:TNamedIndexItem;arg:pointer);
      var
        newparast : tsymtable absolute arg;
        vs : tparavarsym;
      begin
        if tsym(p).typ<>paravarsym then
          exit;
        with tparavarsym(p) do
          begin
            vs:=tparavarsym.create(realname,paranr,varspez,vardef,varoptions);
            vs.defaultconstsym:=defaultconstsym;
            newparast.insert(vs);
          end;
      end;


    function ttypeconvnode.typecheck_proc_to_procvar : tnode;
      var
        pd : tabstractprocdef;
      begin
        result:=nil;
        pd:=tabstractprocdef(left.resultdef);

        { create procvardef }
        resultdef:=tprocvardef.create(pd.parast.symtablelevel);
        tprocvardef(resultdef).proctypeoption:=pd.proctypeoption;
        tprocvardef(resultdef).proccalloption:=pd.proccalloption;
        tprocvardef(resultdef).procoptions:=pd.procoptions;
        tprocvardef(resultdef).returndef:=pd.returndef;

        { method ? then set the methodpointer flag }
        if (pd.owner.symtabletype=objectsymtable) then
          include(tprocvardef(resultdef).procoptions,po_methodpointer);

        { was it a local procedure? }
        if (pd.owner.symtabletype=localsymtable) then
          include(tprocvardef(resultdef).procoptions,po_local);

        { only need the address of the method? this is needed
          for @tobject.create. In this case there will be a loadn without
          a methodpointer. }
        if (left.nodetype=loadn) and
           not assigned(tloadnode(left).left) then
          include(tprocvardef(resultdef).procoptions,po_addressonly);

        { Add parameters use only references, we don't need to keep the
          parast. We use the parast from the original function to calculate
          our parameter data and reset it afterwards }
        pd.parast.foreach_static(@copyparasym,tprocvardef(resultdef).parast);
        tprocvardef(resultdef).calcparas;
      end;


    function ttypeconvnode.typecheck_call_helper(c : tconverttype) : tnode;
      const
         resultdefconvert : array[tconverttype] of pointer = (
          {none} nil,
          {equal} nil,
          {not_possible} nil,
          { string_2_string } @ttypeconvnode.typecheck_string_to_string,
          { char_2_string } @ttypeconvnode.typecheck_char_to_string,
          { char_2_chararray } @ttypeconvnode.typecheck_char_to_chararray,
          { pchar_2_string } @ttypeconvnode.typecheck_pchar_to_string,
          { cchar_2_pchar } @ttypeconvnode.typecheck_cchar_to_pchar,
          { cstring_2_pchar } @ttypeconvnode.typecheck_cstring_to_pchar,
          { cstring_2_int } @ttypeconvnode.typecheck_cstring_to_int,
          { ansistring_2_pchar } nil,
          { string_2_chararray } @ttypeconvnode.typecheck_string_to_chararray,
          { chararray_2_string } @ttypeconvnode.typecheck_chararray_to_string,
          { array_2_pointer } nil,
          { pointer_2_array } nil,
          { int_2_int } @ttypeconvnode.typecheck_int_to_int,
          { int_2_bool } nil,
          { int_2_string } @ttypeconvnode.typecheck_int_to_string,
          { bool_2_bool } nil,
          { bool_2_int } nil,
          { real_2_real } @ttypeconvnode.typecheck_real_to_real,
          { int_2_real } @ttypeconvnode.typecheck_int_to_real,
          { real_2_currency } @ttypeconvnode.typecheck_real_to_currency,
          { proc_2_procvar } @ttypeconvnode.typecheck_proc_to_procvar,
          { arrayconstructor_2_set } @ttypeconvnode.typecheck_arrayconstructor_to_set,
          { load_smallset } nil,
          { cord_2_pointer } @ttypeconvnode.typecheck_cord_to_pointer,
          { intf_2_string } nil,
          { intf_2_guid } @ttypeconvnode.typecheck_interface_to_guid,
          { class_2_intf } nil,
          { char_2_char } @ttypeconvnode.typecheck_char_to_char,
          { normal_2_smallset} nil,
          { dynarray_2_openarray} @ttypeconvnode.typecheck_dynarray_to_openarray,
          { pwchar_2_string} @ttypeconvnode.typecheck_pwchar_to_string,
          { variant_2_dynarray} @ttypeconvnode.typecheck_variant_to_dynarray,
          { dynarray_2_variant} @ttypeconvnode.typecheck_dynarray_to_variant,
          { variant_2_enum} @ttypeconvnode.typecheck_variant_to_enum,
          { enum_2_variant} @ttypeconvnode.typecheck_enum_to_variant,
          { variant_2_interface} @ttypeconvnode.typecheck_interface_to_variant,
          { interface_2_variant} @ttypeconvnode.typecheck_variant_to_interface,
          { array_2_dynarray} @ttypeconvnode.typecheck_array_2_dynarray
         );
      type
         tprocedureofobject = function : tnode of object;
      var
         r : packed record
                proc : pointer;
                obj : pointer;
             end;
      begin
         result:=nil;
         { this is a little bit dirty but it works }
         { and should be quite portable too        }
         r.proc:=resultdefconvert[c];
         r.obj:=self;
         if assigned(r.proc) then
          result:=tprocedureofobject(r)();
      end;


    function ttypeconvnode.pass_typecheck:tnode;

      var
        hdef : tdef;
        hp : tnode;
        currprocdef : tabstractprocdef;
        aprocdef : tprocdef;
        eq : tequaltype;
        cdoptions : tcompare_defs_options;
      begin
        result:=nil;
        resultdef:=totypedef;

        typecheckpass(left);
        if codegenerror then
         exit;

        { When absolute force tc_equal }
        if (nf_absolute in flags) then
          begin
            convtype:=tc_equal;
            if not(tstoreddef(resultdef).is_intregable) and
               not(tstoreddef(resultdef).is_fpuregable) then
              make_not_regable(left,vr_addr);
            exit;
          end;

        { tp procvar support. Skip typecasts to procvar, record or set. Those
          convert on the procvar value. This is used to access the
          fields of a methodpointer }
        if not(nf_load_procvar in flags) and
           not(resultdef.deftype in [procvardef,recorddef,setdef]) then
          maybe_call_procvar(left,true);

        { convert array constructors to sets, because there is no conversion
          possible for array constructors }
        if (resultdef.deftype<>arraydef) and
           is_array_constructor(left.resultdef) then
          begin
            arrayconstructor_to_set(left);
            typecheckpass(left);
          end;

        if convtype=tc_none then
          begin
            cdoptions:=[cdo_check_operator,cdo_allow_variant];
            if nf_explicit in flags then
              include(cdoptions,cdo_explicit);
            if nf_internal in flags then
              include(cdoptions,cdo_internal);
            eq:=compare_defs_ext(left.resultdef,resultdef,left.nodetype,convtype,aprocdef,cdoptions);
            case eq of
              te_exact,
              te_equal :
                begin
                  result := simplify;
                  if assigned(result) then
                    exit;

                  { because is_equal only checks the basetype for sets we need to
                    check here if we are loading a smallset into a normalset }
                  if (resultdef.deftype=setdef) and
                     (left.resultdef.deftype=setdef) and
                     ((tsetdef(resultdef).settype = smallset) xor
                      (tsetdef(left.resultdef).settype = smallset)) then
                    begin
                      { constant sets can be converted by changing the type only }
                      if (left.nodetype=setconstn) then
                       begin
                         left.resultdef:=resultdef;
                         result:=left;
                         left:=nil;
                         exit;
                       end;

                      if (tsetdef(resultdef).settype <> smallset) then
                       convtype:=tc_load_smallset
                      else
                       convtype := tc_normal_2_smallset;
                      exit;
                    end
                  else
                   begin
                     { Only leave when there is no conversion to do.
                       We can still need to call a conversion routine,
                       like the routine to convert a stringconstnode }
                     if convtype in [tc_equal,tc_not_possible] then
                      begin
                        left.resultdef:=resultdef;
                        if (nf_explicit in flags) and (left.nodetype = addrn) then
                          include(left.flags, nf_typedaddr);
                        result:=left;
                        left:=nil;
                        exit;
                      end;
                   end;
                end;

              te_convert_l1,
              te_convert_l2,
              te_convert_l3 :
                begin
                  result := simplify;
                  if assigned(result) then
                    exit;
                  { nothing to do }
                end;

              te_convert_operator :
                begin
                  include(current_procinfo.flags,pi_do_call);
                  inc(aprocdef.procsym.refs);
                  hp:=ccallnode.create(ccallparanode.create(left,nil),Tprocsym(aprocdef.procsym),nil,nil,[]);
                  { tell explicitly which def we must use !! (PM) }
                  tcallnode(hp).procdefinition:=aprocdef;
                  left:=nil;
                  result:=hp;
                  exit;
                end;

              te_incompatible :
                begin
                  { Procedures have a resultdef of voiddef and functions of their
                    own resultdef. They will therefore always be incompatible with
                    a procvar. Because isconvertable cannot check for procedures we
                    use an extra check for them.}
                  if (left.nodetype=calln) and
                     (tcallnode(left).para_count=0) and
                     (resultdef.deftype=procvardef) and
                     (
                      (m_tp_procvar in current_settings.modeswitches) or
                      (m_mac_procvar in current_settings.modeswitches)
                     ) then
                   begin
                     if assigned(tcallnode(left).right) then
                      begin
                        { this is already a procvar, if it is really equal
                          is checked below }
                        convtype:=tc_equal;
                        hp:=tcallnode(left).right.getcopy;
                        currprocdef:=tabstractprocdef(hp.resultdef);
                      end
                     else
                      begin
                        convtype:=tc_proc_2_procvar;
                        currprocdef:=Tprocsym(Tcallnode(left).symtableprocentry).search_procdef_byprocvardef(Tprocvardef(resultdef));
                        hp:=cloadnode.create_procvar(tprocsym(tcallnode(left).symtableprocentry),
                            tprocdef(currprocdef),tcallnode(left).symtableproc);
                        if (tcallnode(left).symtableprocentry.owner.symtabletype=objectsymtable) then
                         begin
                           if assigned(tcallnode(left).methodpointer) then
                             tloadnode(hp).set_mp(tcallnode(left).get_load_methodpointer)
                           else
                             tloadnode(hp).set_mp(load_self_node);
                         end;
                        typecheckpass(hp);
                      end;
                     left.free;
                     left:=hp;
                     { Now check if the procedure we are going to assign to
                       the procvar, is compatible with the procvar's type }
                     if not(nf_explicit in flags) and
                        (proc_to_procvar_equal(currprocdef,tprocvardef(resultdef))=te_incompatible) then
                       IncompatibleTypes(left.resultdef,resultdef);
                     exit;
                   end;

                  { Handle explicit type conversions }
                  if nf_explicit in flags then
                   begin
                     { do common tc_equal cast }
                     convtype:=tc_equal;

                     { ordinal constants can be resized to 1,2,4,8 bytes }
                     if (left.nodetype=ordconstn) then
                       begin
                         { Insert typeconv for ordinal to the correct size first on left, after
                           that the other conversion can be done }
                         hdef:=nil;
                         case longint(resultdef.size) of
                           1 :
                             hdef:=s8inttype;
                           2 :
                             hdef:=s16inttype;
                           4 :
                             hdef:=s32inttype;
                           8 :
                             hdef:=s64inttype;
                         end;
                         { we need explicit, because it can also be an enum }
                         if assigned(hdef) then
                           inserttypeconv_internal(left,hdef)
                         else
                           CGMessage2(type_e_illegal_type_conversion,left.resultdef.GetTypeName,resultdef.GetTypeName);
                       end;

                     { check if the result could be in a register }
                     if (not(tstoreddef(resultdef).is_intregable) and
                         not(tstoreddef(resultdef).is_fpuregable)) or
                        ((left.resultdef.deftype = floatdef) and
                         (resultdef.deftype <> floatdef))  then
                       make_not_regable(left,vr_addr);

                     { class/interface to class/interface, with checkobject support }
                     if is_class_or_interface(resultdef) and
                        is_class_or_interface(left.resultdef) then
                       begin
                         { check if the types are related }
                         if not(nf_internal in flags) and
                            (not(tobjectdef(left.resultdef).is_related(tobjectdef(resultdef)))) and
                            (not(tobjectdef(resultdef).is_related(tobjectdef(left.resultdef)))) then
                           begin
                             { Give an error when typecasting class to interface, this is compatible
                               with delphi }
                             if is_interface(resultdef) and
                                not is_interface(left.resultdef) then
                               CGMessage2(type_e_classes_not_related,
                                 FullTypeName(left.resultdef,resultdef),
                                 FullTypeName(resultdef,left.resultdef))
                             else
                               CGMessage2(type_w_classes_not_related,
                                 FullTypeName(left.resultdef,resultdef),
                                 FullTypeName(resultdef,left.resultdef))
                           end;

                         { Add runtime check? }
                         if (cs_check_object in current_settings.localswitches) then
                           begin
                             { we can translate the typeconvnode to 'as' when
                               typecasting to a class or interface }
                             hp:=casnode.create(left,cloadvmtaddrnode.create(ctypenode.create(resultdef)));
                             left:=nil;
                             result:=hp;
                             exit;
                           end;
                       end

                      else
                       begin
                         { only if the same size or formal def }
                         if not(
                                (left.resultdef.deftype=formaldef) or
                                (
                                 not(is_open_array(left.resultdef)) and
                                 not(is_array_constructor(left.resultdef)) and
                                 (left.resultdef.size=resultdef.size)
                                ) or
                                (
                                 is_void(left.resultdef)  and
                                 (left.nodetype=derefn)
                                )
                               ) then
                           CGMessage2(type_e_illegal_type_conversion,left.resultdef.GetTypeName,resultdef.GetTypeName);
                       end;
                   end
                  else
                   IncompatibleTypes(left.resultdef,resultdef);
                end;

              else
                internalerror(200211231);
            end;
          end;
        { Give hint or warning for unportable code, exceptions are
           - typecasts from constants
           - void }
        if not(nf_internal in flags) and
           (left.nodetype<>ordconstn) and
           not(is_void(left.resultdef)) and
           (((left.resultdef.deftype=orddef) and
             (resultdef.deftype in [pointerdef,procvardef,classrefdef])) or
            ((resultdef.deftype=orddef) and
             (left.resultdef.deftype in [pointerdef,procvardef,classrefdef]))) then
          begin
            { Give a warning when sizes don't match, because then info will be lost }
            if left.resultdef.size=resultdef.size then
              CGMessage(type_h_pointer_to_longint_conv_not_portable)
            else
              CGMessage(type_w_pointer_to_longint_conv_not_portable);
          end;

        result := simplify;
        if assigned(result) then
          exit;

        { now call the resultdef helper to do constant folding }
        result:=typecheck_call_helper(convtype);
      end;


    function ttypeconvnode.simplify: tnode;
      var
        hp: tnode;
      begin
        result := nil;
        { Constant folding and other node transitions to
          remove the typeconv node }
        case left.nodetype of
          realconstn :
            begin
              if (convtype = tc_real_2_currency) then
                result := typecheck_real_to_currency
              else if (convtype = tc_real_2_real) then
                result := typecheck_real_to_real
              else
                exit;
              if not(assigned(result)) then
                begin
                  result := left;
                  left := nil;
                end;
              if (result.nodetype = realconstn) then
                begin
                  result:=crealconstnode.create(trealconstnode(result).value_real,resultdef);
                  if ([nf_explicit,nf_internal] * flags <> []) then
                    include(result.flags, nf_explicit);
                end;
            end;
          niln :
            begin
              { nil to ordinal node }
              if (resultdef.deftype=orddef) then
               begin
                 hp:=cordconstnode.create(0,resultdef,true);
                 if ([nf_explicit,nf_internal] * flags <> []) then
                   include(hp.flags, nf_explicit);
                 result:=hp;
                 exit;
               end
              else
               { fold nil to any pointer type }
               if (resultdef.deftype=pointerdef) then
                begin
                  hp:=cnilnode.create;
                  hp.resultdef:=resultdef;
                  if ([nf_explicit,nf_internal] * flags <> []) then
                    include(hp.flags, nf_explicit);
                  result:=hp;
                  exit;
                end
              else
               { remove typeconv after niln, but not when the result is a
                 methodpointer. The typeconv of the methodpointer will then
                 take care of updateing size of niln to OS_64 }
               if not((resultdef.deftype=procvardef) and
                      (po_methodpointer in tprocvardef(resultdef).procoptions)) then
                 begin
                   left.resultdef:=resultdef;
                   if ([nf_explicit,nf_internal] * flags <> []) then
                     include(left.flags, nf_explicit);
                   result:=left;
                   left:=nil;
                   exit;
                 end;
            end;

          ordconstn :
            begin
              { ordinal contants can be directly converted }
              { but not char to char because it is a widechar to char or via versa }
              { which needs extra code to do the code page transistion             }
              { constant ordinal to pointer }
              if (resultdef.deftype=pointerdef) and
                 (convtype<>tc_cchar_2_pchar) then
                begin
                   hp:=cpointerconstnode.create(TConstPtrUInt(tordconstnode(left).value),resultdef);
                   if ([nf_explicit,nf_internal] * flags <> []) then
                     include(hp.flags, nf_explicit);
                   result:=hp;
                   exit;
                end
              else if is_ordinal(resultdef) and
                      not(convtype=tc_char_2_char) then
                begin
                   { replace the resultdef and recheck the range }
                   left.resultdef:=resultdef;
                   if ([nf_explicit,nf_internal] * flags <> []) then
                     include(left.flags, nf_explicit);
                   testrange(left.resultdef,tordconstnode(left).value,(nf_explicit in flags));
                   result:=left;
                   left:=nil;
                   exit;
                end;
            end;

          pointerconstn :
            begin
              { pointerconstn to any pointer is folded too }
              if (resultdef.deftype=pointerdef) then
                begin
                   left.resultdef:=resultdef;
                   if ([nf_explicit,nf_internal] * flags <> []) then
                     include(left.flags, nf_explicit);
                   result:=left;
                   left:=nil;
                   exit;
                end
              { constant pointer to ordinal }
              else if is_ordinal(resultdef) then
                begin
                   hp:=cordconstnode.create(TConstExprInt(tpointerconstnode(left).value),
                     resultdef,not(nf_explicit in flags));
                   if ([nf_explicit,nf_internal] * flags <> []) then
                     include(hp.flags, nf_explicit);
                   result:=hp;
                   exit;
                end;
            end;
        end;
      end;


      procedure Ttypeconvnode.mark_write;

      begin
        left.mark_write;
      end;

    function ttypeconvnode.first_cord_to_pointer : tnode;

      begin
        result:=nil;
        internalerror(200104043);
      end;


    function ttypeconvnode.first_int_to_int : tnode;

      begin
        first_int_to_int:=nil;
        expectloc:=left.expectloc;
        if not is_void(left.resultdef) then
          begin
            if (left.expectloc<>LOC_REGISTER) and
               (resultdef.size>left.resultdef.size) then
              expectloc:=LOC_REGISTER
            else
              if (left.expectloc=LOC_CREGISTER) and
                 (resultdef.size<left.resultdef.size) then
                expectloc:=LOC_REGISTER;
          end;
{$ifndef cpu64bit}
        if is_64bit(resultdef) then
          registersint:=max(registersint,2)
        else
{$endif cpu64bit}
          registersint:=max(registersint,1);
      end;


    function ttypeconvnode.first_cstring_to_pchar : tnode;

      begin
         result:=nil;
         registersint:=1;
         expectloc:=LOC_REGISTER;
      end;


    function ttypeconvnode.first_cstring_to_int : tnode;

      begin
        result:=nil;
        internalerror(200510014);
      end;


    function ttypeconvnode.first_string_to_chararray : tnode;

      begin
         first_string_to_chararray:=nil;
         expectloc:=left.expectloc;
      end;


    function ttypeconvnode.first_char_to_string : tnode;

      begin
         first_char_to_string:=nil;
         expectloc:=LOC_REFERENCE;
      end;


    function ttypeconvnode.first_nothing : tnode;
      begin
         first_nothing:=nil;
      end;


    function ttypeconvnode.first_array_to_pointer : tnode;

      begin
         first_array_to_pointer:=nil;
         if registersint<1 then
           registersint:=1;
         expectloc:=LOC_REGISTER;
      end;


    function ttypeconvnode.first_int_to_real: tnode;
      var
        fname: string[32];
        typname : string[12];
      begin
        { Get the type name  }
        {  Normally the typename should be one of the following:
            single, double - carl
        }
        typname := lower(pbestrealtype^.GetTypeName);
        { converting a 64bit integer to a float requires a helper }
        if is_64bit(left.resultdef) then
          begin
            if is_signed(left.resultdef) then
              fname := 'fpc_int64_to_'+typname
            else
{$warning generic conversion from int to float does not support unsigned integers}
              fname := 'fpc_int64_to_'+typname;
            result := ccallnode.createintern(fname,ccallparanode.create(
              left,nil));
            left:=nil;
            firstpass(result);
            exit;
          end
        else
          { other integers are supposed to be 32 bit }
          begin
{$warning generic conversion from int to float does not support unsigned integers}
            if is_signed(left.resultdef) then
              fname := 'fpc_longint_to_'+typname
            else
              fname := 'fpc_longint_to_'+typname;
            result := ccallnode.createintern(fname,ccallparanode.create(
              left,nil));
            left:=nil;
            firstpass(result);
            exit;
          end;
      end;


    function ttypeconvnode.first_real_to_real : tnode;
      begin
{$ifdef cpufpemu}
        if cs_fp_emulation in current_settings.moduleswitches then
          begin
            if target_info.system in system_wince then
              begin
                case tfloatdef(left.resultdef).typ of
                  s32real:
                    case tfloatdef(resultdef).typ of
                      s64real:
                        result:=ccallnode.createintern('STOD',ccallparanode.create(left,nil));
                      s32real:
                        begin
                          result:=left;
                          left:=nil;
                        end;
                      else
                        internalerror(2005082704);
                    end;
                  s64real:
                    case tfloatdef(resultdef).typ of
                      s32real:
                        result:=ccallnode.createintern('DTOS',ccallparanode.create(left,nil));
                      s64real:
                        begin
                          result:=left;
                          left:=nil;
                        end;
                      else
                        internalerror(2005082703);
                    end;
                  else
                    internalerror(2005082702);
                end;
                left:=nil;
                firstpass(result);
                exit;
              end
            else
              begin
                case tfloatdef(left.resultdef).typ of
                  s32real:
                    case tfloatdef(resultdef).typ of
                      s64real:
                        result:=ctypeconvnode.create_explicit(ccallnode.createintern('float32_to_float64',ccallparanode.create(
                          ctypeconvnode.create_internal(left,search_system_type('FLOAT32REC').typedef),nil)),resultdef);
                      s32real:
                        begin
                          result:=left;
                          left:=nil;
                        end;
                      else
                        internalerror(200610151);
                    end;
                  s64real:
                    case tfloatdef(resultdef).typ of
                      s32real:
                        result:=ctypeconvnode.create_explicit(ccallnode.createintern('float64_to_float32',ccallparanode.create(
                          ctypeconvnode.create_internal(left,search_system_type('FLOAT64').typedef),nil)),resultdef);
                      s64real:
                        begin
                          result:=left;
                          left:=nil;
                        end;
                      else
                        internalerror(200610152);
                    end;
                  else
                    internalerror(200610153);
                end;
                left:=nil;
                firstpass(result);
                exit;
              end;
          end
        else
{$endif cpufpemu}
          begin
            first_real_to_real:=nil;
            if registersfpu<1 then
              registersfpu:=1;
            expectloc:=LOC_FPUREGISTER;
          end;
      end;


    function ttypeconvnode.first_pointer_to_array : tnode;

      begin
         first_pointer_to_array:=nil;
         if registersint<1 then
           registersint:=1;
         expectloc:=LOC_REFERENCE;
      end;


    function ttypeconvnode.first_cchar_to_pchar : tnode;

      begin
         first_cchar_to_pchar:=nil;
         internalerror(200104021);
      end;


    function ttypeconvnode.first_bool_to_int : tnode;

      begin
         first_bool_to_int:=nil;
         { byte(boolean) or word(wordbool) or longint(longbool) must
         be accepted for var parameters }
         if (nf_explicit in flags) and
            (left.resultdef.size=resultdef.size) and
            (left.expectloc in [LOC_REFERENCE,LOC_CREFERENCE,LOC_CREGISTER]) then
           exit;
         { when converting to 64bit, first convert to a 32bit int and then   }
         { convert to a 64bit int (only necessary for 32bit processors) (JM) }
         if resultdef.size > sizeof(aint) then
           begin
             result := ctypeconvnode.create_internal(left,u32inttype);
             result := ctypeconvnode.create(result,resultdef);
             left := nil;
             firstpass(result);
             exit;
           end;
         expectloc:=LOC_REGISTER;
         if registersint<1 then
           registersint:=1;
      end;


    function ttypeconvnode.first_int_to_bool : tnode;

      begin
         first_int_to_bool:=nil;
         { byte(boolean) or word(wordbool) or longint(longbool) must
         be accepted for var parameters }
         if (nf_explicit in flags) and
            (left.resultdef.size=resultdef.size) and
            (left.expectloc in [LOC_REFERENCE,LOC_CREFERENCE,LOC_CREGISTER]) then
           exit;
         expectloc:=LOC_REGISTER;
         { need if bool to bool !!
           not very nice !!
         insertypeconv(left,s32inttype);
         left.explizit:=true;
         firstpass(left);  }
         if registersint<1 then
           registersint:=1;
      end;


    function ttypeconvnode.first_bool_to_bool : tnode;
      begin
         first_bool_to_bool:=nil;
         if (left.expectloc in [LOC_FLAGS,LOC_JUMP]) then
           expectloc := left.expectloc
         else
           begin
             expectloc:=LOC_REGISTER;
             if registersint<1 then
               registersint:=1;
           end;
      end;


    function ttypeconvnode.first_char_to_char : tnode;

      begin
         first_char_to_char:=first_int_to_int;
      end;


    function ttypeconvnode.first_proc_to_procvar : tnode;
      begin
         first_proc_to_procvar:=nil;
         if tabstractprocdef(resultdef).is_addressonly then
          begin
            registersint:=left.registersint;
            if registersint<1 then
              registersint:=1;
            expectloc:=LOC_REGISTER;
          end
         else
          begin
            if not(left.expectloc in [LOC_CREFERENCE,LOC_REFERENCE]) then
              CGMessage(parser_e_illegal_expression);
            registersint:=left.registersint;
            expectloc:=left.expectloc
          end
      end;


    function ttypeconvnode.first_load_smallset : tnode;

      var
        srsym: ttypesym;
        p: tcallparanode;

      begin
        srsym:=search_system_type('FPC_SMALL_SET');
        p := ccallparanode.create(left,nil);
        { reused }
        left := nil;
        { convert parameter explicitely to fpc_small_set }
        p.left := ctypeconvnode.create_internal(p.left,srsym.typedef);
        { create call, adjust resultdef }
        result :=
          ccallnode.createinternres('fpc_set_load_small',p,resultdef);
        firstpass(result);
      end;


    function ttypeconvnode.first_ansistring_to_pchar : tnode;

      begin
         first_ansistring_to_pchar:=nil;
         expectloc:=LOC_REGISTER;
         if registersint<1 then
           registersint:=1;
      end;


    function ttypeconvnode.first_arrayconstructor_to_set : tnode;
      begin
        first_arrayconstructor_to_set:=nil;
        internalerror(200104022);
      end;

    function ttypeconvnode.first_class_to_intf : tnode;

      begin
         first_class_to_intf:=nil;
         expectloc:=LOC_REGISTER;
         if registersint<1 then
           registersint:=1;
      end;

    function ttypeconvnode._first_int_to_int : tnode;
      begin
         result:=first_int_to_int;
      end;

    function ttypeconvnode._first_cstring_to_pchar : tnode;
      begin
         result:=first_cstring_to_pchar;
      end;

    function ttypeconvnode._first_cstring_to_int : tnode;
      begin
         result:=first_cstring_to_int;
      end;

    function ttypeconvnode._first_string_to_chararray : tnode;
      begin
         result:=first_string_to_chararray;
      end;

    function ttypeconvnode._first_char_to_string : tnode;
      begin
         result:=first_char_to_string;
      end;

    function ttypeconvnode._first_nothing : tnode;
      begin
         result:=first_nothing;
      end;

    function ttypeconvnode._first_array_to_pointer : tnode;
      begin
         result:=first_array_to_pointer;
      end;

    function ttypeconvnode._first_int_to_real : tnode;
      begin
         result:=first_int_to_real;
      end;

    function ttypeconvnode._first_real_to_real : tnode;
      begin
         result:=first_real_to_real;
      end;

    function ttypeconvnode._first_pointer_to_array : tnode;
      begin
         result:=first_pointer_to_array;
      end;

    function ttypeconvnode._first_cchar_to_pchar : tnode;
      begin
         result:=first_cchar_to_pchar;
      end;

    function ttypeconvnode._first_bool_to_int : tnode;
      begin
         result:=first_bool_to_int;
      end;

    function ttypeconvnode._first_int_to_bool : tnode;
      begin
         result:=first_int_to_bool;
      end;

    function ttypeconvnode._first_bool_to_bool : tnode;
      begin
         result:=first_bool_to_bool;
      end;

    function ttypeconvnode._first_proc_to_procvar : tnode;
      begin
         result:=first_proc_to_procvar;
      end;

    function ttypeconvnode._first_load_smallset : tnode;
      begin
         result:=first_load_smallset;
      end;

    function ttypeconvnode._first_cord_to_pointer : tnode;
      begin
         result:=first_cord_to_pointer;
      end;

    function ttypeconvnode._first_ansistring_to_pchar : tnode;
      begin
         result:=first_ansistring_to_pchar;
      end;

    function ttypeconvnode._first_arrayconstructor_to_set : tnode;
      begin
         result:=first_arrayconstructor_to_set;
      end;

    function ttypeconvnode._first_class_to_intf : tnode;
      begin
         result:=first_class_to_intf;
      end;

    function ttypeconvnode._first_char_to_char : tnode;
      begin
         result:=first_char_to_char;
      end;

    function ttypeconvnode.first_call_helper(c : tconverttype) : tnode;

      const
         firstconvert : array[tconverttype] of pointer = (
           nil, { none }
           @ttypeconvnode._first_nothing, {equal}
           @ttypeconvnode._first_nothing, {not_possible}
           nil, { removed in typecheck_string_to_string }
           @ttypeconvnode._first_char_to_string,
           @ttypeconvnode._first_nothing, { char_2_chararray, needs nothing extra }
           nil, { removed in typecheck_chararray_to_string }
           @ttypeconvnode._first_cchar_to_pchar,
           @ttypeconvnode._first_cstring_to_pchar,
           @ttypeconvnode._first_cstring_to_int,
           @ttypeconvnode._first_ansistring_to_pchar,
           @ttypeconvnode._first_string_to_chararray,
           nil, { removed in typecheck_chararray_to_string }
           @ttypeconvnode._first_array_to_pointer,
           @ttypeconvnode._first_pointer_to_array,
           @ttypeconvnode._first_int_to_int,
           @ttypeconvnode._first_int_to_bool,
           nil, { removed in typecheck_int_to_string }
           @ttypeconvnode._first_bool_to_bool,
           @ttypeconvnode._first_bool_to_int,
           @ttypeconvnode._first_real_to_real,
           @ttypeconvnode._first_int_to_real,
           nil, { removed in typecheck_real_to_currency }
           @ttypeconvnode._first_proc_to_procvar,
           @ttypeconvnode._first_arrayconstructor_to_set,
           @ttypeconvnode._first_load_smallset,
           @ttypeconvnode._first_cord_to_pointer,
           @ttypeconvnode._first_nothing,
           @ttypeconvnode._first_nothing,
           @ttypeconvnode._first_class_to_intf,
           @ttypeconvnode._first_char_to_char,
           @ttypeconvnode._first_nothing,
           @ttypeconvnode._first_nothing,
           nil,
           nil,
           nil,
           nil,
           nil,
           nil,
           nil,
           nil
         );
      type
         tprocedureofobject = function : tnode of object;

      var
         r : packed record
                proc : pointer;
                obj : pointer;
             end;

      begin
         { this is a little bit dirty but it works }
         { and should be quite portable too        }
         r.proc:=firstconvert[c];
         r.obj:=self;
         if not assigned(r.proc) then
           internalerror(200312081);
         first_call_helper:=tprocedureofobject(r)()
      end;


    function ttypeconvnode.pass_1 : tnode;
      begin
        result:=nil;
        firstpass(left);
        if codegenerror then
         exit;

        { load the value_str from the left part }
        registersint:=left.registersint;
        registersfpu:=left.registersfpu;
{$ifdef SUPPORT_MMX}
        registersmmx:=left.registersmmx;
{$endif}
        expectloc:=left.expectloc;

        result:=first_call_helper(convtype);
      end;


    function ttypeconvnode.assign_allowed:boolean;
      begin
        result:=(convtype=tc_equal) or
                { typecasting from void is always allowed }
                is_void(left.resultdef) or
                (left.resultdef.deftype=formaldef) or
                { int 2 int with same size reuses same location, or for
                  tp7 mode also allow size < orignal size }
                (
                 (convtype=tc_int_2_int) and
                 (
                  (resultdef.size=left.resultdef.size) or
                  ((m_tp7 in current_settings.modeswitches) and
                   (resultdef.size<left.resultdef.size))
                 )
                ) or
                { int 2 bool/bool 2 int, explicit typecast, see also nx86cnv }
                ((convtype in [tc_int_2_bool,tc_bool_2_int]) and
                 (nf_explicit in flags) and
                 (resultdef.size=left.resultdef.size));

        { When using only a part of the value it can't be in a register since
          that will load the value in a new register first }
        if (resultdef.size<left.resultdef.size) then
          make_not_regable(left,vr_addr);
      end;


    function ttypeconvnode.docompare(p: tnode) : boolean;
      begin
        docompare :=
          inherited docompare(p) and
          (convtype = ttypeconvnode(p).convtype);
      end;


    procedure ttypeconvnode._second_int_to_int;
      begin
        second_int_to_int;
      end;


    procedure ttypeconvnode._second_string_to_string;
      begin
        second_string_to_string;
      end;


    procedure ttypeconvnode._second_cstring_to_pchar;
      begin
        second_cstring_to_pchar;
      end;


    procedure ttypeconvnode._second_cstring_to_int;
      begin
        second_cstring_to_int;
      end;


    procedure ttypeconvnode._second_string_to_chararray;
      begin
        second_string_to_chararray;
      end;


    procedure ttypeconvnode._second_array_to_pointer;
      begin
        second_array_to_pointer;
      end;


    procedure ttypeconvnode._second_pointer_to_array;
      begin
        second_pointer_to_array;
      end;


    procedure ttypeconvnode._second_chararray_to_string;
      begin
        second_chararray_to_string;
      end;


    procedure ttypeconvnode._second_char_to_string;
      begin
        second_char_to_string;
      end;


    procedure ttypeconvnode._second_int_to_real;
      begin
        second_int_to_real;
      end;


    procedure ttypeconvnode._second_real_to_real;
      begin
        second_real_to_real;
      end;


    procedure ttypeconvnode._second_cord_to_pointer;
      begin
        second_cord_to_pointer;
      end;


    procedure ttypeconvnode._second_proc_to_procvar;
      begin
        second_proc_to_procvar;
      end;


    procedure ttypeconvnode._second_bool_to_int;
      begin
        second_bool_to_int;
      end;


    procedure ttypeconvnode._second_int_to_bool;
      begin
        second_int_to_bool;
      end;


    procedure ttypeconvnode._second_bool_to_bool;
      begin
        second_bool_to_bool;
      end;

    procedure ttypeconvnode._second_load_smallset;
      begin
        second_load_smallset;
      end;


    procedure ttypeconvnode._second_ansistring_to_pchar;
      begin
        second_ansistring_to_pchar;
      end;


    procedure ttypeconvnode._second_class_to_intf;
      begin
        second_class_to_intf;
      end;


    procedure ttypeconvnode._second_char_to_char;
      begin
        second_char_to_char;
      end;


    procedure ttypeconvnode._second_nothing;
      begin
        second_nothing;
      end;


    procedure ttypeconvnode.second_call_helper(c : tconverttype);
      const
         secondconvert : array[tconverttype] of pointer = (
           @ttypeconvnode._second_nothing, {none}
           @ttypeconvnode._second_nothing, {equal}
           @ttypeconvnode._second_nothing, {not_possible}
           @ttypeconvnode._second_nothing, {second_string_to_string, handled in resultdef pass }
           @ttypeconvnode._second_char_to_string,
           @ttypeconvnode._second_nothing, {char_to_charray}
           @ttypeconvnode._second_nothing, { pchar_to_string, handled in resultdef pass }
           @ttypeconvnode._second_nothing, {cchar_to_pchar}
           @ttypeconvnode._second_cstring_to_pchar,
           @ttypeconvnode._second_cstring_to_int,
           @ttypeconvnode._second_ansistring_to_pchar,
           @ttypeconvnode._second_string_to_chararray,
           @ttypeconvnode._second_nothing, { chararray_to_string, handled in resultdef pass }
           @ttypeconvnode._second_array_to_pointer,
           @ttypeconvnode._second_pointer_to_array,
           @ttypeconvnode._second_int_to_int,
           @ttypeconvnode._second_int_to_bool,
           @ttypeconvnode._second_nothing, { int_to_string, handled in resultdef pass }
           @ttypeconvnode._second_bool_to_bool,
           @ttypeconvnode._second_bool_to_int,
           @ttypeconvnode._second_real_to_real,
           @ttypeconvnode._second_int_to_real,
           @ttypeconvnode._second_nothing, { real_to_currency, handled in resultdef pass }
           @ttypeconvnode._second_proc_to_procvar,
           @ttypeconvnode._second_nothing, { arrayconstructor_to_set }
           @ttypeconvnode._second_nothing, { second_load_smallset, handled in first pass }
           @ttypeconvnode._second_cord_to_pointer,
           @ttypeconvnode._second_nothing, { interface 2 string }
           @ttypeconvnode._second_nothing, { interface 2 guid   }
           @ttypeconvnode._second_class_to_intf,
           @ttypeconvnode._second_char_to_char,
           @ttypeconvnode._second_nothing,  { normal_2_smallset }
           @ttypeconvnode._second_nothing,  { dynarray_2_openarray }
           @ttypeconvnode._second_nothing,  { pwchar_2_string }
           @ttypeconvnode._second_nothing,  { variant_2_dynarray }
           @ttypeconvnode._second_nothing,  { dynarray_2_variant}
           @ttypeconvnode._second_nothing,  { variant_2_enum }
           @ttypeconvnode._second_nothing,  { enum_2_variant }
           @ttypeconvnode._second_nothing,  { variant_2_interface }
           @ttypeconvnode._second_nothing,  { interface_2_variant }
           @ttypeconvnode._second_nothing   { array_2_dynarray }
         );
      type
         tprocedureofobject = procedure of object;

      var
         r : packed record
                proc : pointer;
                obj : pointer;
             end;

      begin
         { this is a little bit dirty but it works }
         { and should be quite portable too        }
         r.proc:=secondconvert[c];
         r.obj:=self;
         tprocedureofobject(r)();
      end;


{*****************************************************************************
                                TISNODE
*****************************************************************************}

    constructor tisnode.create(l,r : tnode);

      begin
         inherited create(isn,l,r);
      end;


    function tisnode.pass_typecheck:tnode;
      var
        paras: tcallparanode;
      begin
         result:=nil;
         typecheckpass(left);
         typecheckpass(right);

         set_varstate(left,vs_read,[vsf_must_be_valid]);
         set_varstate(right,vs_read,[vsf_must_be_valid]);

         if codegenerror then
           exit;

         if (right.resultdef.deftype=classrefdef) then
          begin
            { left must be a class }
            if is_class(left.resultdef) then
             begin
               { the operands must be related }
               if (not(tobjectdef(left.resultdef).is_related(
                  tobjectdef(tclassrefdef(right.resultdef).pointeddef)))) and
                  (not(tobjectdef(tclassrefdef(right.resultdef).pointeddef).is_related(
                  tobjectdef(left.resultdef)))) then
                 CGMessage2(type_e_classes_not_related,left.resultdef.typename,
                            tclassrefdef(right.resultdef).pointeddef.typename);
             end
            else
             CGMessage1(type_e_class_type_expected,left.resultdef.typename);

            { call fpc_do_is helper }
            paras := ccallparanode.create(
                         left,
                     ccallparanode.create(
                         right,nil));
            result := ccallnode.createintern('fpc_do_is',paras);
            left := nil;
            right := nil;
          end
         else if is_interface(right.resultdef) then
          begin
            { left is a class }
            if is_class(left.resultdef) then
             begin
               { the operands must be related }
               if not(assigned(tobjectdef(left.resultdef).implementedinterfaces) and
                      (tobjectdef(left.resultdef).implementedinterfaces.searchintf(right.resultdef)<>-1)) then
                 CGMessage2(type_e_classes_not_related,
                    FullTypeName(left.resultdef,right.resultdef),
                    FullTypeName(right.resultdef,left.resultdef))
             end
            { left is an interface }
            else if is_interface(left.resultdef) then
             begin
               { the operands must be related }
               if (not(tobjectdef(left.resultdef).is_related(tobjectdef(right.resultdef)))) and
                  (not(tobjectdef(right.resultdef).is_related(tobjectdef(left.resultdef)))) then
                 CGMessage2(type_e_classes_not_related,
                    FullTypeName(left.resultdef,right.resultdef),
                    FullTypeName(right.resultdef,left.resultdef));
             end
            else
             CGMessage1(type_e_class_type_expected,left.resultdef.typename);
            { call fpc_do_is helper }
            paras := ccallparanode.create(
                         left,
                     ccallparanode.create(
                         right,nil));
            result := ccallnode.createintern('fpc_do_is',paras);
            left := nil;
            right := nil;
          end
         else
          CGMessage1(type_e_class_or_interface_type_expected,right.resultdef.typename);

         resultdef:=booltype;
      end;


    function tisnode.pass_1 : tnode;
      begin
        internalerror(200204254);
        result:=nil;
      end;

    { dummy pass_2, it will never be called, but we need one since }
    { you can't instantiate an abstract class                      }
    procedure tisnode.pass_generate_code;
      begin
      end;


{*****************************************************************************
                                TASNODE
*****************************************************************************}

    constructor tasnode.create(l,r : tnode);

      begin
         inherited create(asn,l,r);
         call := nil;
      end;


    destructor tasnode.destroy;

      begin
        call.free;
        inherited destroy;
      end;


    function tasnode.pass_typecheck:tnode;
      var
        hp : tnode;
      begin
         result:=nil;
         typecheckpass(right);
         typecheckpass(left);

         set_varstate(right,vs_read,[vsf_must_be_valid]);
         set_varstate(left,vs_read,[vsf_must_be_valid]);

         if codegenerror then
           exit;

         if (right.resultdef.deftype=classrefdef) then
          begin
            { left must be a class }
            if is_class(left.resultdef) then
             begin
               { the operands must be related }
               if (not(tobjectdef(left.resultdef).is_related(
                  tobjectdef(tclassrefdef(right.resultdef).pointeddef)))) and
                  (not(tobjectdef(tclassrefdef(right.resultdef).pointeddef).is_related(
                  tobjectdef(left.resultdef)))) then
                 CGMessage2(type_e_classes_not_related,
                    FullTypeName(left.resultdef,tclassrefdef(right.resultdef).pointeddef),
                    FullTypeName(tclassrefdef(right.resultdef).pointeddef,left.resultdef));
             end
            else
             CGMessage1(type_e_class_type_expected,left.resultdef.typename);
            resultdef:=tclassrefdef(right.resultdef).pointeddef;
          end
         else if is_interface(right.resultdef) then
          begin
            { left is a class }
            if not(is_class(left.resultdef) or
                   is_interfacecom(left.resultdef)) then
              CGMessage1(type_e_class_or_cominterface_type_expected,left.resultdef.typename);

            resultdef:=right.resultdef;

            { load the GUID of the interface }
            if (right.nodetype=typen) then
             begin
               if assigned(tobjectdef(right.resultdef).iidguid) then
                 begin
                   hp:=cguidconstnode.create(tobjectdef(right.resultdef).iidguid^);
                   right.free;
                   right:=hp;
                 end
               else
                 internalerror(200206282);
               typecheckpass(right);
             end;
          end
         else
          CGMessage1(type_e_class_or_interface_type_expected,right.resultdef.typename);
      end;


    function tasnode.dogetcopy: tnode;

      begin
        result := inherited dogetcopy;
        if assigned(call) then
          tasnode(result).call := call.getcopy
        else
          tasnode(result).call := nil;
      end;


    function tasnode.pass_1 : tnode;

      var
        procname: string;
      begin
        result:=nil;
        if not assigned(call) then
          begin
            if is_class(left.resultdef) and
               (right.resultdef.deftype=classrefdef) then
              call := ccallnode.createinternres('fpc_do_as',
                ccallparanode.create(left,ccallparanode.create(right,nil)),
                resultdef)
            else
              begin
                if is_class(left.resultdef) then
                  procname := 'fpc_class_as_intf'
                else
                  procname := 'fpc_intf_as';
                call := ccallnode.createintern(procname,
                   ccallparanode.create(right,ccallparanode.create(left,nil)));
                call := ctypeconvnode.create_internal(call,resultdef);
              end;
            left := nil;
            right := nil;
            firstpass(call);
            if codegenerror then
              exit;
           expectloc:=call.expectloc;
           registersint:=call.registersint;
           registersfpu:=call.registersfpu;
{$ifdef SUPPORT_MMX}
           registersmmx:=call.registersmmx;
{$endif SUPPORT_MMX}
         end;
      end;


begin
   ctypeconvnode:=ttypeconvnode;
   casnode:=tasnode;
   cisnode:=tisnode;
end.
