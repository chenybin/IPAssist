unit IPEdit;

interface

uses Windows, Messages, SysUtils, Classes, Forms, Controls, ComCtrls, CommCtrl;

type
    TFieldRange = record
        LowRange:Byte;
        HighRange:Byte;
    end;

    TFieldChangeEvent = procedure(Sender:TObject;
        OldField, Value:Byte) of object;

    TIPEdit = class(TWinControl)
    private
        FIP:LongWord;
        FFields:array[0..3] of Byte;
        FFieldRanges:array[0..3] of TFieldRange;
        FCreating:Boolean;
        FOnChange:TNotifyEvent;
        FOnEnter:TNotifyEvent;
        FOnExit:TNotifyEvent;
        FOnFieldChange:TFieldChangeEvent;
        procedure SetIP(Value:LongWord);
        function GetIP:LongWord;
        function GetField(Index:Integer):Byte;
        procedure SetField(Index:Integer; B:Byte);
        function GetFieldRange(Field:Integer):
            TFieldRange;
        procedure SetFieldRange(Field:integer; Value:
            TFieldRange);
        procedure SetIPAddress;
        function GetBlank:Boolean;
        procedure WMNotifyFormat(var Message:TMessage);
            message WM_NOTIFYFORMAT;
        //处理IP控件的通知消息IPN_FIELDCHANGED
        procedure CNNotify(var Message:TWMNotify);
            message CN_NOTIFY;
        procedure CNCommand(var Message:TWMCommand);
            message CN_COMMAND;
        procedure WMSetFont(var Message:TWMSetFont);
            message WM_SETFONT;
    protected
        procedure CreateParams(var Params:TCreateParams); override;
        procedure CreateWnd; override;
        procedure DestroyWnd; override;
    public
        constructor Create(AOwner:TComponent); override;
        destructor Destroy; override;
        //清除IP控件中的IP串
        procedure Clear;
        //设置IP控件的输入焦点（field的有效取值为0..3）
        procedure SetFieldFocus(Field:Byte);
    published
        //判断IP控件的IP串是否为空
        property Blank:Boolean read GetBlank;
        //Field0到Field3分别为IP控件的4个部分的值
        property Field0:Byte index 0 read
            GetField write SetField;
        property Field1:Byte index 1 read
            GetField write SetField;
        property Field2:Byte index 2 read
            GetField write SetField;
        property Field3:Byte index 3 read
            GetField write SetField;
        //Field0Range到Field3Range 限制IP控件各部分的取值的范围
            property Field0Range:TFieldRange index 0 read
            GetFieldRange write SetFieldRange;
        property Field1Range:TFieldRange index 1 read
            GetFieldRange write SetFieldRange;
        property Field2Range:TFieldRange index 2 read
            GetFieldRange write SetFieldRange;
        property Field3Range:TFieldRange index 3 read
            GetFieldRange write SetFieldRange;
        //IP地址值(32位整数LongWord)
        property IP:LongWord read GetIP write SetIP;
         //事件属性
        property OnChange:TNotifyEvent read FOnChange write
            FOnChange;
        property OnEnter:TNotifyEvent read FOnEnter write
            FOnEnter;
        property OnExit:TNotifyEvent read FOnExit write
            FOnExit;
        property OnFieldChange:TFieldChangeEvent read
            FOnFieldChange
            write FOnFieldChange;
        //以下属性继承自TWinControl控件
        property Enabled;
        property TabOrder;
        property TabStop;
        property ParentShowHint;
        property ShowHint;
        property Hint;
        property Visible;
    end;

implementation

{～TIPEdit～～～～～～～～～～～～～～～～～～}

constructor TIPEdit.Create(AOwner:TComponent);
var
    i:integer;
begin
    //初始化ICC_INTERNET_CLASSES类控件
    CheckCommonControl(ICC_INTERNET_CLASSES);
    inherited Create(AOwner);
    for i := 0 to 3 do
    begin
        FFieldRanges[i].LowRange := 0;
        FFieldRanges[i].HighRange := 255;
        FFields[i] := 0;
    end;
    FIP := 0;
    Height := 25;
    Width := 152;
    TabSTop := True;
end;

procedure TIPEdit.DestroyWnd;
begin
    inherited DestroyWnd
