unit frmIPDetail;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, RzButton, RzTabs, RzCommon, ComCtrls, RzListVw, ExtCtrls,
    RzPanel, uIPAssist, RzRadChk, RzEdit, StdCtrls, Mask, RzLabel;

type
    TIPDetailForm = class(TForm)
        pcMain:TRzPageControl;
        tsIP:TRzTabSheet;
        tsDNS:TRzTabSheet;
        tsIE:TRzTabSheet;
        btnOK:TRzButton;
        btnCancel:TRzButton;
        gbIP:TRzGroupBox;
        gbGateway:TRzGroupBox;
        lvIP:TRzListView;
        AddIP:TRzButton;
        ModifyIP:TRzButton;
        DelIP:TRzButton;
        RzFrameController1:TRzFrameController;
        lvGateway:TRzListView;
        AddGateway:TRzButton;
        ModifyGateway:TRzButton;
        DelGateway:TRzButton;
        gbDNS:TRzGroupBox;
        lvDNS:TRzListView;
        AddDNS:TRzButton;
        ModifyDNS:TRzButton;
        DelDNS:TRzButton;
        gbWINS:TRzGroupBox;
        lvWINS:TRzListView;
        AddWINS:TRzButton;
        ModifyWINS:TRzButton;
        DelWINS:TRzButton;
        gbProxy:TRzGroupBox;
        gbDial:TRzGroupBox;
        rbIEDialSet0:TRzRadioButton;
        rbIEDialSet1:TRzRadioButton;
        rbIEDialSet2:TRzRadioButton;
        cbProxyEnabled:TRzCheckBox;
        lbAddress:TRzLabel;
        lbPort:TRzLabel;
        edtProxyServer:TRzEdit;
        edtProxyPort:TRzMaskEdit;
        gbNetBIOS:TRzGroupBox;
        rbNetbios0:TRzRadioButton;
        rbNetbios1:TRzRadioButton;
        rbNetbios2:TRzRadioButton;
        cbIEProxyEnabled:TRzCheckBox;
        cbIEDialEnabled:TRzCheckBox;
        cbNetBIOSEnabled:TRzCheckBox;

    private
        { Private declarations }
        FIPInfor:TIPConfig;
        procedure CommitToObj;
        procedure UpdateControls;
        procedure InitEvent;
        procedure UpdateLanguage;
        function FCheck:Boolean;
        procedure ResetCheckBoxSize(ACheckBox:TRzCheckBox; APixWidth:Integer);

        //////////////////////// Event ////////////////////////////
        procedure lvDNSKeyUp(Sender:TObject; var Key:Word;
            Shift:TShiftState);
        procedure lvWINSKeyUp(Sender:TObject; var Key:Word;
            Shift:TShiftState);
        procedure btnOKClick(Sender:TObject);
        procedure lvIPSelectItem(Sender:TObject; Item:TListItem;
            Selected:Boolean);
        procedure lvDNSDragDrop(Sender, Source:TObject; X, Y:Integer);
        procedure lvDNSDragOver(Sender, Source:TObject; X, Y:Integer;
            State:TDragState; var Accept:Boolean);
        procedure AddIPClick(Sender:TObject);
        procedure ModifyIPClick(Sender:TObject);
        procedure DelIPClick(Sender:TObject);
        procedure lvIPDblClick(Sender:TObject);
        procedure cbIEProxyEnabledClick(Sender:TObject);
        procedure cbProxyEnabledClick(Sender:TObject);
        procedure cbIEDialEnabledClick(Sender:TObject);
        procedure cbNetBIOSEnabledClick(Sender:TObject);
        procedure DisabledControls(AParent:TWinControl; bEnabled:Boolean = False);
        //////////////////////////////////////////////////////////////////////////
    public
        { Public declarations }
        constructor Create(AOwner:TComponent; _IPInfor:TIPConfig); reintroduce;
        destructor Destroy; override;
        procedure Initiliaze;
    end;

var
    IPDetailForm:TIPDetailForm;

