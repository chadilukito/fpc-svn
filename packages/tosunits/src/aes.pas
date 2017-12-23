{
    Copyright (c) 2016 by Free Pascal development team

    AES interface unit for Atari TOS

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit aes;

interface

{ The API description of this file is based on the information available
  online at: http://toshyp.atari.org }

type
  PAESContrl = ^TAESContrl;
  TAESContrl = record
    opcode: SmallInt;
    case boolean of
      true: (
        nums: array[0..3] of SmallInt; );
      false: (
        num_intin: SmallInt;
        num_addrin: SmallInt;
        num_intout: SmallInt;
        num_addrout: SmallInt; );
  end;

  PAESGlobal = ^TAESGlobal;
  TAESGlobal = array[0..14] of SmallInt;

  PAESIntIn = ^TAESIntIn;
  TAESIntIn = array[0..15] of SmallInt;

  PAESIntOut = ^TAESIntOut;
  TAESIntOut = array[0..9] of SmallInt;

  PAESAddrIn = ^TAESAddrIn;
  TAESAddrIn = array[0..7] of Pointer;

  PAESAddrOut = ^TAESAddrOut;
  TAESAddrOut = array[0..1] of Pointer;

type
  PAESPB = ^TAESPB;
  TAESPB = record
    contrl: PAESContrl;
    global: PAESGlobal;
    intin: PAESIntIn;
    intout: PAESIntOut;
    addrin: PAESAddrIn;
    addrout: PAESAddrOut;
  end;

const
  AES_TRAP_MAGIC = $C8;

type
  PAESOBJECT = ^TAESOBJECT;
  TAESOBJECT = record
    ob_next: smallint;   {* The next object               *}
    ob_head: smallint;   {* First child                   *}
    ob_tail: smallint;   {* Last child                    *}
    ob_type: word;       {* Object type                   *}
    ob_flags: word;      {* Manipulation flags            *}
    ob_state: word;      {* Object status                 *}
    ob_spec: pointer;    {* More under object type        *}
    ob_x: smallint;      {* X-coordinate of the object    *}
    ob_y: smallint;      {* Y-coordinate of the object    *}
    ob_width: smallint;  {* Width of the object           *}
    ob_height: smallint; {* Height of the object          *}
  end;

{ kinds, as used by wind_create() }
const
  NAME    = $01;   { Window has a title bar. }
  CLOSER  = $02;   { Window has a close box. }
  FULLER  = $04;   { Window has a fuller box. }
  MOVER   = $08;   { Window may be moved by the user. }
  INFO    = $10;   { Window has an information line. }
  SIZER   = $20;   { Window has a sizer box. }
  UPARROW = $40;   { Window has an up arrow. }
  DNARROW = $80;   { Window has a down arrow. }
  VSLIDE  = $100;  { Window has a vertical slider. }
  LFARROW = $200;  { Window has a left arrow. }
  RTARROW = $400;  { Window has a right arrow. }
  HSLIDE  = $800;  { Window has a horizontal slider. }
  SMALLER = $4000; { Window has an iconifier. }

{ messages as used by evnt_mesag() }
const
  WM_REDRAW     = $0014;
  WM_TOPPED     = $0015;
  WM_CLOSED     = $0016;
  WM_FULLED     = $0017;
  WM_ARROWED    = $0018;
  WM_HSLID      = $0019;
  WM_VSLID      = $001a;
  WM_SIZED      = $001b;
  WM_MOVED      = $001c;
  WM_NEWTOP     = $001d;
  WM_UNTOPPED   = $001e;
  WM_ONTOP      = $001f;
  WM_OFFTOP     = $0020;
  WM_BOTTOMED   = $0021;
  WM_ICONIFY    = $0022;
  WM_UNICONIFY  = $0023;
  WM_ALLICONIFY = $0024;
  WM_TOOLBAR    = $0025;

{ message flags as used by evnt_multi() }
const
  MU_KEYBD  = $0001; { Keyboard event }
  MU_BUTTON = $0002; { Button event   }
  MU_M1     = $0004; { Mouse event 1  }
  MU_M2     = $0008; { Mouse event 2  }
  MU_MESAG  = $0010; { Messages       }
  MU_TIMER  = $0020; { Timer events   }

{ window update flags as used by wind_update() }
const
  END_UPDATE = (0);  { Screen redraw is compete and the flag set by BEG_UPDATE is reset }
  BEG_UPDATE = (1);  { Screen redraw starts, rectangle lists are frozen, flag is set to prevent any other processes updating the screen }
  END_MCTRL  = (2);  { Application releases control of the mouse to the AES and resumes mouse click message reactions }
  BEG_MCTRL  = (3);  { The application wants to have sole control over mouse button messages }


function appl_exit: smallint;
function appl_read(ap_rid: smallint; ap_rlength: smallint; ap_rpbuff: pointer): smallint;
function appl_write(ap_wid: smallint; ap_wlength: smallint; ap_wpbuff: pointer): smallint;
function appl_find(fname: PChar): smallint;
function appl_init: smallint;

function evnt_keybd: smallint;
function evnt_button(ev_bclicks: smallint; ev_bmask: smallint; ev_bstate: smallint;
                     ev_bmx: psmallint; ev_bmy: psmallint; ev_bbutton: psmallint; ev_bkstate: psmallint): smallint;
function evnt_mouse(ev_moflags: smallint; ev_mox: smallint; ev_moy: smallint; ev_mowidth: smallint; ev_moheight: smallint;
                    ev_momx: psmallint; ev_momy: psmallint; ev_mobutton: psmallint; ev_mokstate: psmallint): smallint;
function evnt_mesag(msg: psmallint): smallint;
function evnt_timer(ev_tlocount: smallint; ev_thicount: smallint): smallint;
function evnt_multi(ev_mflags: smallint; ev_mbclicks: smallint; ev_mbmask: smallint; ev_mbstate: smallint;
                    ev_mm1flags: smallint; ev_mm1x: smallint; ev_mm1y: smallint; ev_mm1width: smallint; ev_mm1height: smallint;
                    ev_mm2flags: smallint; ev_mm2x: smallint; ev_mm2y: smallint; ev_mm2width: smallint; ev_mm2height: smallint;
                    ev_mmgpbuff: psmallint; ev_mtlocount: smallint; ev_mthicount: smallint;
                    ev_mmox: psmallint; ev_mmoy: psmallint; ev_mmbutton: psmallint; ev_mmokstate: psmallint;
                    ev_mkreturn: psmallint; ev_mbreturn: psmallint): smallint;
function evnt_dclick(ev_dnew: smallint; ev_dgetset: smallint): smallint;

function form_alert(default: smallint; alertstr: PChar): smallint;
function form_error(error: smallint): smallint;

function graf_handle(gr_hwchar: psmallint; gr_hhchar: psmallint; gr_hwbox: psmallint; gr_hhbox: psmallint): smallint;

function fsel_input(fs_iinpath: pchar; fs_iinsel: pchar; fs_iexbutton: psmallint): smallint;
function fsel_exinput(fs_einpath: pchar; fs_einsel: pchar; fs_eexbutton: psmallint; elabel: pchar): smallint;

function wind_create(kind: smallint; x, y, w, h: smallint): smallint;
function wind_open(handle: smallint; x, y, w, h: smallint): smallint;
function wind_close(wi_clhandle: smallint): smallint;
function wind_delete(handle: smallint): smallint;
function wind_update(wi_ubegend: smallint): smallint;
procedure wind_new;

function crys_if(_opcode: dword): smallint;

implementation

const
  ops_table: array[0..120,0..3] of SmallInt = (
    ( 0, 1, 0, 0 ),    // 10, appl_init
    ( 2, 1, 1, 0 ),    // 11, appl_read
    ( 2, 1, 1, 0 ),    // 12, appl_write
    ( 0, 1, 1, 0 ),    // 13, appl_find
    ( 2, 1, 1, 0 ),    // 14, appl_tplay
    ( 1, 1, 1, 0 ),    // 15, appl_trecord
    ( 0, 0, 0, 0 ),    // 16
    ( 0, 0, 0, 0 ),    // 17
    ( 1, 3, 1, 0 ),    // 18, appl_search (V4.0)
    ( 0, 1, 0, 0 ),    // 19, appl_exit
    ( 0, 1, 0, 0 ),    // 20, evnt_keybd
    ( 3, 5, 0, 0 ),    // 21, evnt_button
    ( 5, 5, 0, 0 ),    // 22, evnt_mouse
    ( 0, 1, 1, 0 ),    // 23, evnt_mesag
    ( 2, 1, 0, 0 ),    // 24, evnt_timer
    (16, 7, 1, 0 ),    // 25, evnt_multi
    ( 2, 1, 0, 0 ),    // 26, evnt_dclick
    ( 0, 0, 0, 0 ),    // 27
    ( 0, 0, 0, 0 ),    // 28
    ( 0, 0, 0, 0 ),    // 29
    ( 1, 1, 1, 0 ),    // 30, menu_bar
    ( 2, 1, 1, 0 ),    // 31, menu_icheck
    ( 2, 1, 1, 0 ),    // 32, menu_ienable
    ( 2, 1, 1, 0 ),    // 33, menu_tnormal
    ( 1, 1, 2, 0 ),    // 34, menu_text
    ( 1, 1, 1, 0 ),    // 35, menu_register
    ( 2, 1, 2, 0 ),    // 36, menu_popup (V3.3)
    ( 2, 1, 2, 0 ),    // 37, menu_attach (V3.3)
    ( 3, 1, 1, 0 ),    // 38, menu_istart (V3.3)
    ( 1, 1, 1, 0 ),    // 39, menu_settings (V3.3)
    ( 2, 1, 1, 0 ),    // 40, objc_add
    ( 1, 1, 1, 0 ),    // 41, objc_delete
    ( 6, 1, 1, 0 ),    // 42, objc_draw
    ( 4, 1, 1, 0 ),    // 43, objc_find
    ( 1, 3, 1, 0 ),    // 44, objc_offset
    ( 2, 1, 1, 0 ),    // 45, objc_order
    ( 4, 2, 1, 0 ),    // 46, objc_edit
    ( 8, 1, 1, 0 ),    // 47, objc_change
    ( 4, 3, 0, 0 ),    // 48, objc_sysvar (V3.4)
    ( 0, 0, 0, 0 ),    // 49
    ( 1, 1, 1, 0 ),    // 50, form_do
    ( 9, 1, 0, 0 ),    // 51, form_dial
    ( 1, 1, 1, 0 ),    // 52, form_alert
    ( 1, 1, 0, 0 ),    // 53, form_error
    ( 0, 5, 1, 0 ),    // 54, form_center
    ( 3, 3, 1, 0 ),    // 55, form_keybd
    ( 2, 2, 1, 0 ),    // 56, form_button
    ( 0, 0, 0, 0 ),    // 57
    ( 0, 0, 0, 0 ),    // 58
    ( 0, 0, 0, 0 ),    // 59
    ( 0, 0, 0, 0 ),    // 60
    ( 0, 0, 0, 0 ),    // 61
    ( 0, 0, 0, 0 ),    // 62
    ( 0, 0, 0, 0 ),    // 63
    ( 0, 0, 0, 0 ),    // 64
    ( 0, 0, 0, 0 ),    // 65
    ( 0, 0, 0, 0 ),    // 66
    ( 0, 0, 0, 0 ),    // 67
    ( 0, 0, 0, 0 ),    // 68
    ( 0, 0, 0, 0 ),    // 69
    ( 4, 3, 0, 0 ),    // 70, graf_rubberbox
    ( 8, 3, 0, 0 ),    // 71, graf_dragbox
    ( 6, 1, 0, 0 ),    // 72, graf_movebox
    ( 8, 1, 0, 0 ),    // 73, graf_growbox
    ( 8, 1, 0, 0 ),    // 74, graf_shrinkbox
    ( 4, 1, 1, 0 ),    // 75, graf_watchbox
    ( 3, 1, 1, 0 ),    // 76, graf_slidebox
    ( 0, 5, 0, 0 ),    // 77, graf_handle
    ( 1, 1, 1, 0 ),    // 78, graf_mouse
    ( 0, 5, 0, 0 ),    // 79, graf_mkstate
    ( 0, 1, 1, 0 ),    // 80, scrp_read
    ( 0, 1, 1, 0 ),    // 81, scrp_write
    ( 0, 0, 0, 0 ),    // 82
    ( 0, 0, 0, 0 ),    // 83
    ( 0, 0, 0, 0 ),    // 84
    ( 0, 0, 0, 0 ),    // 85
    ( 0, 0, 0, 0 ),    // 86
    ( 0, 0, 0, 0 ),    // 87
    ( 0, 0, 0, 0 ),    // 88
    ( 0, 0, 0, 0 ),    // 89
    ( 0, 2, 2, 0 ),    // 90, fsel_input
    ( 0, 2, 3, 0 ),    // 91, fsel_exinput
    ( 0, 0, 0, 0 ),    // 92
    ( 0, 0, 0, 0 ),    // 93
    ( 0, 0, 0, 0 ),    // 94
    ( 0, 0, 0, 0 ),    // 95
    ( 0, 0, 0, 0 ),    // 96
    ( 0, 0, 0, 0 ),    // 97
    ( 0, 0, 0, 0 ),    // 98
    ( 0, 0, 0, 0 ),    // 99
    ( 5, 1, 0, 0 ),    // 100, wind_create
    ( 5, 1, 0, 0 ),    // 101, wind_open
    ( 1, 1, 0, 0 ),    // 102, wind_close
    ( 1, 1, 0, 0 ),    // 103, wind_delete
    ( 2, 5, 0, 0 ),    // 104, wind_get
    ( 6, 1, 0, 0 ),    // 105, wind_set
    ( 2, 1, 0, 0 ),    // 106, wind_find
    ( 1, 1, 0, 0 ),    // 107, wind_update
    ( 6, 5, 0, 0 ),    // 108, wind_calc
    ( 0, 0, 0, 0 ),    // 109, wind_new
    ( 0, 1, 1, 0 ),    // 110, rsrc_load
    ( 0, 1, 0, 0 ),    // 111, rsrc_free
    ( 2, 1, 0, 1 ),    // 112, rsrc_gaddr
    ( 2, 1, 1, 0 ),    // 113, rsrc_saddr
    ( 1, 1, 1, 0 ),    // 114, rsrc_obfix
    ( 0, 0, 0, 0 ),    // 115, rsrc_rcfix (V4.0)
    ( 0, 0, 0, 0 ),    // 116
    ( 0, 0, 0, 0 ),    // 117
    ( 0, 0, 0, 0 ),    // 118
    ( 0, 0, 0, 0 ),    // 119
    ( 0, 1, 2, 0 ),    // 120, shel_read
    ( 3, 1, 2, 0 ),    // 121, shel_write
    ( 1, 1, 1, 0 ),    // 122, shel_get
    ( 1, 1, 1, 0 ),    // 123, shel_put
    ( 0, 1, 1, 0 ),    // 124, shel_find
    ( 0, 1, 2, 0 ),    // 125, shel_envrn
    ( 0, 0, 0, 0 ),    // 126
    ( 0, 0, 0, 0 ),    // 127
    ( 0, 0, 0, 0 ),    // 128
    ( 0, 0, 0, 0 ),    // 129
    ( 1, 5, 0, 0 )     // 130, appl_getinfo (V4.0)
  );

var
  _contrl: TAESContrl;
  _global: TAESGlobal;
  _intin: TAESIntIn;
  _intout: TAESIntOut;
  _addrin: TAESAddrIn;
  _addrout: TAESAddrOut;

const
  aespb: TAESPB = (
    contrl: @_contrl;
    global: @_global;
    intin: @_intin;
    intout: @_intout;
    addrin: @_addrin;
    addrout: @_addrout;
  );

function appl_exit: smallint;
begin
  appl_exit:=crys_if($13);
end;

function appl_read(ap_rid: smallint; ap_rlength: smallint; ap_rpbuff: pointer): smallint;
begin
  _intin[0]:=ap_rid;
  _intin[1]:=ap_rlength;
  _addrin[0]:=ap_rpbuff;

  appl_read:=crys_if($0b);
end;

function appl_write(ap_wid: smallint; ap_wlength: smallint; ap_wpbuff: pointer): smallint;
begin
  _intin[0]:=ap_wid;
  _intin[1]:=ap_wlength;
  _addrin[0]:=ap_wpbuff;

  appl_write:=crys_if($0c);
end;

function appl_find(fname: PChar): smallint;
begin
  _addrin[0]:=fname;
  appl_find:=crys_if($0d);
end;

function appl_init: smallint;
begin
  appl_init:=crys_if($0a);
end;

function evnt_keybd: smallint;
begin
  evnt_keybd:=crys_if($14);
end;

function evnt_button(ev_bclicks: smallint; ev_bmask: smallint; ev_bstate: smallint;
                     ev_bmx: psmallint; ev_bmy: psmallint; ev_bbutton: psmallint; ev_bkstate: psmallint): smallint;
begin
  _intin[0]:=ev_bclicks;
  _intin[1]:=ev_bmask;
  _intin[2]:=ev_bstate;

  crys_if($15);

  ev_bmx^:=_intout[1];
  ev_bmy^:=_intout[2];
  ev_bbutton^:=_intout[3];
  ev_bkstate^:=_intout[4];

  evnt_button:=_intout[0];
end;

function evnt_mouse(ev_moflags: smallint; ev_mox: smallint; ev_moy: smallint; ev_mowidth: smallint; ev_moheight: smallint;
                    ev_momx: psmallint; ev_momy: psmallint; ev_mobutton: psmallint; ev_mokstate: psmallint): smallint;
begin
  _intin[0]:=ev_moflags;
  _intin[1]:=ev_mox;
  _intin[2]:=ev_moy;
  _intin[3]:=ev_mowidth;
  _intin[4]:=ev_moheight;

  crys_if($16);

  ev_momx^:=_intout[1];
  ev_momy^:=_intout[2];
  ev_mobutton^:=_intout[3];
  ev_mokstate^:=_intout[4];

  evnt_mouse:=_intout[0];
end;

function evnt_mesag(msg: psmallint): smallint;
begin
  _addrin[0]:=msg;
  evnt_mesag:=crys_if($17);
end;

function evnt_timer(ev_tlocount: smallint; ev_thicount: smallint): smallint;
begin
  _intin[0]:=ev_tlocount;
  _intin[1]:=ev_thicount;

  evnt_timer:=crys_if($18);
end;

function evnt_multi(ev_mflags: smallint; ev_mbclicks: smallint; ev_mbmask: smallint; ev_mbstate: smallint;
                    ev_mm1flags: smallint; ev_mm1x: smallint; ev_mm1y: smallint; ev_mm1width: smallint; ev_mm1height: smallint;
                    ev_mm2flags: smallint; ev_mm2x: smallint; ev_mm2y: smallint; ev_mm2width: smallint; ev_mm2height: smallint;
                    ev_mmgpbuff: psmallint; ev_mtlocount: smallint; ev_mthicount: smallint;
                    ev_mmox: psmallint; ev_mmoy: psmallint; ev_mmbutton: psmallint; ev_mmokstate: psmallint;
                    ev_mkreturn: psmallint; ev_mbreturn: psmallint): smallint;
begin
  _intin[0]:=ev_mflags;
  _intin[1]:=ev_mbclicks;
  _intin[2]:=ev_mbmask;
  _intin[3]:=ev_mbstate;
  _intin[4]:=ev_mm1flags;
  _intin[5]:=ev_mm1x;
  _intin[6]:=ev_mm1y;
  _intin[7]:=ev_mm1width;
  _intin[8]:=ev_mm1height;
  _intin[9]:=ev_mm2flags;
  _intin[10]:=ev_mm2x;
  _intin[11]:=ev_mm2y;
  _intin[12]:=ev_mm2width;
  _intin[13]:=ev_mm2height;
  _intin[14]:=ev_mtlocount;
  _intin[15]:=ev_mthicount;
  _addrin[0]:=ev_mmgpbuff;

  crys_if($19);

  ev_mmox^:=_intout[1];
  ev_mmoy^:=_intout[2];
  ev_mmbutton^:=_intout[3];
  ev_mmokstate^:=_intout[4];
  ev_mkreturn^:=_intout[5];
  ev_mbreturn^:=_intout[6];

  evnt_multi:=_intout[0];
end;

function evnt_dclick(ev_dnew: smallint; ev_dgetset: smallint): smallint;
begin
  _intin[0]:=ev_dnew;
  _intin[1]:=ev_dgetset;

  evnt_dclick:=crys_if($1a);
end;

function form_alert(default: smallint; alertstr: PChar): smallint;
begin
  _intin[0]:=default;
  _addrin[0]:=alertstr;
  form_alert:=crys_if($34);
end;

function form_error(error: smallint): smallint;
begin
  _intin[0]:=error;
  form_error:=crys_if($35);
end;

function graf_handle(gr_hwchar: psmallint; gr_hhchar: psmallint; gr_hwbox: psmallint; gr_hhbox: psmallint): smallint;
begin
  crys_if($4d);

  gr_hwchar^:=_intout[1];
  gr_hhchar^:=_intout[2];
  gr_hwbox^:=_intout[3];
  gr_hhbox^:=_intout[4];

  graf_handle:=_intout[0];
end;

function fsel_input(fs_iinpath: pchar; fs_iinsel: pchar; fs_iexbutton: psmallint): smallint;
begin
  _addrin[0]:=fs_iinpath;
  _addrin[1]:=fs_iinsel;

  crys_if($5a);

  fs_iexbutton^:=_intout[1];

  fsel_input:=_intout[0];
end;

function fsel_exinput(fs_einpath: pchar; fs_einsel: pchar; fs_eexbutton: psmallint; elabel: pchar): smallint;
begin
  _addrin[0]:=fs_einpath;
  _addrin[1]:=fs_einsel;
  _addrin[2]:=elabel;

  crys_if($5b);

  fs_eexbutton^:=_intout[1];

  fsel_exinput:=_intout[0];
end;

function wind_create(kind: smallint; x, y, w, h: smallint): smallint;
begin
  _intin[0]:=kind;
  _intin[1]:=x;
  _intin[2]:=y;
  _intin[3]:=w;
  _intin[4]:=h;
  wind_create:=crys_if($64);
end;


function wind_open(handle: smallint; x, y, w, h: smallint): smallint;
begin
  _intin[0]:=handle;
  _intin[1]:=x;
  _intin[2]:=y;
  _intin[3]:=w;
  _intin[4]:=h;
  wind_open:=crys_if($65);
end;

function wind_close(wi_clhandle: smallint): smallint;
begin
  _intin[0]:=wi_clhandle;
  wind_close:=crys_if($66);
end;

function wind_delete(handle: smallint): smallint;
begin
  _intin[0]:=handle;
  wind_delete:=crys_if($67);
end;

function wind_update(wi_ubegend: smallint): smallint;
begin
  _intin[0]:=wi_ubegend;
  wind_update:=crys_if($6b);
end;

procedure wind_new;
begin
  crys_if($6d);
end;


function crys_if(_opcode: dword): smallint;
begin
  with _contrl do
    begin
      opcode:=_opcode;
      nums:=ops_table[_opcode-10];
    end;
  asm
    lea.l       aespb, a0
    move.l      a0, d1
    move.w      #AES_TRAP_MAGIC, d0
    trap        #2
  end;
  crys_if:=_intout[0];
end;


end.