end;

destructor TIPEdit.Destroy;
begin
    inherited Destroy;
end;

procedure TIPEdit.CreateParams(var Params:
    TCreateParams);
begin
    inherited CreateParams(Params);
    CreateSubClass(Params, WC_IPADDRESS);
    with Params do
    begin
    end;
end;

procedure TIPEdit.CreateWnd;
begin
    FCreating := True;
    try
        inherited CreateWnd;
        SetIPAddress;
    finally
        FCreating := False;
    end;
end;

function TIPEdit.GetBlank:Boolean;
begin
    Result := Boolean(SendMessage(Handle, IPM_ISBLANK, 0, 0));
end;

procedure TIPEdit.Clear;
begin
    SendMessage(Handle, IPM_CLEARADDRESS, 0, 0);
end;

procedure TIPEdit.SetFieldFocus(Field:Byte);
begin
    SendMessage(Handle, IPM_SETFOCUS, Field, 0);
end;

function TIPEdit.GetFieldRange(Field:Integer):TFieldRange;
begin
    Result := FFieldRanges[Field];
end;

procedure TIPEdit.SetFieldRange(Field:Integer;
    Value:TFieldRange);
begin
    if Value.LowRange > Value.HighRange then exit;
    if (FFieldRanges[Field].LowRange <> Value.LowRange) or
        (FFieldRanges[Field].HighRange <> Value.HighRange) then
    begin
        FFieldRanges[Field] := Value;
        SendMessage(Handle, IPM_SETRANGE, Field,
            MakeIPRange(Value.LowRange, Value.HighRange));
    end;
end;

function TIPEdit.GetField(Index:Integer):Byte;
begin
    if (Index >= 0) and (Index <= 3) then Result := FFields[Index]
    else Result := 0;
end;

procedure TIPEdit.SetField(Index:Integer; B:Byte);
begin
    if (FFields[Index] <> B) then
    begin
        FFields[Index] := B;
        SetIPAddress;
    end;
end;

procedure TIPEdit.SetIPAddress;
var
    i:LongWord;
begin
    i := MAKEIPADDRESS(FFields[0], FFields[1], FFields[2],
        FFields[3]);
    SendMessage(Handle, IPM_SETADDRESS, 0, i);
    FIP := i;
end;

procedure TIPEdit.SetIP(Value:LongWord);
begin
    if (FIP <> Value) then
    begin
        FFields[0] := First_IPAddress(Value);
        FFields[1] := Second_IPAddress(Value);
        FFields[2] := Third_IPAddress(Value);
        FFields[3] := Fourth_IPAddress(Value);
        SetIPAddress;
    end;
end;

function TIPEdit.GetIP:LongWord;
begin
    SendMessage(Handle, IPM_GETADDRESS, 0, Integer(@Result));
end;

procedure TIPEdit.WMSetFont(var Message:TWMSetFont);
begin
    //不可以调用父控件的此方法
    //否则，控件不能正常工作
end;

procedure TIPEdit.WMNotifyFormat(var Message:
    TMessage);
begin
    with Message do
        Result := DefWindowProc(Handle, Msg, WParam, LParam);
end;

procedure TIPEdit.CNNotify(var Message:TWMNotify);
var
    pNM:PNMIPAddress;
begin
    with (Message.NMHdr)^ do
    begin
        case Code of
            IPN_FIELDCHANGED:
                begin
                    pNM := PNMIPADDRESS(Message.NMHdr);
                    if (pNM^.iField >= 0) and (pNM^.iField <= 3) then
                        FFields[pNM^.iField] := pNM^.iValue;
                    if Assigned(FOnFieldChange) then
                        FOnFieldChange(self, pNM^.iField, pNM^.iValue);
                end;
        end;
    end;
end;

procedure TIPEdit.CNCommand(var Message:TWMCommand);
begin
    case Message.NotifyCode of
        EN_CHANGE:
            begin
                if not FCreating then
                    if Assigned(FOnChange) then FOnChange(self);
            end;
        EN_KILLFOCUS:if Assigned(FOnExit) then FOnExit(self);
        EN_SETFOCUS:if Assigned(FOnEnter) then FOnEnter(self);
    end;
end;

end.

