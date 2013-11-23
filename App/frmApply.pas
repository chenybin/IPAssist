unit frmApply;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, RzEdit, RzButton, RzLabel, uIPAssist, jpeg, ExtCtrls;

type
    TApplyForm = class(TForm)
        lbAdapter:TRzLabel;
        lbAdapterName:TRzLabel;
        bbtnOK:TRzBitBtn;
        bbtnCancel:TRzBitBtn;
        memSource:TRzMemo;
        memDest:TRzMemo;
        memArrow:TRzMemo;
        lbStatus:TRzLabel;
        tmApply:TTimer;
        lbIP:TRzLabel;
        lbMask:TRzLabel;
        lbGateway:TRzLabel;
        lbPrimaryDNS:TRzLabel;
        lbSecondaryDNS:TRzLabel;
    private
        { Private declarations }
        FSourceIP, FDestIP:TIPConfig;
        FIPSetUtil:TIPSetUtil;
        FOldTime:Cardinal;
        FAdapterName:string;

        procedure UpdateControls;
        procedure InitEvent;
        procedure UpdateLanguage;
        function Apply:Boolean;
        procedure EnabledControls(bEnabled:Boolean);

        procedure ClearEmpty;

        ////////////// Event /////////////////
        procedure bbtnOKClick(Sender:TObject);
        procedure tmApplyTimer(Sender:TObject);
    public
        { Public declarations }
        constructor Create(AOwner:TComponent; Connection:TConnection; DestIP:TIPConfig; IPSetUtil:TIPSetUtil); reintroduce; overload;
        constructor Create(AOwner:TComponent); overload; override;
        destructor Destroy; override;
        procedure Initialize;
    end;

var
    ApplyForm:TApplyForm;

implementation
uses
    uSysInfo;
{$R *.dfm}

{ TForm1 }

function TApplyForm.Apply:Boolean;
var
    nRet:Integer;
    time1, time2, nTick:Integer;
begin
    Result := False;
    EnabledControls(False);
    lbStatus.Caption := SysInfo.GetMessage('ApplingIP');
    Application.ProcessMessages;
    time1 := GetTickCount;
    nRet := FIPSetUtil.SetIPInfor(FDestIP);
    time2 := GetTickCount;
    nTick := time2 - time1;
    if nRet = 0 then begin
        Result := True;
        lbStatus.Caption := SysInfo.GetMessage('Success');
        // 直接更新结果到对应的设备类中
        FSourceIP.Assign(FDestIP);
    end
    else
        lbStatus.Caption := SysInfo.GetMessage('Faile');

    lbStatus.Caption := Format(lbStatus.Caption + SysInfo.GetMessage('LastTime', '%d'), [nTick]);
    EnabledControls(True);
end;

constructor TApplyForm.Create(AOwner:TComponent; Connection:TConnection; DestIP:TIPConfig; IPSetUtil:TIPSetUtil);
begin
    inherited Create(AOwner);
    FDestIP := DestIP;
    FSourceIP := Connection.IPConfig;
    FAdapterName := Connection.AdapterDescription;
    FIPSetUtil := IPSetUtil;

    Initialize;
end;

destructor TApplyForm.Destroy;
begin

    inherited;
end;

procedure TApplyForm.InitEvent;
begin
    bbtnOK.OnClick := bbtnOKClick;
    tmApply.OnTimer := tmApplyTimer;
end;

procedure TApplyForm.Initialize;
begin
    FOldTime := GetTickCount;
    InitEvent;
    UpdateLanguage;
    UpdateControls;
end;

procedure TApplyForm.UpdateControls;
var
    i, nCount:Integer;
    strTmp:string;
