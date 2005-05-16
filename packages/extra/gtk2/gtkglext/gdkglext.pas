{ GdkGLExt - OpenGL Extension to GDK
  Copyright (C) 2002-2004  Naofumi Yasufuku
  These Pascal bindings copyright 2005 Michalis Kamburelis

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA.
}

{ Translated from C header /usr/include/gtkglext-1.0/gdk/gdkgl.h
  (this is probably standardized system-wide location
  of this header). }

{$mode objfpc}

unit gdkglext;

interface

uses Glib2, Gdk2;

const
  GdkGLExtLib = 
    {$ifdef WIN32} 'libgdkglext-win32-1.0-0.dll'
    {$else}        'libgdkglext-x11-1.0.so'
    {$endif};

type
  {$define read_interface_types}
  {$I gdkglext_includes.inc}
  {$undef read_interface_types}

{$define read_interface_rest}
{$I gdkglext_includes.inc}
{$undef read_interface_rest}

implementation

{$define read_implementation}
{$I gdkglext_includes.inc}

end.