implementation
uses
    uUtiles, frmIPInput, uSysInfo;
{$R *.dfm}

{ TIPDetailForm }

constructor TIPDetailForm.Create(AOwner:TComponent; _IPInfor:TIPConfig);
begin
    inherited Create(AOwner);

    FIPInfor := _IPInfor;

    Initiliaze
end;

destructor TIPDetailForm.Destroy;
begin

    inherited;
end;

procedure TIPDetailForm.UpdateControls;
var
    item:TListItem;
    I:Integer;
begin
    // IP地址
    with FIPInfor do begin
        lvIP.Clear;
        if not DHCP then begin
            // IP地址
            for i := 0 to IPList.Count - 1 do begin
                item := lvIP.Items.Add;
                item.Caption := IPList.Strings[i];
                item.SubItems.Add(SubMaskList.Strings[i]);
            end;

            // 默认网关
            lvGateway.Clear;
            for i := 0 to GatewayList.Count - 1 do begin
                item := lvGateway.Items.Add;
                item.Caption := GatewayList.Strings[i];
            end;
        end
        else begin
            DisabledControls(gbGateway);
            DisabledControls(gbIP);
        end;

        // DNS
        lvDNS.Clear;
        for i := 0 to DNSServerList.Count - 1 do begin
            item := lvDNS.Items.Add;
            item.Caption := DNSServerList.Strings[i];
        end;

        // Wins
        lvWINS.Clear;
        for i := 0 to NetBios.NameServerList.Count - 1 do begin
            item := lvWINS.Items.Add;
            item.Caption := NetBios.NameServerList.Strings[i];
        end;

        // IE代理服务器
        cbIEProxyEnabled.Checked := IEProxySet.Enabled;
        if IEProxySet.Enabled then begin
            cbProxyEnabled.Enabled := True;
            cbProxyEnabled.Checked := Boolean(IEProxySet.ProxyEnable);
        end;
        if cbProxyEnabled.Checked then begin
            edtProxyServer.Enabled := True;
            edtProxyPort.Enabled := True;
            edtProxyServer.Text := IEProxySet.ProxyServer;
            edtProxyPort.Text := IntToStr(IEProxySet.ProxyPort);
        end;

        // IE拨号设置
        cbIEDialEnabled.Checked := IEDialSet.Enabled;
        if IEDialSet.Enabled then begin
            rbIEDialSet0.Enabled := True;
            rbIEDialSet1.Enabled := True;
            rbIEDialSet2.Enabled := True;
            case IEDialSet.DialSet of
                0:rbIEDialSet0.Checked := True;
                1:rbIEDialSet1.Checked := True;
                2:rbIEDialSet2.Checked := True;
            end;
        end;

        // NetBios
        cbNetBIOSEnabled.Checked := NetBios.Enabled;
        if NetBios.Enabled then begin
            rbNetbios0.Enabled := True;
            rbNetbios1.Enabled := True;
            rbNetbios2.Enabled := True;
            case NetBios.NetBIOSOptions of
                0:rbNetbios0.Checked := True;
                1:rbNetbios1.Checked := True;
                2:rbNetbios2.Checked := True;
            end;
        end;
    end;
end;

procedure TIPDetailForm.UpdateLanguage;
var
    i:Integer;
    AComponent:TComponent;
    AFormName:string;
    strComName:string;
    strDefault:string;
    nWidth:Integer;
