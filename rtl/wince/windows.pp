{
    This file is part of the Free Pascal run time library.
    This unit contains the record definition for the Win32 API
    Copyright (c) 1999-2000 by Florian KLaempfl,
    member of the Free Pascal development team.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************

}

unit windows;

{$ifndef NO_SMART_LINK}
{$smartlink on}
{$endif}

{ stuff like array of const is used }
{$mode objfpc}
{$calling cdecl}   //convention is cdecl except for x86 emulator stdcall
                   //change nothing on arm

interface


{$define read_interface}
{$undef read_implementation}


{$i base.inc}
{$i errors.inc}
{$i defines.inc}
{$i struct.inc}
{$i messages.inc}
{$i coredll.inc}
{$i aygshell.inc}
{$i commctrl.inc}
{$i commdlg.inc}
{$i ceshell.inc}
{$i oleaut32.inc}
{$i cemiss.inc}

{$i redef.inc}

{$undef read_interface}

implementation

{$define read_implementation}

{$i base.inc}
{$i errors.inc}
{$i defines.inc}
{$i struct.inc}
{$i messages.inc}
{$i coredll.inc}
{$i aygshell.inc}
{$i commctrl.inc}
{$i commdlg.inc}
{$i ceshell.inc}
{$i oleaut32.inc}
{$i cemiss.inc}

{$i redef.inc}

{$undef read_implementation}

begin
end.
