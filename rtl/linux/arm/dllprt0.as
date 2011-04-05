.file   "dllprt0.as"
.text
        .globl  _startlib
        .type   _startlib,#function
_startlib:
        .globl  FPC_SHARED_LIB_START
        .type   FPC_SHARED_LIB_START,#function
FPC_SHARED_LIB_START:
        mov ip, sp
        stmfd sp!,{fp, ip, lr, pc}
        sub fp, ip, #4

        /* a1 contains argc, a2 contains argv and a3 contains envp */
        ldr ip, =operatingsystem_parameter_argc
        str a1, [ip]

        ldr ip, =operatingsystem_parameter_argv
        str a2, [ip]

        ldr ip, =operatingsystem_parameter_envp
        str a3, [ip]

        /* save initial stackpointer */
        ldr ip, =__stklen
        str sp, [ip]

        ldr ip, =TC_SYSTEM_ISLIBRARY
        mov a1, #1
        str a1, [ip]

        /* call main and exit normally */
        bl PASCALMAIN
        ldmdb fp, {fp, sp, pc}

        .globl  _haltproc
        .type   _haltproc,#function
_haltproc:
        /* r0 contains exitcode */
        swi 0x900001
        b _haltproc

        .globl  _haltproc_eabi
        .type   _haltproc_eabi,#function
_haltproc_eabi:
        /* r0 contains exitcode */
        mov r7,#248
        swi 0x0
        b _haltproc_eabi

.data

        .type operatingsystem_parameters,#object
        .size operatingsystem_parameters,12
operatingsystem_parameters:
        .skip 3*4
        .global operatingsystem_parameter_envp
        .global operatingsystem_parameter_argc
        .global operatingsystem_parameter_argv
        .set operatingsystem_parameter_envp,operatingsystem_parameters+0
        .set operatingsystem_parameter_argc,operatingsystem_parameters+4
        .set operatingsystem_parameter_argv,operatingsystem_parameters+8

.bss

        .comm __stkptr,4