begin
    SysInfo.UpdateFormLanguage(Self);
    if SysInfo.LanguageList.Count = 0 then Exit;
    AFormName := Self.Name;
    nWidth := Self.Canvas.TextWidth('E');
    for i := 0 to Self.ComponentCount - 1 do begin
        AComponent := TComponent(Self.Components[i]);

        if AComponent is TRzRadioButton then begin
            strComName := TRzRadioButton(AComponent).Name + '';
            strDefault := TRzRadioButton(AComponent).Caption;
            TRzRadioButton(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end
        else if AComponent is TRzGroupBox then begin
            strComName := TRzGroupBox(AComponent).Name + '';
            strDefault := TRzGroupBox(AComponent).Caption;
            TRzGroupBox(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end
        else if AComponent is TRzBitBtn then begin
            strComName := TRzBitBtn(AComponent).Name + '';
            strDefault := TRzBitBtn(AComponent).Caption;
            TRzBitBtn(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end
        else if AComponent is TRzButton then begin
            strComName := TRzButton(AComponent).Name + '';
            strDefault := TRzButton(AComponent).Caption;
            TRzButton(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end
        else if AComponent is TRzCheckBox then begin
            strComName := TRzCheckBox(AComponent).Name + '';
            if AComponent is TCustomCheckBox then begin
                strDefault := '';
            end;
            strDefault := TRzCheckBox(AComponent).Caption;
            TRzCheckBox(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
            ResetCheckBoxSize(TRzCheckBox(AComponent), nWidth);
        end
        else if AComponent is TRzTabSheet then begin
            strComName := TRzTabSheet(AComponent).Name + '';
            strDefault := TRzTabSheet(AComponent).Caption;
            TRzTabSheet(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end;
    end;
end;

procedure TIPDetailForm.lvDNSKeyUp(Sender:TObject; var Key:Word;
    Shift:TShiftState);
begin
    // 调整顺序
    case Key of
        VK_UP:if ssCtrl in Shift then MoveListViewSelection(TListView(Sender), 2);
        VK_DOWN:if ssCtrl in Shift then MoveListViewSelection(TListView(Sender), 3);
    end;
end;

procedure TIPDetailForm.lvWINSKeyUp(Sender:TObject; var Key:Word;
    Shift:TShiftState);
begin
    // 调整顺序
    case Key of
        VK_UP:if ssCtrl in Shift then MoveListViewSelection(TListView(Sender), 2);
        VK_DOWN:if ssCtrl in Shift then MoveListViewSelection(TListView(Sender), 3);
    end;
end;

procedure TIPDetailForm.btnOKClick(Sender:TObject);
begin
    if FCheck then begin
        CommitToObj;
        ModalResult := mrOk;
    end
    else begin
        ModalResult := mrNone;
        Abort;
    end;
end;

procedure TIPDetailForm.CommitToObj;
var
    item:TListItem;
    I:Integer;
begin
    // IP地址
    with FIPInfor do begin
        IPList.Clear;
        SubMaskList.Clear;
        for i := 0 to lvIP.Items.Count - 1 do begin
            item := lvIP.Items.Item[i];
            IPList.Add(item.Caption);
            SubMaskList.Add(item.SubItems.Strings[0]);
        end;

        // 默认网关
        GatewayList.Clear;
        for i := 0 to lvGateway.Items.Count - 1 do begin
            item := lvGateway.Items.Item[i];
            GatewayList.Add(item.Caption);
        end;

        // DNS
        DNSServerList.Clear;
        for i := 0 to lvDNS.Items.Count - 1 do begin
            item := lvDNS.Items.Item[i];
            DNSServerList.Add(item.Caption);
        end;

        // Wins
        NetBios.NameServerList.Clear;
        for i := 0 to lvWINS.Items.Count - 1 do begin
            item := lvWINS.Items.Item[i];
            NetBios.NameServerList.Add(item.Caption);
        end;

        IEProxySet.Enabled := cbIEProxyEnabled.Checked;
        if IEProxySet.Enabled then begin
            IEProxySet.ProxyEnable := Integer(cbProxyEnabled.Checked);
        end;
        if cbProxyEnabled.Checked then begin
            IEProxySet.ProxyServer := edtProxyServer.Text;
            IEProxySet.ProxyPort := StrToInt(edtProxyPort.Text);
        end;

        // 拨号设置
        IEDialSet.Enabled := cbIEDialEnabled.Checked;
        if rbIEDialSet0.Checked then IEDialSet.DialSet := 0
        else if rbIEDialSet1.Checked then IEDialSet.DialSet := 1
        else if rbIEDialSet2.Checked then IEDialSet.DialSet := 2;

        // NetBios
        NetBios.Enabled := cbNetBIOSEnabled.Checked;
        if rbNetbios0.Checked then NetBios.NetBIOSOptions := 0
        else if rbNetbios1.Checked then NetBios.NetBIOSOptions := 1
        else if rbNetbios2.Checked then NetBios.NetBIOSOptions := 2;
    end;
end;

procedure TIPDetailForm.lvIPSelectItem(Sender:TObject; Item:TListItem; Selected:Boolean);
var
    bSel:Boolean;
    BtnName:string;
    Btn:TRzButton;
begin
    // 判断是否需要显示修改和删除
    bSel := (TListView(Sender).SelCount <> 0);
    bSel := bSel and Assigned(Item);
    // 为了统一，所以根据名字取另外一个控件
    BtnName := StringReplace(TListView(Sender).Name, 'lv', 'Modify', []);
    Btn := TRzButton(FindComponent(BtnName));
    Btn.Enabled := bSel;
    BtnName := StringReplace(TListView(Sender).Name, 'lv', 'Del', []);
    Btn := TRzButton(FindComponent(BtnName));
    Btn.Enabled := bSel;
end;

procedure TIPDetailForm.lvDNSDragDrop(Sender, Source:TObject; X,
    Y:Integer);
var
    TargetItem, SourceItem, TempItem:TListItem;
begin
    TargetItem := TListView(Sender).GetItemAt(X, Y);
    if TargetItem <> nil then begin
        TempItem := TListItem.Create(TListView(Sender).Items);

        SourceItem := TListView(Sender).Selected;
        TempItem.Assign(SourceItem);
        SourceItem.Assign(TargetItem);
        TargetItem.Assign(TempItem);
        TargetItem.Selected := True;

        FreeAndNil(TempItem);
    end;
end;

procedure TIPDetailForm.lvDNSDragOver(Sender, Source:TObject; X,
    Y:Integer; State:TDragState; var Accept:Boolean);
var
    TargetItem, SourceItem:TListItem;
begin
    TargetItem := TListView(Sender).GetItemAt(X, Y);
    if (Source = Sender) and (TargetItem <> nil) then begin
        Accept := True;

        SourceItem := TListView(Sender).Selected;
        if SourceItem = TargetItem then
            Accept := False;
    end
    else
        Accept := False;
end;

procedure TIPDetailForm.AddIPClick(Sender:TObject);
var
    lvName:string;
    lv:TListView;
    bHaveMask:Boolean;
begin
    // 增加
    // 为了统一，所以根据名字取另外一个控件
    lvName := StringReplace(TRzButton(Sender).Name, 'Add', 'lv', []);
    lv := TListView(FindComponent(lvName));
    bHaveMask := AnsiSameText('lvIP', lvName);
    with TIPInputForm.Create(Self) do begin
        Initialize('', '', bHaveMask);
        if ShowModal = IDOK then begin
            with lv.Items.Add do begin
                Caption := edtIP.Text;
                if bHaveMask then
                    SubItems.Add(edtMask.Text);
            end;
        end;
        Free;
    end;
end;

procedure TIPDetailForm.ModifyIPClick(Sender:TObject);
var
    lvName:string;
    lv:TListView;
    strMask:string;
    bHaveMask:Boolean;
begin
    // 修改
    // 为了统一，所以根据名字取另外一个控件
    lvName := StringReplace(TRzButton(Sender).Name, 'Modify', 'lv', []);
    lv := TListView(FindComponent(lvName));
    bHaveMask := AnsiSameText('lvIP', lvName);
    if bHaveMask then strMask := lv.Selected.SubItems.Strings[0]
    else strMask := '';

    with TIPInputForm.Create(Self) do begin
        Initialize(lv.Selected.Caption, strMask, bHaveMask);
        if ShowModal = IDOK then begin
            with lv.Selected do begin
                Caption := edtIP.Text;
                if bHaveMask then
                    SubItems.Strings[0] := (edtMask.Text);
            end;
        end;
        Free;
    end;
end;

procedure TIPDetailForm.DelIPClick(Sender:TObject);
var
    lvName:string;
    lv:TListView;
begin
    // 删除
    // 为了统一，所以根据名字取另外一个控件
    if SysInfo.ShowMLMessage('ConfirmDelete', '', msOKCancel) <> IDOK then Exit;
    lvName := StringReplace(TRzButton(Sender).Name, 'Del', 'lv', []);
    lv := TListView(FindComponent(lvName));
    lv.DeleteSelected;
end;

procedure TIPDetailForm.lvIPDblClick(Sender:TObject);
var
    lv:TListView;
    lvName:string;
    strMask:string;
    bHaveMask:Boolean;
begin
    // 修改
    // 为了统一，所以根据名字取另外一个控件
    lv := TListView(Sender);
    if not Assigned(lv.Selected) then Exit;
    lvName := lv.Name;
    bHaveMask := AnsiSameText('lvIP', lvName);
    if bHaveMask then strMask := lv.Selected.SubItems.Strings[0]
    else strMask := '';

    with TIPInputForm.Create(Self) do begin
        Initialize(lv.Selected.Caption, strMask, bHaveMask);
        if ShowModal = IDOK then begin
            with lv.Selected do begin
                Caption := edtIP.Text;
                if bHaveMask then
                    SubItems.Strings[0] := (edtMask.Text);
            end;
        end;
        Free;
    end;
end;

procedure TIPDetailForm.InitEvent;
begin
    with lvIP do begin
        OnDblClick := lvIPDblClick;
        OnSelectItem := lvIPSelectItem;
    end;
    AddIP.OnClick := AddIPClick;
    ModifyIP.OnClick := ModifyIPClick;
    DelIP.OnClick := DelIPClick;
    with lvGateway do begin
        OnDblClick := lvIPDblClick;
        OnSelectItem := lvIPSelectItem;
    end;
    AddGateway.OnClick := AddIPClick;
    ModifyGateway.OnClick := ModifyIPClick;
    DelGateway.OnClick := DelIPClick;
    with lvDNS do begin
        OnDblClick := lvIPDblClick;
        OnDragDrop := lvDNSDragDrop;
        OnDragOver := lvDNSDragOver;
        OnSelectItem := lvIPSelectItem;
        OnKeyUp := lvDNSKeyUp;
    end;
    AddDNS.OnClick := AddIPClick;
    ModifyDNS.OnClick := ModifyIPClick;
    DelDNS.OnClick := DelIPClick;
    with lvWINS do begin
        OnDblClick := lvIPDblClick;
        OnDragDrop := lvDNSDragDrop;
        OnDragOver := lvDNSDragOver;
        OnSelectItem := lvIPSelectItem;
        OnKeyUp := lvWINSKeyUp;
    end;
    AddWINS.OnClick := AddIPClick;
    ModifyWINS.OnClick := ModifyIPClick;
    DelWINS.OnClick := DelIPClick;
    btnOK.OnClick := btnOKClick;
    cbIEProxyEnabled.OnClick := cbIEProxyEnabledClick;
    cbProxyEnabled.OnClick := cbProxyEnabledClick;
    cbIEDialEnabled.OnClick := cbIEDialEnabledClick;
    cbNetBIOSEnabled.OnClick := cbNetBIOSEnabledClick;
end;

procedure TIPDetailForm.cbIEProxyEnabledClick(Sender:TObject);
begin
    cbProxyEnabled.Enabled := cbIEProxyEnabled.Checked;
    if not cbIEProxyEnabled.Checked then
        cbProxyEnabled.Checked := False;
    edtProxyServer.Enabled := cbProxyEnabled.Checked;
    edtProxyPort.Enabled := cbProxyEnabled.Checked;
end;

procedure TIPDetailForm.cbProxyEnabledClick(Sender:TObject);
begin
    edtProxyServer.Enabled := cbProxyEnabled.Checked;
    edtProxyPort.Enabled := cbProxyEnabled.Checked;
end;

procedure TIPDetailForm.cbIEDialEnabledClick(Sender:TObject);
var
    bEnabled:Boolean;
begin
    bEnabled := cbIEDialEnabled.Checked;
    rbIEDialSet0.Enabled := bEnabled;
    rbIEDialSet1.Enabled := bEnabled;
    rbIEDialSet2.Enabled := bEnabled;
end;

procedure TIPDetailForm.cbNetBIOSEnabledClick(Sender:TObject);
var
    bEnabled:Boolean;
begin
    bEnabled := cbNetBIOSEnabled.Checked;
    rbNetbios0.Enabled := bEnabled;
    rbNetbios1.Enabled := bEnabled;
    rbNetbios2.Enabled := bEnabled;
end;

procedure TIPDetailForm.DisabledControls(AParent:TWinControl; bEnabled:Boolean);
var
    i:Integer;
begin
    // 控制Control
    AParent.Enabled := bEnabled;
    for i := 0 to AParent.ControlCount - 1 do
        AParent.Controls[i].Enabled := bEnabled;
end;

function TIPDetailForm.FCheck:Boolean;
begin
    Result := False;
    if lvIP.Enabled then begin
        if lvIP.Items.Count = 0 then begin
            SysInfo.ShowMLMessage('OneMoreIP');
            AddIP.SetFocus;
            Exit;
        end;

        if lvGateway.Items.Count = 0 then begin
            SysInfo.ShowMLMessage('OneMoreGate');
            AddGateway.SetFocus;
            Exit;
        end;
        {case InSameSegment(edtIP.Text, edtGateway.Text) of
            -1:begin
                    Application.MessageBox('网关和IP相同，请检查', '提示', MB_OK + MB_ICONWARNING);
                    edtGateway.SetFocus;
                    Exit;
                end;
            1:begin
                    Application.MessageBox('网关和IP不在同一网段，请检查', '提示', MB_OK + MB_ICONWARNING);
                    edtGateway.SetFocus;
                    Exit;
                end;
        end;}
    end;

    if cbProxyEnabled.Checked then begin
        if Trim(edtProxyServer.Text) = '' then begin
            SysInfo.ShowMLMessage('MustProxyAdd');
            edtProxyServer.SetFocus;
            Exit;
        end;

        if Trim(edtProxyPort.Text) = '' then begin
            SysInfo.ShowMLMessage('MustProxyPort');
            edtProxyPort.SetFocus;
            Exit;
        end;
    end;

    if cbIEProxyEnabled.Checked then begin
        if not (rbIEDialSet0.Checked or rbIEDialSet1.Checked or rbIEDialSet2.Checked) then begin
            SysInfo.ShowMLMessage('OneMoreDialSet');
            rbIEDialSet0.SetFocus;
            Exit;
        end;
    end;

    if cbNetBIOSEnabled.Checked then begin
        if not (rbNetbios0.Checked or rbNetbios1.Checked or rbNetbios2.Checked) then begin
            SysInfo.ShowMLMessage('OneMoreNetBios');
            rbNetbios0.SetFocus;
            Exit;
        end;
    end;
    Result := True;
end;

procedure TIPDetailForm.Initiliaze;
begin
    pcMain.ActivePageIndex := 0;
    FlatListViewHeader(lvIP);
    FlatListViewHeader(lvGateway);
    FlatListViewHeader(lvWINS);
    FlatListViewHeader(lvDNS);

    InitEvent;
    UpdateLanguage;
    UpdateControls;
end;

procedure TIPDetailForm.ResetCheckBoxSize(ACheckBox:TRzCheckBox; APixWidth:Integer);
begin
    // 重新设置大小，主要针对语言
    if not Assigned(ACheckBox) then Exit;
    ACheckBox.Width := APixWidth * (Length(ACheckBox.Caption) + 4);
end;

end.

