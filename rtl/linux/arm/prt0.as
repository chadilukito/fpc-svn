/* Startup code for ARM & ELF
   Copyright (C) 1995, 1996, 1997, 1998, 2001, 2002 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

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
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.  */

/* This is the canonical entry point, usually the first thing in the text
   segment.

	Note that the code in the .init section has already been run.
	This includes _init and _libc_init


	At this entry point, most registers' values are unspecified, except:

   a1		Contains a function pointer to be registered with `atexit'.
		This is how the dynamic linker arranges to have DT_FINI
		functions called for shared libraries that have been loaded
		before this code runs.

   sp		The stack contains the arguments and environment:
		0(sp)			argc
		4(sp)			argv[0]
		...
		(4*argc)(sp)		NULL
		(4*(argc+1))(sp)	envp[0]
		...
					NULL
*/

	.text
	.globl _dynamic_start
	.type _dynamic_start,#function
_dynamic_start:
.ifdef __thumb__
         ldr r7,=__dl_fini
         str a1,[r7]
.else
         ldr ip,=__dl_fini
         str a1,[ip]
.endif
         b _start

	.text
	.globl _start
	.type _start,#function
_start:
.ifdef __thumb__
        pop {a2}

        /* Pop argc off the stack and save a pointer to argv */
	ldr r7,=operatingsystem_parameter_argc
	str a2,[r7]

	ldr r7,=operatingsystem_parameter_argv
        mov a3,sp
   	str a3,[r7]

	/* calc envp */
	ldr r7,=operatingsystem_parameter_envp
	add a2,a2,#1
        lsl a2,a2,#2
	add a2,sp,a2
        str a2,[r7]

        /* Save initial stackpointer */
	ldr r7,=__stkptr
        str a3,[r7]

	/* Clear the frame pointer since this is the outermost frame.  */
	mov r7, #0
.else
	mov fp, #0
	ldmia   sp!, {a2}

        /* Pop argc off the stack and save a pointer to argv */
	ldr ip,=operatingsystem_parameter_argc
	ldr a3,=operatingsystem_parameter_argv
	str a2,[ip]

	/* calc envp */
	add a2,a2,#1
	add a2,sp,a2,LSL #2
	ldr ip,=operatingsystem_parameter_envp

	str sp,[a3]
   	str a2,[ip]

        /* Save initial stackpointer */
	ldr ip,=__stkptr
	str sp,[ip]
.endif

        /* align sp again to 8 byte boundary, needed by eabi */
        sub sp,sp,#4

	/* Initialize TLS */
	bl FPC_INITTLS

	/* Call main program, it will never return  */
	bl PASCALMAIN

	.globl  _haltproc
    .type   _haltproc,#function
_haltproc:
        /* r0 contains exitcode */
.ifdef __thumb__
        ldr r0,=operatingsystem_result
        ldr r0,[r0]
        mov r7,#248  /* exit group call */
	swi 0x0
.else
	swi 0x900001
.endif
	b _haltproc

	.globl  _haltproc_eabi
        .type   _haltproc_eabi,#function
_haltproc_eabi:
        ldr r0,=__dl_fini
        ldr r0,[r0]
        cmp r0,#0

.ifdef __thumb__
        beq .Lnobranch
        /* only branch if not equal zero */
        mov lr,pc
        bx  r0     /* we require armv5 anyway, so use bx here */
.Lnobranch:
.else
        /* only branch if not equal zero */
        movne lr,pc
        bxne  r0     /* we require armv5 anyway, so use bx here */
.endif

.Lloop:
        ldr r0,=operatingsystem_result
        ldr r0,[r0]
        mov r7,#248  /* exit group call */
	swi 0x0
	b .Lloop

	/* Define a symbol for the first piece of initialized data.  */
	.data
	.globl __data_start
__data_start:
	.long 0
	.weak data_start
	data_start = __data_start

.bss
        .comm __dl_fini,4
        .comm __stkptr,4

        .comm operatingsystem_parameter_envp,4
        .comm operatingsystem_parameter_argc,4
        .comm operatingsystem_parameter_argv,4

	.section ".comment"
	.byte 0
	.ascii "generated by FPC http://www.freepascal.org\0"

