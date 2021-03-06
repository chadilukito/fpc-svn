{
    This file is part of the Free Pascal run time library.
    Copyright (c) 2002 by Peter Vreman,
    member of the Free Pascal development team.

    FreeRTOS threading support implementation

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{ resourcestrings are not supported by the system unit,
  they are in the objpas unit and not available for fpc/tp modes }
const
  SNoThreads = 'This binary has no thread support compiled in.';
  SRecompileWithThreads = 'Recompile the application with a thread-driver in the program uses clause before other units using thread.';

Procedure NoThreadError;
  begin
  {$ifdef FPC_HAS_FEATURE_CONSOLEIO}
    If IsConsole then
      begin
      Writeln(StdErr,SNoThreads);
      Writeln(StdErr,SRecompileWithThreads);
      end;
  {$endif FPC_HAS_FEATURE_CONSOLEIO}
    RunError(232)
  end;


function  NoGetCurrentThreadId : TThreadID;
  begin
    if IsMultiThread then
      NoThreadError
    else
      ThreadingAlreadyUsed:=true;
    result:=TThreadID(1);
  end;


function NoBeginThread(sa : Pointer;stacksize : PtrUInt;
                     ThreadFunction : tthreadfunc;p : pointer;
                     creationFlags : dword; var ThreadId : TThreadID) : TThreadID;
  begin
    NoThreadError;
    result:=tthreadid(-1);
  end;


procedure SysInitCriticalSection(var cs);
  begin
  end;


procedure SysDoneCriticalSection(var cs);
  begin
  end;


procedure SysEnterCriticalSection(var cs);
  begin
  end;


function SysTryEnterCriticalSection(var cs):longint;
  begin
  end;


procedure SysLeaveCriticalSection(var cs);
  begin
  end;

const
  FreeRTOSThreadManager : TThreadManager = (
    InitManager            : Nil;
    DoneManager            : Nil;
    { while this is pretty hacky, it reduces the size of typical embedded programs
     and works fine on arm and avr }
    BeginThread            : @NoBeginThread;
    EndThread              : TEndThreadHandler(@NoThreadError);
    SuspendThread          : TThreadHandler(@NoThreadError);
    ResumeThread           : TThreadHandler(@NoThreadError);
    KillThread             : TThreadHandler(@NoThreadError);
    CloseThread            : TThreadHandler(@NoThreadError);
    ThreadSwitch           : TThreadSwitchHandler(@NoThreadError);
    WaitForThreadTerminate : TWaitForThreadTerminateHandler(@NoThreadError);
    ThreadSetPriority      : TThreadSetPriorityHandler(@NoThreadError);
    ThreadGetPriority      : TThreadGetPriorityHandler(@NoThreadError);
    GetCurrentThreadId     : @NoGetCurrentThreadId;
    SetThreadDebugNameA    : TThreadSetThreadDebugNameHandlerA(@NoThreadError);
    {$ifdef FPC_HAS_FEATURE_UNICODESTRINGS}
    SetThreadDebugNameU    : TThreadSetThreadDebugNameHandlerU(@NoThreadError);
    {$endif FPC_HAS_FEATURE_UNICODESTRINGS}
    InitCriticalSection    : @SysInitCriticalSection;
    DoneCriticalSection    : @SysDoneCriticalSection;
    EnterCriticalSection   : @SysEnterCriticalSection;
    TryEnterCriticalSection: @SysTryEnterCriticalSection;
    LeaveCriticalSection   : @SysLeaveCriticalSection;
    InitThreadVar          : TInitThreadVarHandler(@NoThreadError);
    RelocateThreadVar      : TRelocateThreadVarHandler(@NoThreadError);
    AllocateThreadVars     : @NoThreadError;
    ReleaseThreadVars      : @NoThreadError;
    BasicEventCreate       : TBasicEventCreateHandler(@NoThreadError);
    BasicEventdestroy      : TBasicEventHandler(@NoThreadError);
    BasicEventResetEvent   : TBasicEventHandler(@NoThreadError);
    BasicEventSetEvent     : TBasicEventHandler(@NoThreadError);
    BasicEventWaitFor      : TBasicEventWaitForHandler(@NoThreadError);
    RTLEventCreate         : TRTLCreateEventHandler(@NoThreadError);
    RTLEventdestroy        : TRTLEventHandler(@NoThreadError);
    RTLEventSetEvent       : TRTLEventHandler(@NoThreadError);
    RTLEventResetEvent     : TRTLEventHandler(@NoThreadError);
    RTLEventWaitFor        : TRTLEventHandler(@NoThreadError);
    RTLEventwaitfortimeout : TRTLEventHandlerTimeout(@NoThreadError);
  );

Procedure InitSystemThreads;
  begin
    SetThreadManager(FreeRTOSThreadManager);
  end;


