#   $Id: prt0.as,v 1.9 2004/07/05 21:07:38 florian Exp $
/* Startup code for elf32-sparc
   Copyright (C) 1997, 1998 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Richard Henderson <richard@gnu.ai.mit.edu>, 1997.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

	.section ".text"
	.align 4
	.global _start
	.type _start,#function
_start:

  	/* Terminate the stack frame, and reserve space for functions to
     	   drop their arguments.  */
	mov	%g0, %fp
	sub	%sp, 6*4, %sp

  	/* Extract the arguments and environment as encoded on the stack.  The
     	   argument info starts after one register window (16 words) past the SP.  */
	ld	[%sp+22*4], %o2
	sethi	%hi(operatingsystem_parameter_argc),%o1
	or	%o1,%lo(operatingsystem_parameter_argc),%o1
	st	%o2, [%o1]

	add	%sp, 23*4, %o0
	sethi	%hi(operatingsystem_parameter_argv),%o1
	or	%o1,%lo(operatingsystem_parameter_argv),%o1
	st	%o0, [%o1]

	/* envp=(argc+1)*4+argv */
	inc     %o2
	sll     %o2, 2, %o2
	add	%o2, %o0, %o2
	sethi	%hi(operatingsystem_parameter_envp),%o1
	or	%o1,%lo(operatingsystem_parameter_envp),%o1
	st	%o2, [%o1]

  	/* Call the user program entry point.  */
  	call	PASCALMAIN
  	nop

.globl  _haltproc
.type   _haltproc,@function
_haltproc:
	mov	1, %g1			/* "exit" system call */
	sethi	%hi(operatingsystem_result),%o0
	or	%o0,%lo(operatingsystem_result),%o0
	ldsh	[%o0], %o0			/* give exit status to parent process*/
	ta	0x10			/* dot the system call */
	nop				/* delay slot */
	/* Die very horribly if exit returns.  */
	unimp

	.size _start, .-_start

        .comm operatingsystem_parameter_envp,4
        .comm operatingsystem_parameter_argc,4
        .comm operatingsystem_parameter_argv,4

#
# $Log: prt0.as,v $
# Revision 1.9  2004/07/05 21:07:38  florian
#   * remade makefile (too old fpcmake)
#   * fixed sparc startup code
#
# Revision 1.8  2004/07/03 21:50:31  daniel
#   * Modified bootstrap code so separate prt0.as/prt0_10.as files are no
#     longer necessary
#
# Revision 1.7  2004/05/27 23:15:02  peter
#   * startup argc,argv,envp fix
#   * stat fixed
#
# Revision 1.6  2004/05/17 20:56:56  peter
#   * use ldsh to load exitcode
#
# Revision 1.5  2004/03/16 10:19:11  mazen
# + _haltproc definition for linux/sparc
#
# Revision 1.4  2003/06/02 22:03:37  mazen
# *making init and fini symbols compatible FPC code by
#  changing  _init ==> fpc_initialize
#  and _fini ==> fpc_finalize
#
# Revision 1.3  2002/11/18 19:03:46  mazen
# * start code of gcc adapted for FPC
#

