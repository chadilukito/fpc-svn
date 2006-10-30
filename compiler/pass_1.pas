{
    Copyright (c) 1998-2002 by Florian Klaempfl

    This unit handles the pass_typecheck and node conversion pass

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
unit pass_1;

{$i fpcdefs.inc}

interface

    uses
       node;

    procedure typecheckpass(var p : tnode);
    function  do_typecheckpass(var p : tnode) : boolean;

    procedure firstpass(var p : tnode);
    function  do_firstpass(var p : tnode) : boolean;
{$ifdef state_tracking}
    procedure  do_track_state_pass(p:Tnode);
{$endif}


implementation

    uses
      globtype,systems,cclasses,
      cutils,globals,
      procinfo,
      cgbase,symdef
{$ifdef extdebug}
      ,verbose,htypechk
{$endif extdebug}
{$ifdef state_tracking}
      ,nstate
{$endif}
      ;

{*****************************************************************************
                            Global procedures
*****************************************************************************}

    procedure typecheckpass(var p : tnode);
      var
         oldcodegenerror  : boolean;
         oldlocalswitches : tlocalswitches;
         oldpos    : tfileposinfo;
         hp        : tnode;
      begin
        if (p.resultdef=nil) then
         begin
           oldcodegenerror:=codegenerror;
           oldpos:=current_filepos;
           oldlocalswitches:=current_settings.localswitches;
           codegenerror:=false;
           current_filepos:=p.fileinfo;
           current_settings.localswitches:=p.localswitches;
           hp:=p.pass_typecheck;
           { should the node be replaced? }
           if assigned(hp) then
            begin
               p.free;
               { run typecheckpass }
               typecheckpass(hp);
               { switch to new node }
               p:=hp;
            end;
           current_settings.localswitches:=oldlocalswitches;
           current_filepos:=oldpos;
           if codegenerror then
            begin
              include(p.flags,nf_error);
              { default to errortype if no type is set yet }
              if p.resultdef=nil then
               p.resultdef:=generrordef;
            end;
           codegenerror:=codegenerror or oldcodegenerror;
         end
        else
         begin
           { update the codegenerror boolean with the previous result of this node }
           if (nf_error in p.flags) then
             codegenerror:=true;
         end;
      end;


    function do_typecheckpass(var p : tnode) : boolean;
      begin
         codegenerror:=false;
         typecheckpass(p);
         do_typecheckpass:=codegenerror;
      end;


    procedure firstpass(var p : tnode);
      var
         oldcodegenerror  : boolean;
         oldlocalswitches : tlocalswitches;
         oldpos    : tfileposinfo;
         hp : tnode;
      begin
         if (nf_pass1_done in p.flags) then
           exit;
         if not(nf_error in p.flags) then
           begin
              oldcodegenerror:=codegenerror;
              oldpos:=current_filepos;
              oldlocalswitches:=current_settings.localswitches;
              codegenerror:=false;
              current_filepos:=p.fileinfo;
              current_settings.localswitches:=p.localswitches;
              { checks make always a call }
              if ([cs_check_range,cs_check_overflow,cs_check_stack] * current_settings.localswitches <> []) then
                include(current_procinfo.flags,pi_do_call);
              { determine the resultdef if not done }
              if (p.resultdef=nil) then
               begin
                 current_filepos:=p.fileinfo;
                 current_settings.localswitches:=p.localswitches;
                 hp:=p.pass_typecheck;
                 { should the node be replaced? }
                 if assigned(hp) then
                  begin
                     p.free;
                     { run typecheckpass }
                     typecheckpass(hp);
                     { switch to new node }
                     p:=hp;
                  end;
                 if codegenerror then
                  begin
                    include(p.flags,nf_error);
                    { default to errortype if no type is set yet }
                    if p.resultdef=nil then
                     p.resultdef:=generrordef;
                  end;
                 current_settings.localswitches:=oldlocalswitches;
                 current_filepos:=oldpos;
                 codegenerror:=codegenerror or oldcodegenerror;
               end;
              if not(nf_error in p.flags) then
               begin
                 { first pass }
                 current_filepos:=p.fileinfo;
                 current_settings.localswitches:=p.localswitches;
                 hp:=p.pass_1;
                 { should the node be replaced? }
                 if assigned(hp) then
                  begin
                    p.free;
                    { run firstpass }
                    firstpass(hp);
                    { switch to new node }
                    p:=hp;
                  end;
                 if codegenerror then
                  include(p.flags,nf_error)
                 else
                  begin
{$ifdef EXTDEBUG}
                    if (p.expectloc=LOC_INVALID) then
                      Comment(V_Warning,'Expectloc is not set in firstpass: '+nodetype2str[p.nodetype]);
{$endif EXTDEBUG}
                  end;
               end;
              include(p.flags,nf_pass1_done);
              codegenerror:=codegenerror or oldcodegenerror;
              current_settings.localswitches:=oldlocalswitches;
              current_filepos:=oldpos;
           end
         else
           codegenerror:=true;
      end;


    function do_firstpass(var p : tnode) : boolean;
      begin
         codegenerror:=false;
         firstpass(p);
{$ifdef state_tracking}
         writeln('TRACKSTART');
         writeln('before');
         writenode(p);
         do_track_state_pass(p);
         writeln('after');
         writenode(p);
         writeln('TRACKDONE');
{$endif}
         do_firstpass:=codegenerror;
      end;

{$ifdef state_tracking}
     procedure do_track_state_pass(p:Tnode);

     begin
        aktstate:=Tstate_storage.create;
        p.track_state_pass(true);
            aktstate.destroy;
     end;
{$endif}

end.
