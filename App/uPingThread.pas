unit uPingThread;

interface

uses
    Windows, Classes, Messages, uICMPUtil, StdCtrls, uIPAssist, SysUtils;

type
    // ²éÑ¯½ø¶È
    TOnProcess = procedure(AControlName:string; nResult:Integer; bFinished:Boolean = False) of object;

    TPingThread = class(TThread)
    private
        { Private declarations }
        FPingEvent:THandle;
        FOnProcess:TOnProcess;
        FICMPUtil:TICMPUtil;
        FControlList:TThreadList;
        FException:Exception;
        procedure DoHandleException;
        procedure Ping;
    protected
        procedure Execute; override;
        procedure HandleException; virtual;
    public
        constructor Create(AICMPUtil:TICMPUtil);
        destructor Destroy; override;
    public
        property ControlList:TThreadList read FControlList write FControlList;
        property PingEvent:THandle read FPingEvent;
        property OnProcess:TOnProcess read FOnProcess write FOnProcess;
    end;

implementation

uses uSysInfo, uUtiles;

constructor TPingThread.Create(AICMPUtil:TICMPUtil);
begin
    inherited Create(False);
    FPingEvent := CreateEvent(nil, False, False, 'IPPing');
    FreeOnTerminate := False;
    FICMPUtil := AICMPUtil;
    FControlList := TThreadList.Create;
end;

destructor TPingThread.Destroy;
begin
    if Assigned(FControlList) then begin
        FControlList.Clear;
        FControlList.Free;
    end;
    CloseHandle(FPingEvent);
    inherited;
end;

procedure TPingThread.DoHandleException;
begin
    FException := Exception(ExceptObject);
    try
        // Don't show EAbort messages
        if not (FException is EAbort) then
            Synchronize(DoHandleException);
    finally
        FException := nil;
    end;
end;

procedure TPingThread.HandleException;
begin
    // This function is virtual so you can override it
      // and add your own functionality.
    FException := Exception(ExceptObject);
    try
        // Don't show EAbort messages
        if not (FException is EAbort) then
            Synchronize(DoHandleException);
    finally
        FException := nil;
    end;
end;

procedure TPingThread.Execute;
begin
    while not Terminated do begin
        case WaitForSingleObject(FPingEvent, INFINITE) of
            WAIT_OBJECT_0:begin
                    Synchronize(Ping);
                end;
        end;
    end;
end;

procedure TPingThread.Ping;
var
    nRet:Integer;
    FIP:string;
    i:Integer;
    FControl:TCustomEdit;
    bFinished:Boolean;
const
    LISTCOUNT:Integer = 3;
begin
    FException := nil;
    try
        FControlList.LockList;
        try
            for i := 0 to LISTCOUNT - 1 do begin
                if Terminated then Exit;
                bFinished := (i >= LISTCOUNT - 1);
                FControl := TCustomEdit(FControlList.LockList.Items[i]);
                if not Assigned(FControl) then Continue;
                if Terminated then Exit;
                FIP := FControl.Text;
                if FIP = '' then begin
                    if Assigned(FOnProcess) then
                        FOnProcess(FControl.Name, -2, bFinished);
                    if bFinished then ResetEvent(FPingEvent);
                    Continue;
                end;
                if not Assigned(FICMPUtil) then Continue;
                if not TICMPUtil.CheckIPValid(FIP) then nRet := -1
                else nRet := FICMPUtil.PingIP(FIP);
                if Assigned(FOnProcess) then
                    FOnProcess(FControl.Name, nRet, bFinished);
                if bFinished then ResetEvent(FPingEvent);
            end;
        finally
            FControlList.UnlockList;
        end;
    except
        HandleException;
    end;
end;

end.

