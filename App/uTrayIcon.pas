{* What is a tray icon? *

Tray Icons are those you see near the clock,
such as the volume control, or DeskMenu.
You can add your application's icon to the system tray,
the small area on the right side of the task bar,
and react to mouse events occurring on your system tray icon.

* How can I create a tray icon? *

Fortunately, creating an application that runs in the system tray is pretty easy -
only one (API) function, Shell_NotifyIcon, is needed to accomplish the task.
The function is defined in the ShellAPI unit and requires two parameters.

The first parameter (dwMessage) specifies the action to be taken.
This parameter can be one of the following values:

NIM_ADD: Adds an icon to the status area.
NIM_DELETE: Deletes an icon from the status area.
NIM_MODIFY: Modifies an icon in the status area.

* To display an icon in the system tray, call Shell_NotifyIcon with
the NIM_ADD flag.

* Any time you want to change the icon, tooltip text,
etc, you can call Shell_NotifyIcon with NIM_MODIFY.

* Before your program terminates, call Shell_NotifyIcon with NIM_DELETE
to clear your icon from the system tray.

The second parameter (pnid) is a pointer to a TNotifyIconData structure
holding the information about the icon.

The TNotifyIconData structure contains the following elements:

cbSize: Passes the size of the NOTIFYICONDATA data type.
Data Type: DWORD.

hWnd: Handle of the window used to receive the notification message.
Data Type: HWND.

uId: Identifier of the icon in the status area.
Data Type: UINT.

uFlags: Array of flags that indicate which of the other members contain
valid data.
Data Type: UINT.
Value: Any combination of the following constants to indicate that
the member of this structure is valid and will be used:

NIF_ICON: Passing this flag indicates that the value for the
hIcon will be the icon that appears in the taskbar status area.

NIF_MESSAGE: Passing this flag indicates that the uCallBackMessage
value will be used as the callback message.

NIF_TIP: Passing this flag indicates that the value of szTip will
be used as the ToolTip for the icon in the taskbar status area.

uCallBackMessage: Identifier of the notification message sent to the
window that is used to receive the messages.
Data Type: UINT.

hIcon: Handle of the icon that is displayed in the taskbar status area.
Data Type: HICON.

szTip: String to be used as the ToolTip text.
Data Type: Fixed-length AnsiChar 64 bytes long.

NOTIFYICONDATAA.dwInfoFlags就是气泡图标的值。
但是也只有NIIF_NONE（无）
NIIF_INFO（信息）
NIIF_WARNING（警告）
NIIF_ERROR（错误）
NIIF_ICON_MASK（保留）

// Notify Icon Infotip flags
#define NIIF_NONE       0x00000000
// icon flags are mutually exclusive
// and take only the lowest 2 bits
#define NIIF_INFO       0x00000001
#define NIIF_WARNING    0x00000002
#define NIIF_ERROR      0x00000003
#define NIIF_ICON_MASK  0x0000000F
#if (_WIN32_IE >= 0x0501)
#define NIIF_NOSOUND    0x00000010
#endif
#endif

带着这个疑问我尝试着在我的程序内使用NOTIFYICONDATAA.dwInfoFlags = 0x00000004~0x0000000E等值，
发现一个新图标:0x00000007（问号）。可是就这样完了吗？
我发现NOTIFYICONDATAA结构还有个变量hIcon,这个在一般的文章中定义的是程序的图标，难道...？
在尝试几段代码后发现：0x00000004其实是就是自定义类型，
自定义的图标就是NOTIFYICONDATAA.hIcon中Load的图标，现在一切都变的简单了，
只要使用0x00000004就可以随意更换气泡的图标啦~~~

{*****************************************************}

unit uTrayIcon;

interface

{
  A component to make it easier to create a system tray icon.
  Install this component in the Delphi IDE (Component, Install component)
  and drop it on a form, and the application automatically
  becomes a tray icon. This means that when the application is
  minimized, it does not minimize to a normal taskbar icon, but
  to the little system tray on the side of the taskbar. A popup
  menu is available from the system tray icon, and your application
  can process mouse events as the user moves the mouse over
  the system tray icon, clicks on the icon, etc.

  Copyright ? 1996 Tempest Software. All rights reserved.
  You may use this software in an application without fee or royalty,
  provided this copyright notice remains intact.
}

uses
    Windows, Messages, SysUtils, Classes, Graphics, Controls,
    Forms, Dialogs, Menus;

{
  This message is sent to the special, hidden window for shell
  notification messages. Only derived classes might need to
  know about it.
}

const
    WM_CALLBACK_MESSAGE = WM_USER + 1;

    NIF_INFO = $10;
    NIF_MESSAGE = 1;
    NIF_ICON = 2;
    NOTIFYICON_VERSION = 3;
    NIF_TIP = 4;
    NIM_SETVERSION = $00000004;
    NIM_SETFOCUS = $00000003;
    NIIF_INFO = $00000001;
    NIIF_WARNING = $00000002;
    NIIF_ERROR = $00000003;

    NIN_BALLOONSHOW = WM_USER + 2;
    NIN_BALLOONHIDE = WM_USER + 3;
    NIN_BALLOONTIMEOUT = WM_USER + 4;
    NIN_BALLOONUSERCLICK = WM_USER + 5;
    NIN_SELECT = WM_USER + 0;
    NINF_KEY = $1;
    NIN_KEYSELECT = NIN_SELECT or NINF_KEY;

type
    PNotifyIconDataEx = ^TNotifyIconDataEx;
    TDUMMYUNIONNAME = record
        case Integer of
            0:(uTimeout:UINT);
            1:(uVersion:UINT);
    end;

    TNotifyIconDataAEx = record
        cbSize:DWORD;
        Wnd:HWND;
        uID:UINT;
        uFlags:UINT;
        uCallbackMessage:UINT;
        hIcon:HICON;
        //Version 5.0 is 128 chars, old ver is 64 chars
        szTip:array[0..127] of Char;
        dwState:DWORD; //Version 5.0
        dwStateMask:DWORD; //Version 5.0
        szInfo:array[0..255] of Char; //Version 5.0
        DUMMYUNIONNAME:TDUMMYUNIONNAME;
        szInfoTitle:array[0..63] of Char; //Version 5.0
        dwInfoFlags:DWORD; //Version 5.0
    end;

    TNotifyIconDataWEx = record
        cbSize:DWORD;
        Wnd:HWND;
        uID:UINT;
        uFlags:UINT;
        uCallbackMessage:UINT;
        hIcon:HICON;
        //Version 5.0 is 128 chars, old ver is 64 chars
        szTip:array[0..127] of WideChar;
        dwState:DWORD; //Version 5.0
        dwStateMask:DWORD; //Version 5.0
        szInfo:array[0..255] of Char; //Version 5.0
        DUMMYUNIONNAME:TDUMMYUNIONNAME;
        szInfoTitle:array[0..63] of WideChar; //Version 5.0
        dwInfoFlags:DWORD; //Version 5.0
    end;
    TNotifyIconDataEx = TNotifyIconDataAEx;
    TNotifyIconData = TNotifyIconDataAEx;

    TTrayIcon = class(TComponent)
    private
        fData:TNotifyIconData;
        fIcon:TIcon;
        fHint:string;
        fBalloonTipTitle:string;
        fBalloonTipInfo:string;
        fBalloonTipTimeOut:Integer;
        fShowBalloonTip:Boolean;

        fPopupMenu:TPopupMenu;
        fClicked:Boolean;
        fOnClick:TNotifyEvent;
        fOnDblClick:TNotifyEvent;
        fOnMinimize:TNotifyEvent;
        fOnMouseMove:TMouseMoveEvent;
        fOnMouseDown:TMouseEvent;
        fOnMouseUp:TMouseEvent;
        fOnRestore:TNotifyEvent;
        fOnBalloonClick:TNotifyEvent;
        fOnBalloonShow:TNotifyEvent;
        fOnBalloonHide:TNotifyEvent;
        fOnBalloonTimeOut:TNotifyEvent;
    protected
        procedure SetHint(const Hint:string); virtual;
        procedure SetIcon(Icon:TIcon); virtual;
        procedure SetBalloonTipInfo(const BalloonTipInfo:string);
        procedure SetBalloonTipTitle(const BalloonTipTitle:string);
        procedure SetBalloonTipTimeOut(const Value:Integer);
        procedure SetShowBalloonTip(const ShowBalloonTip:Boolean);
        procedure AppMinimize(Sender:TObject);
        procedure AppRestore(Sender:TObject);
        procedure DoMenu; virtual;
        procedure Click; virtual;
        procedure DblClick; virtual;
        procedure EndSession; virtual;
        procedure DoMouseMove(Shift:TShiftState; X, Y:Integer); virtual;
        procedure DoMouseDown(Button:TMouseButton; Shift:TShiftState; X, Y:Integer);
            virtual;
        procedure DoMouseUp(Button:TMouseButton; Shift:TShiftState; X, Y:Integer);
            virtual;
        procedure OnMessage(var Msg:TMessage); virtual;
        procedure BalloonClick(); virtual;
        procedure BalloonShow(); virtual;
        procedure BalloonHide(); virtual;
        procedure BalloonTimeOut(); virtual;
        procedure Changed; virtual;
        property Data:TNotifyIconData read fData;
    public
        constructor Create(Owner:TComponent); override;
        destructor Destroy; override;
        procedure Minimize; virtual;
        procedure Restore; virtual;
    published
        property Hint:string read fHint write SetHint;
        property Icon:TIcon read fIcon write SetIcon;
        property BalloonTipTitle:string read fBalloonTipTitle write SetBalloonTipTitle;
        property BalloonTipInfo:string read fBalloonTipInfo write SetBalloonTipInfo;
        property BalloonTipTimeOut:Integer read fBalloonTipTimeOut write SetBalloonTipTimeOut;
        property ShowBalloonTip:Boolean read fShowBalloonTip write SetShowBalloonTip;
        property PopupMenu:TPopupMenu read fPopupMenu write fPopupMenu;
        property OnClick:TNotifyEvent read fOnClick write fOnClick;
        property OnDblClick:TNotifyEvent read fOnDblClick write fOnDblClick;
        property OnMinimize:TNotifyEvent read fOnMinimize write fOnMinimize;
        property OnMouseMove:TMouseMoveEvent read fOnMouseMove write fOnMouseMove;
        property OnMouseDown:TMouseEvent read fOnMouseDown write fOnMouseDown;
        property OnMouseUp:TMouseEvent read fOnMouseUp write fOnMouseUp;
        property OnRestore:TNotifyEvent read fOnRestore write fOnRestore;
        property OnBalloonClick:TNotifyEvent read fOnBalloonClick write fOnBalloonClick;
        property OnBalloonShow:TNotifyEvent read fOnBalloonShow write fOnBalloonShow;
        property OnBalloonHide:TNotifyEvent read fOnBalloonHide write fOnBalloonHide;
        property OnBalloonTimeOut:TNotifyEvent read fOnBalloonTimeOut write fOnBalloonTimeOut;
    end;

procedure Register;

implementation
uses
    ShellAPI;
{
  Create the component. At run-time, automatically add a tray icon
  with a callback to a hidden window. Use the application icon and title.
}

constructor TTrayIcon.Create(Owner:TComponent);
begin
    inherited Create(Owner);
    fIcon := TIcon.Create;
    fIcon.Assign(Application.Icon);
    if not (csDesigning in ComponentState) then begin
        FillChar(fData, SizeOf(fData), 0);
        fData.cbSize := SizeOf(fData);
        fData.Wnd := Classes.AllocateHwnd(OnMessage); // handle to get notification message
        fData.hIcon := Icon.Handle; // icon to display
        StrPLCopy(fData.szTip, Application.Title, SizeOf(fData.szTip) - 1);
        fData.uFlags := Nif_Icon or Nif_Message;
        if Application.Title <> '' then
            fData.uFlags := fData.uFlags or Nif_Tip;
        fData.uCallbackMessage := WM_CALLBACK_MESSAGE;
        fData.DUMMYUNIONNAME.uTimeout := 300;

        BalloonTipTitle := Application.Title;
        ShowBalloonTip := False;
        if not Shell_NotifyIcon(NIM_ADD, @fData) then // add it
            raise EOutOfResources.Create('Cannot create shell notification icon');
        {
          Replace the application's minimize and restore handlers with
          special ones for the tray. The TrayIcon component has its own
          OnMinimize and OnRestore events that the user can set.
        }
        Application.OnMinimize := AppMinimize;
        Application.OnRestore := AppRestore;
        fData.DUMMYUNIONNAME.uVersion := NOTIFYICON_VERSION;
        //..if not Shell_NotifyIcon(NIM_SETVERSION, @fData) then
            //ShowMessage('setversion fail');
    end;
end;

{ Remove the icon from the system tray.}

destructor TTrayIcon.Destroy;
begin
    fIcon.Free;
    if not (csDesigning in ComponentState) then begin
        Classes.DeallocateHWnd(fData.Wnd);
        Shell_NotifyIcon(Nim_Delete, @fData);
    end;
    inherited Destroy;
end;

{ Whenever any information changes, update the system tray. }

procedure TTrayIcon.Changed;
begin
    if not (csDesigning in ComponentState) then
        Shell_NotifyIcon(NIM_MODIFY, @fData);
end;

{ When the Application is minimized, minimize to the system tray.}

procedure TTrayIcon.AppMinimize(Sender:TObject);
begin
    Minimize
end;

{ When restoring from the system tray, restore the application. }

procedure TTrayIcon.AppRestore(Sender:TObject);
begin
    Restore
end;

{
  Message handler for the hidden shell notification window.
  Most messages use Wm_Callback_Message as the Msg ID, with
  WParam as the ID of the shell notify icon data. LParam is
  a message ID for the actual message, e.g., Wm_MouseMove.
  Another important message is Wm_EndSession, telling the
  shell notify icon to delete itself, so Windows can shut down.

  Send the usual Delphi events for the mouse messages. Also
  interpolate the OnClick event when the user clicks the
  left button, and popup the menu, if there is one, for
  right click events.
}

procedure TTrayIcon.OnMessage(var Msg:TMessage);
{ Return the state of the shift keys. }
    function ShiftState:TShiftState;
    begin
        Result := [];
        if GetKeyState(VK_SHIFT) < 0 then
            Include(Result, ssShift);
        if GetKeyState(VK_CONTROL) < 0 then
            Include(Result, ssCtrl);
        if GetKeyState(VK_MENU) < 0 then
            Include(Result, ssAlt);
    end;
var
    Pt:TPoint;
    Shift:TShiftState;
begin
    case Msg.Msg of
        Wm_QueryEndSession:
            Msg.Result := 1;
        Wm_EndSession:
            if TWmEndSession(Msg).EndSession then
                EndSession;
        Wm_Callback_Message:
            case Msg.lParam of
                WM_MOUSEMOVE:begin
                        Shift := ShiftState;
                        GetCursorPos(Pt);
                        DoMouseMove(Shift, Pt.X, Pt.Y);
                    end;
                WM_LBUTTONDOWN:begin
                        Shift := ShiftState + [ssLeft];
                        GetCursorPos(Pt);
                        DoMouseDown(mbLeft, Shift, Pt.X, Pt.Y);
                        fClicked := True;
                    end;
                WM_LBUTTONUP:begin
                        Shift := ShiftState + [ssLeft];
                        GetCursorPos(Pt);
                        if fClicked then begin
                            fClicked := False;
                            Click;
                        end;
                        DoMouseUp(mbLeft, Shift, Pt.X, Pt.Y);
                    end;
                WM_LBUTTONDBLCLK:
                    DblClick;
                WM_RBUTTONDOWN:begin
                        Shift := ShiftState + [ssRight];
                        GetCursorPos(Pt);
                        DoMouseDown(mbRight, Shift, Pt.X, Pt.Y);
                        DoMenu;
                    end;
                WM_RBUTTONUP:begin
                        Shift := ShiftState + [ssRight];
                        GetCursorPos(Pt);
                        DoMouseUp(mbRight, Shift, Pt.X, Pt.Y);
                    end;
                WM_RBUTTONDBLCLK:
                    DblClick;
                WM_MBUTTONDOWN:begin
                        Shift := ShiftState + [ssMiddle];
                        GetCursorPos(Pt);
                        DoMouseDown(mbMiddle, Shift, Pt.X, Pt.Y);
                    end;
                WM_MBUTTONUP:begin
                        Shift := ShiftState + [ssMiddle];
                        GetCursorPos(Pt);
                        DoMouseUp(mbMiddle, Shift, Pt.X, Pt.Y);
                    end;
                WM_MBUTTONDBLCLK:
                    DblClick;
                NIN_BALLOONSHOW:
                    {Sent when the balloon is shown}
                    BalloonShow;
                NIN_BALLOONHIDE:
                    {Sent when the balloon disappears?Rwhen the icon is deleted,
                    for example. This message is not sent if the balloon is dismissed because of
                    a timeout or mouse click by the user. }
                    BalloonHide;
                NIN_BALLOONTIMEOUT:
                    {Sent when the balloon is dismissed because of a timeout.}
                    BalloonTimeOut;
                NIN_BALLOONUSERCLICK:
                    {Sent when the balloon is dismissed because the user clicked the mouse.
                    Note: in XP there's Close button on he balloon tips, when click the button,
                    send NIN_BALLOONTIMEOUT message actually.}
                    BalloonClick;
            end;
    end;
end;

{ Set a new hint, which is the tool tip for the shell icon. }

procedure TTrayIcon.SetHint(const Hint:string);
begin
    if fHint <> Hint then begin
        fHint := Hint;
        StrPLCopy(fData.szTip, Hint, SizeOf(fData.szTip) - 1);
        if Hint <> '' then
            fData.uFlags := fData.uFlags or Nif_Tip
        else
            fData.uFlags := fData.uFlags and not Nif_Tip;
        Changed;
    end;
end;

{ Set a new icon. Update the system tray. }

procedure TTrayIcon.SetIcon(Icon:TIcon);
begin
    if fIcon <> Icon then begin
        fIcon.Assign(Icon);
        fData.hIcon := Icon.Handle;
        Changed;
    end;
end;

procedure TTrayIcon.SetBalloonTipInfo(const BalloonTipInfo:string);
begin
    // BallonTip's Info
    if fBalloonTipInfo <> BalloonTipInfo then begin
        fBalloonTipInfo := BalloonTipInfo;
        StrPLCopy(fData.szInfo, BalloonTipInfo, SizeOf(fData.szInfo) - 1);
        Changed;
    end;
end;

procedure TTrayIcon.SetBalloonTipTitle(const BalloonTipTitle:string);
begin
    // BallonTip's Title
    if fBalloonTipTitle <> BalloonTipTitle then begin
        fBalloonTipTitle := BalloonTipTitle;
        StrPLCopy(fData.szInfoTitle, BalloonTipTitle, SizeOf(fData.szInfoTitle) - 1);
        Changed;
    end;
end;

procedure TTrayIcon.SetBalloonTipTimeOut(const Value:Integer);
begin
    if Value <> fBalloonTipTimeOut then begin
        fData.DUMMYUNIONNAME.uTimeout := Value;
        fBalloonTipTimeOut := Value;
        Changed;
    end;
end;

procedure TTrayIcon.SetShowBalloonTip(const ShowBalloonTip:Boolean);
begin
    // show/Hide BalloonTip
    if ShowBalloonTip then begin
        fData.uFlags := fData.uFlags or NIF_INFO;
        fData.dwInfoFlags := fData.dwInfoFlags or NIIF_INFO;
    end
    else begin
        fData.uFlags := fData.uFlags and not NIF_INFO;
        fData.dwInfoFlags := fData.dwInfoFlags and not NIIF_INFO;
    end;
    Changed;
    if fShowBalloonTip = ShowBalloonTip then Exit;
    fShowBalloonTip := ShowBalloonTip;
end;

{
  When the user right clicks the icon, call DoMenu.
  If there is a popup menu, and if the window is minimized,
  then popup the menu.
}

procedure TTrayIcon.DoMenu;
var
    Pt:TPoint;
begin
    if (fPopupMenu <> nil) and not IsWindowVisible(Application.Handle) then begin
        GetCursorPos(Pt);
        fPopupMenu.Popup(Pt.X, Pt.Y);
    end;
end;

procedure TTrayIcon.Click;
begin
    if Assigned(fOnClick) then
        fOnClick(Self);
end;

procedure TTrayIcon.DblClick;
begin
    if Assigned(fOnDblClick) then
        fOnDblClick(Self);
end;

procedure TTrayIcon.BalloonClick();
begin
    if Assigned(fOnBalloonClick) then
        fOnBalloonClick(Self);
end;

procedure TTrayIcon.BalloonHide;
begin
    if Assigned(fOnBalloonHide) then
        fOnBalloonHide(Self);
end;

procedure TTrayIcon.BalloonShow;
begin
    if Assigned(fOnBalloonShow) then
        fOnBalloonShow(Self);
end;

procedure TTrayIcon.BalloonTimeOut;
begin
    if Assigned(fOnBalloonTimeOut) then
        fOnBalloonTimeOut(Self);
end;

procedure TTrayIcon.DoMouseMove(Shift:TShiftState; X, Y:Integer);
begin
    if Assigned(fOnMouseMove) then
        fOnMouseMove(Self, Shift, X, Y);
end;

procedure TTrayIcon.DoMouseDown(Button:TMouseButton; Shift:TShiftState; X, Y:Integer);
begin
    if Assigned(fOnMouseDown) then
        fOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TTrayIcon.DoMouseUp(Button:TMouseButton; Shift:TShiftState; X, Y:Integer);
begin
    if Assigned(fOnMouseUp) then
        fOnMouseUp(Self, Button, Shift, X, Y);
end;

{
  When the application minimizes, hide it, so only the icon
  in the system tray is visible.
}

procedure TTrayIcon.Minimize;
begin
    ShowWindow(Application.Handle, SW_HIDE);
    if Assigned(fOnMinimize) then
        fOnMinimize(Self);
end;

{
  Restore the application by making its window visible again,
  which is a little weird since its window is invisible, having
  no height or width, but that's what determines whether the button
  appears on the taskbar.
}

procedure TTrayIcon.Restore;
begin
    ShowWindow(Application.Handle, SW_RESTORE);
    if Assigned(fOnRestore) then
        fOnRestore(Self);
end;

{ Allow Windows to exit by deleting the shell notify icon. }

procedure TTrayIcon.EndSession;
begin
    Shell_NotifyIcon(Nim_Delete, @fData);
end;

procedure Register;
begin
    RegisterComponents('Tempest', [TTrayIcon]);
end;

end.