begin
    memSource.Clear;
    memDest.Clear;

    strTmp := SysInfo.GetMessage('AutoGetIP');
    if FSourceIP.DHCP then begin
        memSource.Lines.Add(strTmp);
        memSource.Lines.Add(strTmp);
        memSource.Lines.Add(strTmp);
    end
    else begin
        with FSourceIP do begin
            if IPList.Count > 0 then memSource.Lines.Add(IPList.Strings[0])
            else memSource.Lines.Add('');

            if SubMaskList.Count > 0 then memSource.Lines.Add(SubMaskList.Strings[0])
            else memSource.Lines.Add('');

            if GatewayList.Count > 0 then memSource.Lines.Add(GatewayList.Strings[0])
            else memSource.Lines.Add('');
        end;
    end;
    nCount := 3;

    memSource.Lines.AddStrings(FSourceIP.DNSServerList);

    if FDestIP.DHCP then begin
        memDest.Lines.Add(strTmp);
        memDest.Lines.Add(strTmp);
        memDest.Lines.Add(strTmp);
    end
    else begin
        with FDestIP do begin
            if IPList.Count > 0 then memDest.Lines.Add(IPList.Strings[0])
            else memDest.Lines.Add('');

            if SubMaskList.Count > 0 then memDest.Lines.Add(SubMaskList.Strings[0])
            else memDest.Lines.Add('');

            if GatewayList.Count > 0 then memDest.Lines.Add(GatewayList.Strings[0])
            else memDest.Lines.Add('');
        end;
    end;

    memDest.Lines.AddStrings(FDestIP.DNSServerList);

    if FSourceIP.DNSServerList.Count > FDestIP.DNSServerList.Count then
        Inc(nCount, FSourceIP.DNSServerList.Count)
    else Inc(nCount, FDestIP.DNSServerList.Count);

    memArrow.Clear;
    for i := 1 to nCount do
        memArrow.Lines.Add('->');

    // 如果自动应用，则不显示确定按钮
    if SysInfo.AutoApply then begin
        bbtnOK.Visible := False;
        tmApply.Enabled := True;
        EnabledControls(False)
    end
    else begin
        tmApply.Enabled := False;
    end;

    lbAdapterName.Caption := FAdapterName;
    lbStatus.Caption := '';

    // 清空空行
    ClearEmpty
end;

procedure TApplyForm.UpdateLanguage;
var
    i:Integer;
    AComponent:TComponent;
    AFormName:string;
    strComName:string;
    strDefault:string;
begin
    SysInfo.UpdateFormLanguage(Self);
    if SysInfo.LanguageList.Count = 0 then Exit;
    AFormName := Self.Name;

    for i := 0 to Self.ComponentCount - 1 do begin
        AComponent := TComponent(Self.Components[i]);

        if AComponent is TRzBitBtn then begin
            strComName := TRzBitBtn(AComponent).Name + '';
            strDefault := TRzBitBtn(AComponent).Caption;
            TRzBitBtn(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end;
    end;
end;

procedure TApplyForm.bbtnOKClick(Sender:TObject);
begin
    if not Apply then ModalResult := mrNone;
end;

constructor TApplyForm.Create(AOwner:TComponent);
begin
    inherited;
    {FDestIP := DestIP;
    FSourceIP := Connection.IPConfig;
    lbAdapter.Caption := Connection.AdapterDescription;
    FIPSetUtil:= IPSetUtil;}

    Initialize;
end;

procedure TApplyForm.EnabledControls(bEnabled:Boolean);
var
    I:Integer;
begin
    // 禁止窗体
    for i := 0 to Self.ControlCount - 1 do begin
        if not (Self.Controls[I] is TLabeledEdit) then begin
            Self.Controls[i].Enabled := bEnabled;
        end;
    end;
end;

procedure TApplyForm.tmApplyTimer(Sender:TObject);
begin
    if GetTickCount - FOldTime > 800 then begin
        bbtnOKClick(bbtnOK);
        tmApply.Enabled := False;
    end;
end;

procedure TApplyForm.ClearEmpty;
var
    i:Integer;
begin
    with memSource do begin
        for i := Lines.Count - 1 downto 0 do begin
            if Trim(Lines.Strings[i]) = '' then Lines.Delete(i);
        end;
    end;

    with memDest do begin
        for i := Lines.Count - 1 downto 0 do begin
            if Trim(Lines.Strings[i]) = '' then Lines.Delete(i);
        end;
    end;

    with memArrow do begin
        for i := Lines.Count - 1 downto 0 do begin
            if Trim(Lines.Strings[i]) = '' then Lines.Delete(i);
        end;
    end;
end;

end.

