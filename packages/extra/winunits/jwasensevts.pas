
{******************************************************************************}
{                                                                              }
{ System Event Notification Services API interface Unit for Object Pascal      }
{                                                                              }
{ Portions created by Microsoft are Copyright (C) 1995-2001 Microsoft          }
{ Corporation. All Rights Reserved.                                            }
{                                                                              }
{ The original file is: sensevts.h, released March 2003. The original Pascal   }
{ code is: SensEvts.pas, released April 2003. The initial developer of the     }
{ Pascal code is Marcel van Brakel (brakelm att chello dott nl).               }
{                                                                              }
{ Portions created by Marcel van Brakel are Copyright (C) 1999-2001            }
{ Marcel van Brakel. All Rights Reserved.                                      }
{                                                                              }
{ Obtained through: Joint Endeavour of Delphi Innovators (Project JEDI)        }
{                                                                              }
{ You may retrieve the latest version of this file at the Project JEDI         }
{ APILIB home page, located at http://jedi-apilib.sourceforge.net              }
{                                                                              }
{ The contents of this file are used with permission, subject to the Mozilla   }
{ Public License Version 1.1 (the "License"); you may not use this file except }
{ in compliance with the License. You may obtain a copy of the License at      }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                      }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ Alternatively, the contents of this file may be used under the terms of the  }
{ GNU Lesser General Public License (the  "LGPL License"), in which case the   }
{ provisions of the LGPL License are applicable instead of those above.        }
{ If you wish to allow use of your version of this file only under the terms   }
{ of the LGPL License and not to allow others to use your version of this file }
{ under the MPL, indicate your decision by deleting  the provisions above and  }
{ replace  them with the notice and other provisions required by the LGPL      }
{ License.  If you do not delete the provisions above, a recipient may use     }
{ your version of this file under either the MPL or the LGPL License.          }
{                                                                              }
{ For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html }
{                                                                              }
{******************************************************************************}

// $Id: jwasensevts.pas,v 1.1 2005/04/04 07:56:10 marco Exp $

unit JwaSensEvts;

{$WEAKPACKAGEUNIT}

{$HPPEMIT ''}
{$HPPEMIT '#include "SensEvts.h"'}
{$HPPEMIT ''}

{$I jediapilib.inc}

interface

uses
  JwaWinNT, JwaWinType;

//
// SENS Events Type library
//

//[
//uuid(d597deed-5b9f-11d1-8dd2-00aa004abd5e),
//version(2.0),
//helpstring("SENS Events Type Library")
//]

//library SensEvents
//{
//
//typedef [uuid(d597fad1-5b9f-11d1-8dd2-00aa004abd5e)] struct SENS_QOCINFO

type
  SENS_QOCINFO = record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwOutSpeed: DWORD;
    dwInSpeed: DWORD;
  end;
  {$EXTERNALSYM SENS_QOCINFO}
  LPSENS_QOCINFO = ^SENS_QOCINFO;
  {$EXTERNALSYM LPSENS_QOCINFO}
  TSensQocInfo = SENS_QOCINFO;
  PSensQocInfo = LPSENS_QOCINFO;

//
// Interface ISensNetwork
//

  ISensNetwork = interface (IDispatch)
  ['{d597bab1-5b9f-11d1-8dd2-00aa004abd5e}']
    function ConnectionMade(bstrConnection: WideString; ulType: ULONG; lpQOCInfo: LPSENS_QOCINFO): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 1; {$endif}
    function ConnectionMadeNoQOCInfo(bstrConnection: WideString; ulType: ULONG): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 2; {$endif}
    function ConnectionLost(bstrConnection: WideString; ulType: ULONG): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 3; {$endif}
    function DestinationReachable(bstrDestination, bstrConnection: WideString; ulType: ULONG; lpQOCInfo: LPSENS_QOCINFO): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 4; {$endif}
    function DestinationReachableNoQOCInfo(bstrDestination, bstrConnection: WideString; ulType: ULONG): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 5; {$endif}
  end;
  {$EXTERNALSYM ISensNetwork}

//
// Interface ISensOnNow
//

  ISensOnNow = interface (IDispatch)
  ['{d597bab2-5b9f-11d1-8dd2-00aa004abd5e}']
    function OnACPower: HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 1; {$endif}
    function OnBatteryPower(dwBatteryLifePercent: DWORD): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 2; {$endif}
    function BatteryLow(dwBatteryLifePercent: DWORD): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 3; {$endif}
  end;
  {$EXTERNALSYM ISensOnNow}

//
// Interface ISensLogon
//

  ISensLogon = interface (IDispatch)
  ['{d597bab3-5b9f-11d1-8dd2-00aa004abd5e}']
    function Logon(bstrUserName: WideString): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 1;  {$endif}
    function Logoff(bstrUserName: WideString): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 2; {$endif}
    function StartShell(bstrUserName: WideString): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 3; {$endif}
    function DisplayLock(bstrUserName: WideString): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 4;{$endif}
    function DisplayUnlock(bstrUserName: WideString): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 5;{$endif}
    function StartScreenSaver(bstrUserName: WideString): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 6;{$endif}
    function StopScreenSaver(bstrUserName: WideString): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 7;{$endif}
  end;
  {$EXTERNALSYM ISensLogon}

//
// Interface ISensLogon2
//

  ISensLogon2 = interface (IDispatch)
  ['{d597bab4-5b9f-11d1-8dd2-00aa004abd5e}']
    function Logon(bstrUserName: WideString; dwSessionId: DWORD): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 1; {$endif}
    function Logoff(bstrUserName: WideString; dwSessionId: DWORD): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 2;{$endif}
    function SessionDisconnect(bstrUserName: WideString; dwSessionId: DWORD): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 3;{$endif}
    function SessionReconnect(bstrUserName: WideString; dwSessionId: DWORD): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 4; {$endif}
    function PostShell(bstrUserName: WideString; dwSessionId: DWORD): HRESULT; stdcall; {$IFDEF SUPPORTS_DISPID} dispid 5; {$endif}
  end;
  {$EXTERNALSYM ISensLogon2}

//
// CoClass SENS
//

//    [
//    uuid(d597cafe-5b9f-11d1-8dd2-00aa004abd5e),
//    helpstring("System Event Notification Service (SENS)")
//    ]
//    coclass SENS
//    {
//        [default, source]   interface ISensNetwork;
//        [source]            interface ISensOnNow;
//        [source]            interface ISensLogon;
//        [source]            interface ISensLogon2;
//    };
//};

const
  CLSID_SENS: TGUID = '{d597cafe-5b9f-11d1-8dd2-00aa004abd5e}';
  {$EXTERNALSYM CLSID_SENS}

implementation

end.
