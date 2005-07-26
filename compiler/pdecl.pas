{
    Copyright (c) 1998-2002 by Florian Klaempfl

    Does declaration (but not type) parsing for Free Pascal

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
unit pdecl;

{$i fpcdefs.inc}

interface

    uses
      { global }
      globals,
      { symtable }
      symsym,
      { pass_1 }
      node;

    function  readconstant(const orgname:string;const filepos:tfileposinfo):tconstsym;

    procedure const_dec;
    procedure label_dec;
    procedure type_dec;
    procedure var_dec;
    procedure threadvar_dec;
    procedure property_dec;
    procedure resourcestring_dec;

implementation

    uses
       { common }
       cutils,cclasses,
       { global }
       globtype,tokens,verbose,widestr,
       systems,
       { aasm }
       aasmbase,aasmtai,fmodule,
       { symtable }
       symconst,symbase,symtype,symdef,symtable,paramgr,defutil,
       { pass 1 }
       nmat,nadd,ncal,nset,ncnv,ninl,ncon,nld,nflw,nobj,
       { codegen }
       ncgutil,
       { parser }
       scanner,
       pbase,pexpr,ptype,ptconst,pdecsub,pdecvar,pdecobj,
       { cpu-information }
       cpuinfo
       ;


    function readconstant(const orgname:string;const filepos:tfileposinfo):tconstsym;
      var
        hp : tconstsym;
        p : tnode;
        ps : pconstset;
        pd : pbestreal;
        pg : pguid;
        sp : pchar;
        pw : pcompilerwidestring;
        storetokenpos : tfileposinfo;
      begin
        readconstant:=nil;
        if orgname='' then
         internalerror(9584582);
        hp:=nil;
        p:=comp_expr(true);
        storetokenpos:=akttokenpos;
        akttokenpos:=filepos;
        case p.nodetype of
           ordconstn:
             begin
               if p.resulttype.def.deftype=pointerdef then
                 hp:=tconstsym.create_ordptr(orgname,constpointer,tordconstnode(p).value,p.resulttype)
               else
                 hp:=tconstsym.create_ord(orgname,constord,tordconstnode(p).value,p.resulttype);
             end;
           stringconstn:
             begin
               if is_widestring(p.resulttype.def) then
                 begin
                   initwidestring(pw);
                   copywidestring(pcompilerwidestring(tstringconstnode(p).value_str),pw);
                   hp:=tconstsym.create_wstring(orgname,constwstring,pw);
                 end
               else
                 begin
                   getmem(sp,tstringconstnode(p).len+1);
                   move(tstringconstnode(p).value_str^,sp^,tstringconstnode(p).len+1);
                   hp:=tconstsym.create_string(orgname,conststring,sp,tstringconstnode(p).len);
                 end;
             end;
           realconstn :
             begin
                new(pd);
                pd^:=trealconstnode(p).value_real;
                hp:=tconstsym.create_ptr(orgname,constreal,pd,p.resulttype);
             end;
           setconstn :
             begin
               new(ps);
               ps^:=tsetconstnode(p).value_set^;
               hp:=tconstsym.create_ptr(orgname,constset,ps,p.resulttype);
             end;
           pointerconstn :
             begin
               hp:=tconstsym.create_ordptr(orgname,constpointer,tpointerconstnode(p).value,p.resulttype);
             end;
           niln :
             begin
               hp:=tconstsym.create_ord(orgname,constnil,0,p.resulttype);
             end;
           typen :
             begin
               if is_interface(p.resulttype.def) then
                begin
                  if assigned(tobjectdef(p.resulttype.def).iidguid) then
                   begin
                     new(pg);
                     pg^:=tobjectdef(p.resulttype.def).iidguid^;
                     hp:=tconstsym.create_ptr(orgname,constguid,pg,p.resulttype);
                   end
                  else
                   Message1(parser_e_interface_has_no_guid,tobjectdef(p.resulttype.def).objrealname^);
                end
               else
                Message(parser_e_illegal_expression);
             end;
           else
             Message(parser_e_illegal_expression);
        end;
        akttokenpos:=storetokenpos;
        p.free;
        readconstant:=hp;
      end;


    procedure const_dec;
      var
         orgname : stringid;
         tt  : ttype;
         sym : tsym;
         dummysymoptions : tsymoptions;
         storetokenpos,filepos : tfileposinfo;
         old_block_type : tblock_type;
         skipequal : boolean;
      begin
         consume(_CONST);
         old_block_type:=block_type;
         block_type:=bt_const;
         repeat
           orgname:=orgpattern;
           filepos:=akttokenpos;
           consume(_ID);
           case token of

             _EQUAL:
                begin
                   consume(_EQUAL);
                   sym:=readconstant(orgname,filepos);
                   { Support hint directives }
                   dummysymoptions:=[];
                   try_consume_hintdirective(dummysymoptions);
                   if assigned(sym) then
                     begin
                       sym.symoptions:=sym.symoptions+dummysymoptions;
                       symtablestack.insert(sym);
                     end;
                   consume(_SEMICOLON);
                end;

             _COLON:
                begin
                   { set the blocktype first so a consume also supports a
                     caret, to support const s : ^string = nil }
                   block_type:=bt_type;
                   consume(_COLON);
                   ignore_equal:=true;
                   read_type(tt,'',false);
                   ignore_equal:=false;
                   block_type:=bt_const;
                   skipequal:=false;
                   { create symbol }
                   storetokenpos:=akttokenpos;
                   akttokenpos:=filepos;
                   sym:=ttypedconstsym.createtype(orgname,tt,(cs_typed_const_writable in aktlocalswitches));
                   akttokenpos:=storetokenpos;
                   symtablestack.insert(sym);
                   insertconstdata(ttypedconstsym(sym));
                   { procvar can have proc directives, but not type references }
                   if (tt.def.deftype=procvardef) and
                      (tt.sym=nil) then
                    begin
                      { support p : procedure;stdcall=nil; }
                      if try_to_consume(_SEMICOLON) then
                       begin
                         if check_proc_directive(true) then
                          parse_var_proc_directives(sym)
                         else
                          begin
                            Message(parser_e_proc_directive_expected);
                            skipequal:=true;
                          end;
                       end
                      else
                      { support p : procedure stdcall=nil; }
                       begin
                         if check_proc_directive(true) then
                          parse_var_proc_directives(sym);
                       end;
                      { add default calling convention }
                      handle_calling_convention(tabstractprocdef(tt.def));
                    end;
                   if not skipequal then
                    begin
                      { get init value }
                      consume(_EQUAL);
                      readtypedconst(tt,ttypedconstsym(sym),(cs_typed_const_writable in aktlocalswitches));
                      try_consume_hintdirective(sym.symoptions);
                      consume(_SEMICOLON);
                    end;
                end;

              else
                { generate an error }
                consume(_EQUAL);
           end;
         until token<>_ID;
         block_type:=old_block_type;
      end;


    procedure label_dec;
      var
         hl : tasmlabel;
      begin
         consume(_LABEL);
         if not(cs_support_goto in aktmoduleswitches) then
           Message(sym_e_goto_and_label_not_supported);
         repeat
           if not(token in [_ID,_INTCONST]) then
             consume(_ID)
           else
             begin
                if token=_ID then
                 symtablestack.insert(tlabelsym.create(orgpattern))
                else
                 symtablestack.insert(tlabelsym.create(pattern));
                consume(token);
             end;
           if token<>_SEMICOLON then consume(_COMMA);
         until not(token in [_ID,_INTCONST]);
         consume(_SEMICOLON);
      end;


    { search in symtablestack used, but not defined type }
    procedure resolve_type_forward(p : tnamedindexitem;arg:pointer);
      var
        hpd,pd : tdef;
        stpos  : tfileposinfo;
        again  : boolean;
        srsym  : tsym;
        srsymtable : tsymtable;
      {$ifdef gdb_notused}
        stab_str:Pchar;
      {$endif gdb_notused}

      begin
         { Check only typesyms or record/object fields }
         case tsym(p).typ of
           typesym :
             pd:=ttypesym(p).restype.def;
           fieldvarsym :
             pd:=tfieldvarsym(p).vartype.def
           else
             exit;
         end;
         repeat
           again:=false;
           case pd.deftype of
             arraydef :
               begin
                 { elementtype could also be defined using a forwarddef }
                 pd:=tarraydef(pd).elementtype.def;
                 again:=true;
               end;
             pointerdef,
             classrefdef :
               begin
                 { classrefdef inherits from pointerdef }
                 hpd:=tpointerdef(pd).pointertype.def;
                 { still a forward def ? }
                 if hpd.deftype=forwarddef then
                  begin
                    { try to resolve the forward }
                    { get the correct position for it }
                    stpos:=akttokenpos;
                    akttokenpos:=tforwarddef(hpd).forwardpos;
                    resolving_forward:=true;
                    make_ref:=false;
                    if not assigned(tforwarddef(hpd).tosymname) then
                      internalerror(20021120);
                    searchsym(tforwarddef(hpd).tosymname^,srsym,srsymtable);
                    make_ref:=true;
                    resolving_forward:=false;
                    akttokenpos:=stpos;
                    { we don't need the forwarddef anymore, dispose it }
                    hpd.free;
                    tpointerdef(pd).pointertype.def:=nil; { if error occurs }
                    { was a type sym found ? }
                    if assigned(srsym) and
                       (srsym.typ=typesym) then
                     begin
                       tpointerdef(pd).pointertype.setsym(srsym);
                       { avoid wrong unused warnings web bug 801 PM }
                       inc(ttypesym(srsym).refs);
{$ifdef GDB_UNUSED}
                       if (cs_debuginfo in aktmoduleswitches) and assigned(debuglist) and
                          (tsym(p).owner.symtabletype in [globalsymtable,staticsymtable]) then
                        begin
                          ttypesym(p).isusedinstab:=true;
{                          ttypesym(p).concatstabto(debuglist);}
                          {not stabs for forward defs }
                          if not Ttypesym(p).isstabwritten then
                            begin
                              if Ttypesym(p).restype.def.typesym=p then
                                Tstoreddef(Ttypesym(p).restype.def).concatstabto(debuglist)
                              else
                                begin
                                  stab_str:=Ttypesym(p).stabstring;
                                  if assigned(stab_str) then
                                    debuglist.concat(Tai_stabs.create(stab_str));
                                  Ttypesym(p).isstabwritten:=true;
                                end;
                            end;
                        end;
{$endif GDB_UNUSED}
                       { we need a class type for classrefdef }
                       if (pd.deftype=classrefdef) and
                          not(is_class(ttypesym(srsym).restype.def)) then
                         Message1(type_e_class_type_expected,ttypesym(srsym).restype.def.typename);
                     end
                    else
                     begin
                       MessagePos1(tsym(p).fileinfo,sym_e_forward_type_not_resolved,tsym(p).realname);
                       { try to recover }
                       tpointerdef(pd).pointertype:=generrortype;
                     end;
                  end;
               end;
             recorddef :
               trecorddef(pd).symtable.foreach_static(@resolve_type_forward,nil);
             objectdef :
               begin
                 if not(m_fpc in aktmodeswitches) and
                    (oo_is_forward in tobjectdef(pd).objectoptions) then
                  begin
                    { only give an error as the implementation may follow in an
                      other type block which is allowed by FPC modes }
                    MessagePos1(tsym(p).fileinfo,sym_e_forward_type_not_resolved,tsym(p).realname);
                  end
                 else
                  begin
                    { Check all fields of the object declaration, but don't
                      check objectdefs in objects/records, because these
                      can't exist (anonymous objects aren't allowed) }
                    if not(tsym(p).owner.symtabletype in [objectsymtable,recordsymtable]) then
                     tobjectdef(pd).symtable.foreach_static(@resolve_type_forward,nil);
                  end;
               end;
          end;
        until not again;
      end;


    { reads a type declaration to the symbol table }
    procedure type_dec;
      var
         typename,orgtypename : stringid;
         newtype  : ttypesym;
         sym      : tsym;
         srsymtable : tsymtable;
         tt       : ttype;
         oldfilepos,
         defpos,storetokenpos : tfileposinfo;
         old_block_type : tblock_type;
         ch       : tclassheader;
         unique,istyperenaming : boolean;

      begin
         old_block_type:=block_type;
         block_type:=bt_type;
         consume(_TYPE);
         typecanbeforward:=true;
         repeat
           typename:=pattern;
           orgtypename:=orgpattern;
           defpos:=akttokenpos;
           istyperenaming:=false;
           consume(_ID);
           consume(_EQUAL);
           { support 'ttype=type word' syntax }
           unique:=try_to_consume(_TYPE);

           { MacPas object model is more like Delphi's than like TP's, but }
           { uses the object keyword instead of class                      }
           if (m_mac in aktmodeswitches) and
              (token = _OBJECT) then
             token := _CLASS;

           { is the type already defined? }
           searchsym(typename,sym,srsymtable);
           newtype:=nil;
           { found a symbol with this name? }
           if assigned(sym) then
            begin
              if (sym.typ=typesym) then
               begin
                 if ((token=_CLASS) or
                     (token=_INTERFACE)) and
                    (assigned(ttypesym(sym).restype.def)) and
                    is_class_or_interface(ttypesym(sym).restype.def) and
                    (oo_is_forward in tobjectdef(ttypesym(sym).restype.def).objectoptions) then
                  begin
                    { we can ignore the result   }
                    { the definition is modified }
                    object_dec(orgtypename,tobjectdef(ttypesym(sym).restype.def));
                    newtype:=ttypesym(sym);
                    tt:=newtype.restype;
                  end
                 else
                  message1(parser_h_type_redef,orgtypename);
               end;
            end;
           { no old type reused ? Then insert this new type }
           if not assigned(newtype) then
            begin
              { insert the new type first with an errordef, so that
                referencing the type before it's really set it
                will give an error (PFV) }
              tt:=generrortype;
              storetokenpos:=akttokenpos;
              newtype:=ttypesym.create(orgtypename,tt);
              symtablestack.insert(newtype);
              akttokenpos:=defpos;
              akttokenpos:=storetokenpos;
              { read the type definition }
              read_type(tt,orgtypename,false);
              { update the definition of the type }
              newtype.restype:=tt;
              if assigned(tt.sym) then
                istyperenaming:=true
              else
                tt.sym:=newtype;
              if unique and assigned(tt.def) then
                begin
                   tt.setdef(tstoreddef(tt.def).getcopy);
                   include(tt.def.defoptions,df_unique);
                   newtype.restype:=tt;
                end;
              if assigned(tt.def) and not assigned(tt.def.typesym) then
                tt.def.typesym:=newtype;
              { KAZ: handle TGUID declaration in system unit }
              if (cs_compilesystem in aktmoduleswitches) and not assigned(rec_tguid) and
                 (typename='TGUID') and { name: TGUID and size=16 bytes that is 128 bits }
                 assigned(tt.def) and (tt.def.deftype=recorddef) and (tt.def.size=16) then
                rec_tguid:=trecorddef(tt.def);
            end;
           if assigned(tt.def) then
            begin
              case tt.def.deftype of
                pointerdef :
                  begin
                    consume(_SEMICOLON);
                    if try_to_consume(_FAR) then
                     begin
                       tpointerdef(tt.def).is_far:=true;
                       consume(_SEMICOLON);
                     end;
                  end;
                procvardef :
                  begin
                    { in case of type renaming, don't parse proc directives }
                    if istyperenaming then
                     consume(_SEMICOLON)
                    else
                     begin
                       if not check_proc_directive(true) then
                        consume(_SEMICOLON);
                       parse_var_proc_directives(tsym(newtype));
                       handle_calling_convention(tprocvardef(tt.def));
                     end;
                  end;
                objectdef,
                recorddef :
                  begin
                    try_consume_hintdirective(newtype.symoptions);
                    consume(_SEMICOLON);
                  end;
                else
                  consume(_SEMICOLON);
              end;
            end;

           { Write tables if we are the typesym that defines
             this type. This will not be done for simple type renamings }
           if (tt.def.typesym=newtype) then
            begin
              { file position }
              oldfilepos:=aktfilepos;
              aktfilepos:=newtype.fileinfo;

              { generate persistent init/final tables when it's declared in the interface so it can
                be reused in other used }
              if current_module.in_interface and
                 ((is_class(tt.def) and
                   tobjectdef(tt.def).members_need_inittable) or
                  tt.def.needs_inittable) then
                generate_inittable(newtype);

              { for objects we should write the vmt and interfaces.
                This need to be done after the rtti has been written, because
                it can contain a reference to that data (PFV)
                This is not for forward classes }
              if (tt.def.deftype=objectdef) and
                 (tt.def.owner.symtabletype in [staticsymtable,globalsymtable]) then
                with Tobjectdef(tt.def) do
                  begin
                    if not(oo_is_forward in objectoptions) then
                      begin
                        ch:=tclassheader.create(tobjectdef(tt.def));
                        { generate and check virtual methods, must be done
                          before RTTI is written }
                        ch.genvmt;
                        { Generate RTTI for class }
                        generate_rtti(newtype);
                        if is_interface(tobjectdef(tt.def)) then
                          ch.writeinterfaceids;
                        if (oo_has_vmt in objectoptions) then
                          ch.writevmt;
                        ch.free;
                      end;
                   end
              else
                begin
                  { Always generate RTTI info for all types. This is to have typeinfo() return
                    the same pointer }
                  generate_rtti(newtype);
                end;

              aktfilepos:=oldfilepos;
            end;
         until token<>_ID;
         typecanbeforward:=false;
         symtablestack.foreach_static(@resolve_type_forward,nil);
         block_type:=old_block_type;
      end;


    procedure var_dec;
    { parses variable declarations and inserts them in }
    { the top symbol table of symtablestack         }
      begin
        consume(_VAR);
        read_var_decs([]);
      end;


    procedure property_dec;
      var
         old_block_type : tblock_type;
      begin
         consume(_PROPERTY);
         if not(symtablestack.symtabletype in [staticsymtable,globalsymtable]) then
           message(parser_e_resourcestring_only_sg);
         old_block_type:=block_type;
         block_type:=bt_const;
         repeat
           read_property_dec(nil);
           consume(_SEMICOLON);
         until token<>_ID;
         block_type:=old_block_type;
      end;


    procedure threadvar_dec;
    { parses thread variable declarations and inserts them in }
    { the top symbol table of symtablestack                }
      begin
        consume(_THREADVAR);
        if not(symtablestack.symtabletype in [staticsymtable,globalsymtable]) then
          message(parser_e_threadvars_only_sg);
        read_var_decs([vd_threadvar]);
      end;


    procedure resourcestring_dec;
      var
         orgname : stringid;
         p : tnode;
         dummysymoptions : tsymoptions;
         storetokenpos,filepos : tfileposinfo;
         old_block_type : tblock_type;
         sp : pchar;
         sym : tsym;
      begin
         consume(_RESOURCESTRING);
         if not(symtablestack.symtabletype in [staticsymtable,globalsymtable]) then
           message(parser_e_resourcestring_only_sg);
         old_block_type:=block_type;
         block_type:=bt_const;
         repeat
           orgname:=orgpattern;
           filepos:=akttokenpos;
           consume(_ID);
           case token of
             _EQUAL:
                begin
                   consume(_EQUAL);
                   p:=comp_expr(true);
                   storetokenpos:=akttokenpos;
                   akttokenpos:=filepos;
                   sym:=nil;
                   case p.nodetype of
                      ordconstn:
                        begin
                           if is_constcharnode(p) then
                             begin
                                getmem(sp,2);
                                sp[0]:=chr(tordconstnode(p).value);
                                sp[1]:=#0;
                                sym:=tconstsym.create_string(orgname,constresourcestring,sp,1);
                             end
                           else
                             Message(parser_e_illegal_expression);
                        end;
                      stringconstn:
                        with Tstringconstnode(p) do
                          begin
                             getmem(sp,len+1);
                             move(value_str^,sp^,len+1);
                             sym:=tconstsym.create_string(orgname,constresourcestring,sp,len);
                          end;
                      else
                        Message(parser_e_illegal_expression);
                   end;
                   akttokenpos:=storetokenpos;
                   { Support hint directives }
                   dummysymoptions:=[];
                   try_consume_hintdirective(dummysymoptions);
                   if assigned(sym) then
                     begin
                       sym.symoptions:=sym.symoptions+dummysymoptions;
                       symtablestack.insert(sym);
                     end;
                   consume(_SEMICOLON);
                   p.free;
                end;
              else consume(_EQUAL);
           end;
         until token<>_ID;
         block_type:=old_block_type;
      end;

end.
