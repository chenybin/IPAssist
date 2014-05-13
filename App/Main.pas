unit Main;

interface

{
    �Զ�ˢ������

    ���   mac�ͻ������޸�  ,    ����������ʾ���  ������ϸ��Ϣ�ķ���  sendarp

    hookע�����Ӻ���
    �Զ�������Ч�Ƚ���   �Զ������ö��̣߳������Զ���Ӧʱ��ˢ

    ��������dll��ʽ��ʹ��getacp��ʽ�Զ�ƥ��
    �������
    �Զ����������Ĭ�����أ��������񲻺ϳ���
    ����ͼ�꣬ҪСͼ��
    ip��������⣬������Ҫ������������û��Զ���
    ����ѡ���Ƿ�hint
    ����ѡ���Ƿ�ֱ��apply������ʾ�߼�
    ע������
    �滮����
}

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, Mask, RzEdit, ComCtrls, ImgList, RzStatus, ExtCtrls,
    RzPanel, RzListVw, Registry, RzButton, RzRadChk, RzLabel, RzCommon,
    RzRadGrp, uIPAssist, jpeg, RzCmboBx, Menus, ActnList,
    RzGroupBar, ToolWin, uTrayIcon, Buttons, System.Actions; //, uPingThread;

type
    TMainForm = class(TForm)
        sbMain:TRzStatusBar;
        RzClockStatus1:TRzClockStatus;
        spLicensed:TRzStatusPane;
        gbIPConfig:TRzGroupBox;
        lvIPHistory:TRzListView;
        RzFrameController1:TRzFrameController;
        ilDevice:TImageList;
        gbDetail:TRzGroupBox;
        gbIPDetail:TRzGroupBox;
        lbIP:TRzLabel;
        lbMask:TRzLabel;
        lbGateway:TRzLabel;
        edtIP:TRzEdit;
        edtGateway:TRzEdit;
        edtMask:TRzEdit;
        gbDNSDetail:TRzGroupBox;
        lbPrimaryDNS:TRzLabel;
        lbSecondaryDNS:TRzLabel;
        edtPrimaryDNS:TRzEdit;
        edtSecondaryDNS:TRzEdit;
        rgIpSet:TRzRadioGroup;
        rgDNSSet:TRzRadioGroup;
        ilBig:TImageList;
        ilToolbar:TImageList;
        lbAdapter:TRzLabel;
        edtConfigName:TRzEdit;
        lbConfigName:TRzLabel;
        lbIPExist:TRzLabel;
        alMain:TActionList;
        atNewConfig:TAction;
        atSaveConfig:TAction;
        atDelConfig:TAction;
        atApply:TAction;
        atAdvance:TAction;
        atAbout:TAction;
        atRefresh:TAction;
        atOption:TAction;
        MainMenu:TMainMenu;
        atStopAdapter:TAction;
        atStartAdapter:TAction;
        mmFile:TMenuItem;
        mmHelp:TMenuItem;
        B1:TMenuItem;
        atExit:TAction;
        sbRefresh:TSpeedButton;
        pmLVIPHis:TPopupMenu;
        N1:TMenuItem;
        S1:TMenuItem;
        D1:TMenuItem;
        N2:TMenuItem;
        E1:TMenuItem;
        A2:TMenuItem;
        cbAdapterList:TRzComboBox;
        atIcon:TAction;
        atSmallIcon:TAction;
        atReport:TAction;
        mmView:TMenuItem;
        N4:TMenuItem;
        N5:TMenuItem;
        N6:TMenuItem;
        X1:TMenuItem;
        mmEdit:TMenuItem;
        N7:TMenuItem;
        S2:TMenuItem;
        D2:TMenuItem;
        N8:TMenuItem;
        A3:TMenuItem;
        A4:TMenuItem;
        mmSetup:TMenuItem;
        O1:TMenuItem;
        sbMovePrev:TSpeedButton;
        sbMoveNext:TSpeedButton;
        ilSmall:TImageList;
        N10:TMenuItem;
        N11:TMenuItem;
        N12:TMenuItem;
        N13:TMenuItem;
        atMovePrev:TAction;
        atMoveNext:TAction;
        tbrMain:TRzToolbar;
        btnFrames:TRzToolButton;
        btnComboBoxes:TRzToolButton;
        btnListBoxes:TRzToolButton;
        btnCommon:TRzToolButton;
        btnEdits:TRzToolButton;
        btnTabs:TRzToolButton;
        btnWelcome:TRzToolButton;
        imgPrimaryDNS:TImage;
        imgSecondaryDNS:TImage;
        imgGateWay:TImage;
        pmMain:TPopupMenu;
        B2:TMenuItem;
        X2:TMenuItem;
        atRestore:TAction;
        R1:TMenuItem;
        atShortCut:TAction;
        N14:TMenuItem;
        K1:TMenuItem;
        atReg:TAction;
        N15:TMenuItem;
        sbStopAdapter:TSpeedButton;
        sbStartAdapter:TSpeedButton;
        atPing:TAction;
        N3:TMenuItem;
        N9:TMenuItem;
        atSaveAsConfig:TAction;
        N16:TMenuItem;
        N17:TMenuItem;
    private
        { Private declarations }
        IPSetUtil:TIPSetUtil; // IP���ù�����
        TrayIcon:TTrayIcon;
        //..PingThread:TPingThread;
        FControlList:TList;
        FFinished:Boolean; // �Ƿ��Ѿ����
        OldSelItem:TListItem; // ��ѡ������жϵ�ǰ�Ƿ������л�
        FBitmap:TBitmap; // ��ʱλͼ����

        bAllSaved:Boolean; // ȫ�ֱ����־
        bSaved:Boolean; // ������־
        bSetEdit:Boolean; // ��ʾ�Ƿ�ֵ��ɣ�Ϊ�˱����жϱ༭���״̬

        // ������б༭��
        procedure ClearEdit(AParent:TWinControl);
        // �༭�����ݸı�ʱ�޸ĵ�����
        procedure ChangeEvent(Sender:TObject);
        // �����
        function FCheck(ACheckConfigName:Boolean = True):Boolean;

        // ��ʾ��ϸ��Ϣ
        procedure ShowDetail(_IPConfig:TIPConfig; bShowConfigName:Boolean = True);
        // ���浥����Ϣ
        procedure SaveDetail(var _IPConfig:TIPConfig);
        // ����ȫ����Ϣ
        procedure SaveToFile;
        procedure ApplyByParam();
        procedure ApplyDefault();

        // ����Ping���
        procedure OnProcessPing(AControlName:string; nResult:Integer; bFinished:Boolean = False);
        procedure PingGateDNS(Sender:TObject);

        // ����ͼƬ��ÿ���л�ʱ��Ҫ������
        procedure HideImage;

        // ������ʱλͼ����Ping�õ�
        procedure CreateBMP;

        // ����ʹ��ListView���¼�
        procedure EnabledListViewEvent(bEanbled:Boolean);

        // Tray�˵����¼�
        procedure InitTrayMenu(PM:TPopupMenu);
        // Tray���
        procedure ClearTrayMenu(PM:TPopupMenu);
        procedure ApplySelected(Sender:TObject);
        // ��ʼ���¼�
        procedure InitEvent;
        // ��ʾע����Ϣ
        procedure ShowLicensedInfo;
        // ��ʾģʽ
        procedure DefaultStyle();

        // ��Tray�ӻָ��ȵ��¼�
        procedure OnTrayRestore(Sender:TObject);
        procedure OnTrayDbClick(Sender:TObject);

        // ��������
        procedure UpdateLanguage;
        // ��������GroupBox��С����������
        procedure ResetRadioGroupSize(ARadioGroup:TRzRadioGroup; APixWidth:Integer);

        ////////////////////////  Event //////////////////////
        procedure rgIpSetClick(Sender:TObject);
        procedure rgDNSSetClick(Sender:TObject);
        procedure atSaveConfigExecute(Sender:TObject);
        procedure atDelConfigExecute(Sender:TObject);
        procedure atAboutExecute(Sender:TObject);
        procedure atExitExecute(Sender:TObject);
        procedure atOptionExecute(Sender:TObject);
        procedure atApplyExecute(Sender:TObject);
        procedure atAdvanceExecute(Sender:TObject);
        procedure FormCloseQuery(Sender:TObject; var CanClose:Boolean);
        procedure atNewConfigExecute(Sender:TObject);
        procedure edtIPChange(Sender:TObject);
        procedure atStartAdapterExecute(Sender:TObject);
        procedure atStopAdapterExecute(Sender:TObject);
        procedure atRefreshExecute(Sender:TObject);
        procedure cbAdapterListDrawItem(Control:TWinControl; Index:Integer;
            Rect:TRect; State:TOwnerDrawState);
        procedure atIconExecute(Sender:TObject);
        procedure atSmallIconExecute(Sender:TObject);
        procedure atReportExecute(Sender:TObject);
        procedure atMovePrevExecute(Sender:TObject);
        procedure atMoveNextExecute(Sender:TObject);
        procedure edtGatewayChange(Sender:TObject);
        procedure cbAdapterListChange(Sender:TObject);
        procedure atRestoreExecute(Sender:TObject);
        procedure atShortCutExecute(Sender:TObject);
        procedure atRegExecute(Sender:TObject);
        procedure atPingExecute(Sender:TObject);
        procedure atSaveAsConfigExecute(Sender:TObject);

        procedure lvIPHistoryClick(Sender:TObject);
        procedure lvIPHistorySelectItem(Sender:TObject; Item:TListItem;
            Selected:Boolean);
        procedure lvIPHistoryKeyUp(Sender:TObject; var Key:Word;
            Shift:TShiftState);
        procedure lvIPHistoryMouseMove(Sender:TObject; Shift:TShiftState; X,
            Y:Integer);
        procedure lvIPHistoryDblClick(Sender:TObject);
        procedure lvIPHistoryDragDrop(Sender, Source:TObject; X, Y:Integer);
        procedure lvIPHistoryDragOver(Sender, Source:TObject; X, Y:Integer;
            State:TDragState; var Accept:Boolean);
        //////////////////////////////////////////////////////
    public
        constructor Create(AOwner:TComponent); override;
        destructor Destroy; override;
        procedure Initiliaze;
    published

    end;

var
    MainForm:TMainForm;

implementation
uses
    uUtiles, uIPHintWindow, frmOption, frmIPDetail, frmAbout, uICMPUtil, uMutilLanguage,
    frmApply, uSysInfo, DateUtils, frmAutoSearch, frmRegistry, frmSaveAs;
{$R *.dfm}

procedure TMainForm.rgIpSetClick(Sender:TObject);
var
    bManual:Boolean;
begin
    bManual := (rgIpSet.ItemIndex = 1);
    gbIPDetail.Enabled := bManual; // IP������Ϣ������
    TRzRadioButton(rgDNSSet.Components[0]).Enabled := (not bManual); // dns�����Զ�
    rgDNSSet.ItemIndex := 1;
    ChangeEvent(Sender);
    // ����������治����Ͳ�Ҫ�����
    if not bManual and SysInfo.AutoClearDHCPIP then ClearEdit(gbIPDetail);
end;

procedure TMainForm.rgDNSSetClick(Sender:TObject);
var
    bManual:Boolean;
begin
    bManual := (rgDNSSet.ItemIndex = 1);
    gbDNSDetail.Enabled := bManual; // DNS������Ϣ������
    ChangeEvent(Sender);
    if not bManual and SysInfo.AutoClearDHCPIP then ClearEdit(gbDNSDetail);
end;

procedure TMainForm.ClearEdit(AParent:TWinControl);
var
    i:Integer;
    Control:TControl;
begin
    // ��ձ༭������
    for i := 0 to AParent.ControlCount - 1 do begin
        Control := AParent.Controls[i];
        if Control is TCustomEdit then begin
            TCustomEdit(Control).Text := '';
        end;
    end;
end;

constructor TMainForm.Create(AOwner:TComponent);
begin
    inherited;
    IPSetUtil := TIPSetUtil.Create;
    TrayIcon := TTrayIcon.Create(Self);
    FControlList := TList.Create;
    Initiliaze;
    {//..
    PingThread := TPingThread.Create(IPSetUtil.ICMPUtil);
    // �¼�
    PingThread.OnProcess := OnProcessPing;
    // �ؼ�
    try
        with PingThread.ControlList.LockList do begin
            Add(edtGateway);
            Add(edtPrimaryDNS);
            Add(edtSecondaryDNS);
        end;
    finally
        PingThread.ControlList.UnlockList;
    end; }
end;

destructor TMainForm.Destroy;
begin
    {PingThread.Terminate;
    SetEvent(PingThread.PingEvent);
    TerminateThread(PingThread.Handle, 0);
    PingThread.Free;}
    FControlList.Clear;
    FControlList.Free;
    TrayIcon.ShowBalloonTip := False;
    TrayIcon.Free;
    IPSetUtil.Free;
    FBitmap.Free;
    inherited;
end;

procedure TMainForm.atSaveConfigExecute(Sender:TObject);
var
    IP:TIPConfig;
    nPos:Integer;
    Item:TListItem;
    strMsg:string;
begin
    // ������޸�������
    if not FCheck then Exit;
    Item := lvIPHistory.Selected;
    if Assigned(Item) then IP := TIPConfig(Item.data);

    if Assigned(Item) and Assigned(IP) then begin

        nPos := IPSetUtil.IPConfigExist(edtConfigName.Text);
        if (nPos <> -1) and (nPos <> Item.Index) then begin
            strMsg := SysInfo.GetMessage('ExistConfig', '%s');
            strMsg := Format(strMsg, [Item.Caption]);
            SysInfo.ShowMLMessage(strMsg);
            edtConfigName.SetFocus;
            Exit;
        end;

        SaveDetail(ip);

        bSaved := True;
        Item.Caption := IP.ConfigName;
        IPSetUtil.SaveAllConfigs(TListView(lvIPHistory));
        if IP.IPList.Count > 0 then
            Item.SubItems.Add(IP.IPList.Strings[0])
        else Item.SubItems.Add('');

        if IP.SubMaskList.Count > 0 then
            Item.SubItems.Add(IP.SubMaskList.Strings[0])
        else Item.SubItems.Add('');

        if IP.GatewayList.Count > 0 then
            Item.SubItems.Add(IP.GatewayList.Strings[0])
        else Item.SubItems.Add('');

        // ����Զ������
        if rgDNSSet.ItemIndex = 0 then ip.DNSServerList.Clear
        else begin
            if IP.DNSServerList.Count > 0 then
                Item.SubItems.Add(IP.DNSServerList.Strings[0])
            else Item.SubItems.Add('');

            if IP.DNSServerList.Count > 1 then
                Item.SubItems.Add(IP.DNSServerList.Strings[1])
            else Item.SubItems.Add('');
        end;

        Item.Data := IP;
    end;
    TAction(Sender).Enabled := False;
    atNewConfig.Enabled := True;
    EnabledListViewEvent(True);
    atDelConfig.Enabled := True;
    atApply.Enabled := True;
    atSaveAsConfig.Enabled := True;
    atPing.Enabled := True;
    InitTrayMenu(pmMain);
end;

procedure TMainForm.lvIPHistoryKeyUp(Sender:TObject; var Key:Word;
    Shift:TShiftState);
begin
    // ����˳��
    case Key of
        VK_UP:if ssCtrl in Shift then begin
                MoveListViewSelection(TListView(lvIPHistory), 2);
                bAllSaved := False;
                // �������ݵ�������
                IPSetUtil.SaveAllConfigs(TListView(lvIPHistory));
            end;
        VK_DOWN:if ssCtrl in Shift then begin
                MoveListViewSelection(TListView(lvIPHistory), 3);
                bAllSaved := False;
                IPSetUtil.SaveAllConfigs(TListView(lvIPHistory));
            end;
    end;
end;

procedure TMainForm.lvIPHistoryMouseMove(Sender:TObject;
    Shift:TShiftState; X, Y:Integer);
{$J+}
const
    OldItem:TListItem = nil;
    {$J-}
var
    AnItem:TListItem;

    function BuildHint(_IPConfig:TIPConfig):string;
    var
        i:Integer;
    begin
        if not Assigned(_IPConfig) then Exit;
        with _IPConfig do begin
            Result := '';
            if DHCP then Result := Result + '     IP:  ' + SysInfo.GetMessage('AutoGetIP') + #13#10
            else begin
                if IPList.Count > 0 then
                    Result := Result + '     IP:  ' + IPList.Strings[0] + #13#10;
                if SubMaskList.Count > 0 then
                    Result := Result + 'SubMask:  ' + SubMaskList.Strings[0] + #13#10;
                if GatewayList.Count > 0 then
                    // װ��һ��vpn�Ŀͻ��ˣ�������������û�У�����ip����û��
                    // ��Ӧ��Ĭ�����أ����Լ�������ж�

                    Result := Result + 'GateWay:  ' + GatewayList.Strings[0] + #13#10;
            end;
            for i := 0 to DNSServerList.Count - 1 do begin
                Result := Result + '   DNS' + IntToStr(i + 1) + ':  ' + DNSServerList.Strings[i] + #13#10;
            end;
        end;
    end;

begin
    AnItem := TListView(Sender).GetItemAt(X, Y);
    if Assigned(AnItem) and (AnItem <> OldItem) then begin
        TListView(Sender).Hint := BuildHint(TIPConfig(AnItem.Data));
        Application.ActivateHint(Mouse.CursorPos);
        OldItem := AnItem;
    end;
end;

procedure TMainForm.lvIPHistoryDblClick(Sender:TObject);
begin
    atAdvanceExecute(Sender);
end;

procedure TMainForm.atDelConfigExecute(Sender:TObject);
var
    item:TListItem;
    newItem:TListItem;
    i:Integer;
    nIndex:Integer;
    strTmp:string;
begin
    if not Assigned(lvIPHistory.Selected) then Exit;
    item := lvIPHistory.Selected;
    strTmp := SysInfo.GetMessage('ConfirmDelConfig', '%s');
    strTmp := Format(strTmp, [Item.Caption]);
    if SysInfo.ShowMLMessage(strTmp, '', msOKCancel) <> IDOK then Exit;
    nIndex := item.Index;
    IPSetUtil.DelIPConfig(nIndex);
    //.. ɾ��Ч�����ã��м��ճ��ܴ��ط�
    // �����Ȱ����ƶ������Ȼ��ɾ��
    for i := nIndex + 1 to lvIPHistory.Items.Count - 1 do begin
        newItem := lvIPHistory.Items.Item[i];
        newItem.Selected := True;
        MoveListViewSelection(TListView(lvIPHistory), 2);
    end;
    lvIPHistory.Items.Delete(lvIPHistory.Items.Count - 1);
    bAllSaved := False;
    InitTrayMenu(pmMain);
end;

procedure TMainForm.ShowDetail(_IPConfig:TIPConfig; bShowConfigName:Boolean);
begin
    if not Assigned(_IPConfig) then Exit;
    with _IPConfig do begin
        if bShowConfigName then begin
            edtConfigName.Text := ConfigName;
            cbAdapterList.ItemIndex := IPSetUtil.GetAdapterIndex(AdapterName);
            if cbAdapterList.ItemIndex = -1 then begin
                SysInfo.ShowMLMessage('NotExistNetCard');
            end;
        end;
        if DHCP then begin
            rgIpSet.ItemIndex := 0;
        end
        else begin
            rgIpSet.ItemIndex := 1;
            // ģ������ʹѡ������Ч
            SendMessage(rgIpSet.Handle, WM_LBUTTONDOWN, 0, 0);
            SendMessage(rgIpSet.Handle, WM_LBUTTONUP, 0, 0);
        end;
        if DNSServerList.Count = 0 then rgDNSSet.ItemIndex := 0
        else begin
            rgDNSSet.ItemIndex := 1;
        end;

        if (IPList.Count > 0) then edtIP.Text := IPList.Strings[0]
        else edtIP.Text := '';
        if (GatewayList.Count > 0) then edtGateway.Text := GatewayList.Strings[0]
        else edtGateway.Text := '';
        if (SubMaskList.Count > 0) then edtMask.Text := SubMaskList.Strings[0]
        else edtMask.Text := '';
        if (DNSServerList.Count > 0) then edtPrimaryDNS.Text := DNSServerList.Strings[0]
        else edtPrimaryDNS.Text := '';
        if (DNSServerList.Count > 1) then edtSecondaryDNS.Text := DNSServerList.Strings[1]
        else edtSecondaryDNS.Text := '';
    end;
end;

procedure TMainForm.lvIPHistoryClick(Sender:TObject);
var
    item:TListItem;
begin
    // �ж��Ƿ���Ҫ���棬�л���
    if not Assigned(lvIPHistory.Selected) then Exit;
    item := lvIPHistory.Selected;
    if oldSelItem = nil then OldSelItem := Item;

    // ���ϵͳ��Ҫ���ж�
    if SysInfo.ConfirmChange and (not bSaved) and (item <> oldSelItem) then begin
        if SysInfo.ShowMLMessage('ConfigChanged', '', msOKCancel) <> IDOK then begin
            Item.Selected := False;
            oldSelItem.Selected := True;
            Exit;
        end;
    end;
    EnabledListViewEvent(True);
    atNewConfig.Enabled := True;
    atApply.Enabled := True;
    atPing.Enabled := True;
    atDelConfig.Enabled := True;
    atSaveConfig.Enabled := False;
    atSaveAsConfig.Enabled := True;
    if bSaved then OldSelItem := Item;

    // ��ʾ��ϸ
    if not Assigned(lvIPHistory.Selected) then Exit;
    item := lvIPHistory.Selected;
    bSetEdit := False;
    ShowDetail(TIPConfig(Item.Data));
    bSetEdit := True;
end;

procedure TMainForm.atAboutExecute(Sender:TObject);
begin
    // ����
    with TAboutForm.Create(self) do begin
        ShowModal;
        Free;
    end;
end;

procedure TMainForm.atExitExecute(Sender:TObject);
begin
    Close;
end;

procedure TMainForm.atOptionExecute(Sender:TObject);
    function GetConfigList:string;
    var
        i:Integer;
    begin
        for i := 0 to lvIPHistory.Items.Count - 1 do
            Result := Result + lvIPHistory.Items.Item[i].Caption + #13#10;
    end;
begin
    // ѡ��
    with TOptionForm.Create(self, cbAdapterList.Items, GetConfigList) do begin
        if ShowModal = IDOK then begin
            if LanguageChanged then UpdateLanguage;
            DefaultStyle;
            InitTrayMenu(pmMain);
        end;
        Free;
    end;
end;

procedure TMainForm.atMovePrevExecute(Sender:TObject);
begin
    // ���ƶ�
    MoveListViewSelection(TListView(lvIPHistory), 2);
    bAllSaved := False;
end;

procedure TMainForm.atMoveNextExecute(Sender:TObject);
begin
    // ���ƶ�
    MoveListViewSelection(TListView(lvIPHistory), 3);
    bAllSaved := False;
end;

procedure TMainForm.atApplyExecute(Sender:TObject);
var
    item:TListItem;
begin
    if not Assigned(lvIPHistory.Selected) then Exit;
    item := lvIPHistory.Selected;
    if Trim(cbAdapterList.Text) = '' then begin
        // ���û�ж�Ӧ����������������Ӧ��
        SysInfo.ShowMLMessage('SelAdapter');
        Exit;
    end;
    with TApplyForm.Create(self, TConnection(cbAdapterList.Items.Objects[cbAdapterList.ItemIndex]), TIPConfig(Item.Data), IPSetUtil) do begin
        if ShowModal = IDOK then begin
            PingGateDNS(edtGateway);
        end;
        Free;
    end;
end;

procedure TMainForm.atSaveAsConfigExecute(Sender:TObject);
begin
    // ���Ϊ
    if not FCheck then Exit;
    with TSaveAsForm.Create(Self, IPSetUtil) do begin
        if ShowModal = IDOK then begin
            self.edtConfigName.Text := edtNewConfigName.Text;
            atNewConfigExecute(atNewConfig);
            atSaveConfigExecute(atSaveConfig);
        end;
        Free;
    end;
end;

procedure TMainForm.atAdvanceExecute(Sender:TObject);
var
    IPConfig:TIPConfig;
begin
    // ��ϸ��Ϣ
    if not Assigned(lvIPHistory.Selected) then Exit;
    IPConfig := TIPConfig(lvIPHistory.Selected.Data);
    with TIPDetailForm.Create(self, IPConfig) do begin
        // ���ȷ������Ҫ��ʾ�Ƿ񱣴浽�ļ���
        if ShowModal = IDOK then begin
            bAllSaved := False;
            bSetEdit := False;
            ShowDetail(IPConfig);
        end;
        Free;
    end;
end;

procedure TMainForm.SaveDetail(var _IPConfig:TIPConfig);
var
    strTmp:string;
begin
    // ���������Ϣ��������
    if not Assigned(_IPConfig) then Exit;
    with _IPConfig do begin
        ConfigName := edtConfigName.Text;

        AdapterName := TConnection(cbAdapterList.Items.Objects[cbAdapterList.ItemIndex]).AdapterName;

        DHCP := (rgIpSet.ItemIndex = 0);
        if not DHCP then begin
            if (IPList.Count > 0) then IPList.Strings[0] := edtIP.Text
            else IPList.Add(edtIP.Text);

            if (GatewayList.Count > 0) then GatewayList.Strings[0] := edtGateway.Text
            else GatewayList.Add(edtGateway.Text);

            if (SubMaskList.Count > 0) then SubMaskList.Strings[0] := edtMask.Text
            else SubMaskList.Add(edtMask.Text);
        end;

        strTmp := Trim(edtPrimaryDNS.Text);
        if strTmp <> '' then begin
            if (DNSServerList.Count > 0) then DNSServerList.Strings[0] := strTmp
            else DNSServerList.Add(strTmp);
        end;

        strTmp := Trim(edtSecondaryDNS.Text);
        if strTmp <> '' then begin
            if (DNSServerList.Count > 1) then DNSServerList.Strings[1] := strTmp
            else DNSServerList.Add(strTmp);
        end;
    end;
end;

procedure TMainForm.SaveToFile;
var
    FileName:string;
begin
    FileName := GetIPConfigName;
    IPSetUtil.SaveAllConfigs(TListView(lvIPHistory));
    IPSetUtil.SaveAllConfigs(FileName);
end;

procedure TMainForm.ApplyByParam;
var
    nIndex:Integer;
begin
    // ͨ����������������ݷ�ʽ�Զ�����
    if ParamCount = 0 then Exit;
    try
        nIndex := StrToInt(ParamStr(1));
    except
        SysInfo.ShowMLMessage('InvalidPara');
        Exit;
    end;

    if (nIndex < 0) or (nIndex > lvIPHistory.Items.Count) then begin
        SysInfo.ShowMLMessage('InvalidPara');
        Exit;
    end;
    lvIPHistory.Items.Item[nIndex].Selected := True;
    // �л�������
    ShowDetail(TIPConfig(lvIPHistory.Items.Item[nIndex].Data));
    atApplyExecute(nil);
end;

procedure TMainForm.ApplyDefault;
var
    nIndex:Integer;
    i:Integer;
begin
    // ͨ������Ĭ�����÷�ʽ
    if SysInfo.DefaultConfig = '' then Exit;

    nIndex := -1;
    for i := 0 to lvIPHistory.Items.Count - 1 do begin
        if lvIPHistory.Items.Item[i].Caption = SysInfo.DefaultConfig then begin
            nIndex := i;
            Break;
        end;
    end;
    if nIndex = -1 then begin
        SysInfo.ShowMLMessage('NotExistConfig');
        Exit;
    end;
    lvIPHistory.Items.Item[nIndex].Selected := True;
    // �л�������
    ShowDetail(TIPConfig(lvIPHistory.Items.Item[nIndex].Data));
    atApplyExecute(nil);
end;

procedure TMainForm.Initiliaze;
begin
    // ��������
    UpdateLanguage;

    // ���ӿؼ�
    with FControlList do begin
        Add(edtGateway);
        Add(edtPrimaryDNS);
        Add(edtSecondaryDNS);
    end;

    if SysInfo.AutoTray then
        ShowWindow(Handle, SW_MINIMIZE);

    // �Զ�Ӧ�����ã�ǰ���ǵ�ǰ���ڿ�ݷ�ʽ�´���
    if ParamCount = 0 then begin
        // �Զ����������������ʡȥ���º�ȡ�豸�б�
        // û�в������Զ������������ǿ�ݷ�ʽ
        if (not SysInfo.ApplyDefault) and (SysInfo.AutoSearch) then begin
            AutoSearchForm := TAutoSearchForm.Create(Self, IPSetUtil);
            AutoSearchForm.ShowModal;
            AutoSearchForm.Free;
        end;
    end;
    // �¼���ʼ��
    InitEvent;
    // FlagIP������ʷ��Ϣ����
    // ��ʼ��,
    IPSetUtil.GetAllIPConfigs(TListView(lvIPHistory), GetIPConfigName());

    // Hint����
    HintWindowClass := TIPHintWindow;
    // ListViewͷ��ƽ��
    FlatListViewHeader(lvIPHistory);
    // ȡ���豸�б�
    IPSetUtil.GetAllConnections(TComboBox(cbAdapterList));
    cbAdapterList.ItemIndex := 0;
    // ��ʾ��һ������������ϸ��Ϣ
    if cbAdapterList.Items.Count > 0 then
        ShowDetail(TConnection(cbAdapterList.Items.Objects[0]).IPConfig, False);
    TrayIcon.PopupMenu := pmMain;
    TrayIcon.Hint := Application.Title;
    bSaved := True;
    bAllSaved := True;
    atSaveConfig.Enabled := False;
    atSaveAsConfig.Enabled := False;
    atDelConfig.Enabled := False;
    atAdvance.Enabled := False;
    atApply.Enabled := False;
    atPing.Enabled := False;
    bSetEdit := False;
    // ��̬���ɲ˵����������¼�
    InitTrayMenu(pmMain);
    TrayIcon.OnDblClick := OnTrayDbClick;
    TrayIcon.OnRestore := OnTrayRestore;
    // ��ݷ�ʽ��Ч
    if ParamCount > 0 then ApplyByParam
        // Ĭ��Ӧ��
    else if SysInfo.ApplyDefault then ApplyDefault;

    // ��Ȩ��Ϣ
    ShowLicensedInfo;

    // �б�
    DefaultStyle;

    // ��ʾPing����
    FFinished := True;

    // ����λͼ,����Ping
    CreateBMP;
end;

procedure TMainForm.lvIPHistorySelectItem(Sender:TObject; Item:TListItem;
    Selected:Boolean);
var
    bSel:Boolean;
begin
    // �ж��Ƿ���Ҫ��ʾ�޸ĺ�ɾ��
    bSel := (lvIPHistory.SelCount <> 0);
    bSel := bSel and Assigned(Item);
    bSel := bSel and Assigned(Item.Data);
    bSaved := True;
    atDelConfig.Enabled := bSel;
    atApply.Enabled := bSel;
    atSaveAsConfig.Enabled := bSel;
    atPing.Enabled := bSel;
    atAdvance.Enabled := bSel;
    atMovePrev.Enabled := bSel and (Item.Index <> 0);
    atMoveNext.Enabled := bSel and (Item.Index <> lvIPHistory.Items.Count - 1);
end;

procedure TMainForm.FormCloseQuery(Sender:TObject; var CanClose:Boolean);
var
    nRet:Integer;
begin
    // �ж��Ƿ���Ҫ����

    if not bAllSaved then begin
        // �Զ�����
        if SysInfo.AutoSave then begin
            CanClose := True;
            SaveToFile;
        end
        else begin
            nRet := SysInfo.ShowMLMessage('ConfirmSave', '', msYesNoCancel);
            case nRet of
                IDYES:begin
                        CanClose := True;
                        SaveToFile;
                    end;
                IDNo:begin
                        CanClose := True;
                    end; // �����л�ʱ����ʾ ;
                IDCANCEL:begin
                        CanClose := False;
                    end;
            end;
        end;
    end
    else begin
        CanClose := True; // �����л�ʱ����ʾ
    end;
end;

procedure TMainForm.atNewConfigExecute(Sender:TObject);
var
    ip:TIPConfig;
    Item:TListItem;
    strTmp:string;
begin
    // ����
    if not FCheck(False) then Exit;
    bSetEdit := False; // ��������Ժ��½��Ͳ�������atSaveConfig�仯��
    // �����ֵ�˾Ͳ�����������
    if Trim(edtConfigName.Text) = '' then begin
        strTmp := SysInfo.GetMessage('NewConfig', '%s');
        edtConfigName.Text := Format(strTmp, [FormatDateTime('yymmddhhnnss', Now)]);
    end;
    bAllSaved := False;
    bSetEdit := True; // ��������Ժ����Ҫ����仯��
    // ���������
    ip := TIPConfig.Create;
    Item := lvIPHistory.Items.Add;

    if Assigned(Item) and Assigned(IP) then begin
        SaveDetail(ip);
        if IPSetUtil.AddIPConfig(IP) <> 0 then begin
            //Application.MessageBox()
            ip.Free;
            Item.Delete;
        end
        else begin
            Item.Caption := IP.ConfigName;
            Item.Data := IP;
            Item.Selected := True;
        end;
    end;
    InitTrayMenu(pmMain);
end;

procedure TMainForm.ChangeEvent(Sender:TObject);
begin
    if not bSetEdit then Exit;
    bSaved := False;
    bAllSaved := False;
    atSaveConfig.Enabled := True;
    atSaveAsConfig.Enabled := True;
    atNewConfig.Enabled := False;
    atDelConfig.Enabled := False;
    atApply.Enabled := False;
    atPing.Enabled := False;
    EnabledListViewEvent(False);
end;

procedure TMainForm.edtIPChange(Sender:TObject);
begin
    ChangeEvent(Sender);
end;

procedure TMainForm.cbAdapterListChange(Sender:TObject);
var
    objConn:TConnection;
    ComboBox:TComboBox;
begin
    if not bSaved then Exit;
    ChangeEvent(Sender);
    ComboBox := TComboBox(Sender);
    objConn := TConnection(ComboBox.Items.Objects[ComboBox.ItemIndex]);
    ShowDetail(objConn.IPConfig, False);
end;

procedure TMainForm.edtGatewayChange(Sender:TObject);
begin
    ChangeEvent(Sender);
    HideImage;
    if not SysInfo.AutoPing then Exit;
    PingGateDNS(Sender);
end;

procedure TMainForm.atStartAdapterExecute(Sender:TObject);
var
    obj:TConnection;
    strMsg:string;
begin
    // ����������
    if cbAdapterList.Items.Count = 0 then Exit;
    obj := TConnection(cbAdapterList.Items.Objects[cbAdapterList.ItemIndex]);
    strMsg := SysInfo.GetMessage('EnableDeving', '%s');
    strMsg := Format(strMsg, [obj.AdapterDescription]);
    TrayIcon.BalloonTipInfo := strMsg;
    TrayIcon.ShowBalloonTip := True;
    obj.Stat := 1;

    strMsg := SysInfo.GetMessage('EndEnableDev', '%s');
    strMsg := Format(strMsg, [obj.AdapterDescription]);
    TrayIcon.BalloonTipInfo := strMsg;
    TrayIcon.ShowBalloonTip := False;
    HideBalloonTip;
    atRefreshExecute(Sender)
end;

procedure TMainForm.atStopAdapterExecute(Sender:TObject);
var
    obj:TConnection;
    strMsg:string;
begin
    // ֹͣ������
    if cbAdapterList.Items.Count = 0 then Exit;
    obj := TConnection(cbAdapterList.Items.Objects[cbAdapterList.ItemIndex]);
    strMsg := SysInfo.GetMessage('DisableDeving', '%s');
    strMsg := Format(strMsg, [obj.AdapterDescription]);
    TrayIcon.BalloonTipInfo := strMsg;
    TrayIcon.ShowBalloonTip := True;
    obj.Stat := 2;
    strMsg := SysInfo.GetMessage('EndDisableDev', '%s');
    strMsg := Format(strMsg, [obj.AdapterDescription]);
    TrayIcon.BalloonTipInfo := strMsg;
    TrayIcon.ShowBalloonTip := False;
    HideBalloonTip;
    atRefreshExecute(Sender)
end;

procedure TMainForm.atRefreshExecute(Sender:TObject);
var
    OldAdapter:string;
begin
    // ˢ��������
    OldAdapter := cbAdapterList.Text;
    IPSetUtil.GetAllConnections(TComboBox(cbAdapterList));
    cbAdapterList.ItemIndex := cbAdapterList.Items.IndexOf(OldAdapter);
end;

procedure TMainForm.cbAdapterListDrawItem(Control:TWinControl;
    Index:Integer; Rect:TRect; State:TOwnerDrawState);
var
    _Canvas:TCanvas;
    Connection:TConnection;
begin
    // �Զ��廭ͼ
    Connection := TConnection(TComboBox(Control).Items.Objects[Index]);

    _Canvas := TComboBox(Control).Canvas;
    with Connection do begin
        ilDevice.Draw(_Canvas, Rect.Left + 2, Rect.Top, ImageIndex);
        _Canvas.TextOut(Rect.Left + 20, Rect.Top + 4, ConnectionName + ' - ' + AdapterDescription);
        atStopAdapter.Visible := (Stat = 1);
        atStartAdapter.Visible := (Stat = 2);
    end;
end;

procedure TMainForm.atIconExecute(Sender:TObject);
begin
    // ��ͼ��ģʽ
    lvIPHistory.ViewStyle := vsIcon;
end;

procedure TMainForm.atSmallIconExecute(Sender:TObject);
begin
    // Сͼ��ģʽ
    lvIPHistory.ViewStyle := vsSmallIcon;
end;

procedure TMainForm.atReportExecute(Sender:TObject);
begin
    // �б�ģʽ
    lvIPHistory.ViewStyle := vsReport;
end;

procedure TMainForm.lvIPHistoryDragDrop(Sender, Source:TObject; X,
    Y:Integer);
var
    TargetItem, SourceItem, TempItem:TListItem;
begin
    TargetItem := lvIPHistory.GetItemAt(X, Y);
    if TargetItem <> nil then begin
        TempItem := TListItem.Create(lvIPHistory.Items);

        SourceItem := lvIPHistory.Selected;
        TempItem.Assign(SourceItem);
        SourceItem.Assign(TargetItem);
        TargetItem.Assign(TempItem);
        TargetItem.Selected := True;
        // ���浽������
        IPSetUtil.SaveAllConfigs(TListView(lvIPHistory));
        FreeAndNil(TempItem);
    end;
end;

procedure TMainForm.lvIPHistoryDragOver(Sender, Source:TObject; X,
    Y:Integer; State:TDragState; var Accept:Boolean);
var
    TargetItem, SourceItem:TListItem;
begin
    TargetItem := lvIPHistory.GetItemAt(X, Y);
    if (Source = Sender) and (TargetItem <> nil) then begin
        Accept := True;

        SourceItem := lvIPHistory.Selected;
        if SourceItem = TargetItem then
            Accept := False;
    end
    else
        Accept := False;
end;

procedure TMainForm.OnProcessPing(AControlName:string; nResult:Integer; bFinished:Boolean);
var
    ImgName:string;
    img:TImage;
    strTmp:string;
begin
    ImgName := StringReplace(AControlName, 'edt', 'img', []); //GetImageName(PingThread.IP);
    img := TImage(Self.FindComponent(imgName));
    if not Assigned(img) then Exit;

    try
        img.Visible := True;
        // �������Ϊ����Out of System Resource�Ĵ���
        // ��ΪFBitmap.Canvas���̲߳���ȫ��
        FBitmap.Canvas.Lock;
        // ���
        FBitmap.Canvas.FillRect(FBitmap.Canvas.ClipRect);
        case nResult of
            -2:begin
                    // IP��ַΪ��
                end;
            -1:begin // IP ��ַ���Ϸ�
                    ilToolbar.Draw(FBitmap.Canvas, 0, 0, 18);
                    strTmp := SysInfo.GetMessage('InvalidIP');
                    img.Hint := strTmp;
                end;
            0:begin // ��ͨ
                    ilToolbar.Draw(FBitmap.Canvas, 0, 0, 17);
                    strTmp := SysInfo.GetMessage('EConnect');
                    img.Hint := strTmp;
                end;
        else begin // ͨ��
                ilToolbar.Draw(FBitmap.Canvas, 0, 0, 16);
                strTmp := SysInfo.GetMessage('SConnect', '%d');
                img.Hint := Format(strTmp, [nResult]);
            end;
        end;
        img.Picture.Bitmap.Assign(FBitmap);
    finally
        FBitmap.Canvas.Unlock;
    end;

    FFinished := bFinished;
    if not FFinished then begin
        TrayIcon.BalloonTipInfo := SysInfo.GetMessage('Testing');
        TrayIcon.ShowBalloonTip := True;
    end
    else begin
        TrayIcon.BalloonTipInfo := SysInfo.GetMessage('EndTest');
        TrayIcon.ShowBalloonTip := False;
        HideBalloonTip;
    end;
end;

procedure TMainForm.HideImage;
begin
    // ����ͼƬ
    imgPrimaryDNS.Visible := False;
    imgSecondaryDNS.Visible := False;
    imgGateWay.Visible := False;
end;

procedure TMainForm.CreateBMP;
begin
    FBitmap := TBitmap.Create;
    with FBitmap do begin
        Width := ilToolbar.Width;
        Height := ilToolbar.Height;
        PixelFormat := pf24bit;
    end;
end;

procedure TMainForm.PingGateDNS(Sender:TObject);
var
    nRet:Integer;
    FIP:string;
    i:Integer;
    FControl:TCustomEdit;
    bFinish:Boolean;
begin
    // ping
    // ������
    if FFinished then begin
        {//..if PingThread.Suspended then PingThread.Resume;
        SetEvent(PingThread.PingEvent); }

        for i := 0 to FControlList.Count - 1 do begin
            bFinish := (i >= FControlList.Count - 1);
            FControl := TCustomEdit(FControlList.Items[i]);
            if not Assigned(FControl) then Continue;

            FIP := FControl.Text;
            if FIP = '' then begin
                OnProcessPing(FControl.Name, -2, bFinish);
                Continue;
            end;
            if not Assigned(IPSetUtil.ICMPUtil) then Continue;
            if not IPSetUtil.ICMPUtil.CheckIPValid(FIP) then nRet := -1
            else nRet := IPSetUtil.ICMPUtil.PingIP(FIP);
            OnProcessPing(FControl.Name, nRet, bFinish);
            Application.ProcessMessages;
        end;
    end;
end;

procedure TMainForm.InitTrayMenu(PM:TPopupMenu);
var
    MenuItem:TMenuItem;
    i:Integer;
    function GetItemCaption(_IPConfig:TIPConfig):string;
    begin
        Result := '';
        if not Assigned(_IPConfig) then Exit;
        case SysInfo.TrayMenuStyle of
            0:begin
                    if _IPConfig.IPList.Count > 0 then Result := _IPConfig.IPList.Strings[0]
                    else Result := SysInfo.GetMessage('AutoGetIP');
                end;
            1:begin
                    Result := _IPConfig.ConfigName;
                end;
            2:begin
                    Result := _IPConfig.ConfigName;
                    if _IPConfig.IPList.Count > 0 then Result := Format('%s(%s)', [Result, _IPConfig.IPList.Strings[0]])
                    else Result := Format('%s(%s)', [Result, SysInfo.GetMessage('AutoGetIP')])
                end;
        end;
    end;
begin
    ClearTrayMenu(PM);
    MenuItem := TMenuItem.Create(PM);
    MenuItem.Caption := '-';
    PM.Items.Insert(0, MenuItem);
    for i := 0 to lvIPHistory.Items.Count - 1 do begin
        MenuItem := TMenuItem.Create(PM);
        with MenuItem do begin
            Caption := GetItemCaption(TIPConfig(lvIPHistory.Items.Item[i].Data));
            OnClick := ApplySelected;
            Tag := i;
        end;
        PM.Items.Insert(0, MenuItem);
    end;

end;

procedure TMainForm.ClearTrayMenu(PM:TPopupMenu);
var
    MenuItem:TMenuItem;
    i:Integer;
    bFlag:Boolean; // ��-��ʼ���
begin
    // ȡ����
    bFlag := False;
    for i := PM.Items.Count - 1 downto 0 do begin
        MenuItem := PM.Items.Items[i];
        if (not bFlag) and (MenuItem.Caption = '-') then bFlag := True;
        if bFlag then PM.Items.Delete(i);
    end;
end;

procedure TMainForm.ApplySelected(Sender:TObject);
var
    nIndex:Integer;
begin
    // ��Чѡ�������
    nIndex := TMenuItem(Sender).Tag;
    lvIPHistory.Items.Item[nIndex].Selected := True;
    atApplyExecute(atApply);
end;

procedure TMainForm.EnabledListViewEvent(bEanbled:Boolean);
begin
    // �л���ͬ����ʱ���ж�
    if bEanbled then begin
        with lvIPHistory do begin
            OnDblClick := lvIPHistoryDblClick;
            OnDragDrop := lvIPHistoryDragDrop;
            OnDragOver := lvIPHistoryDragOver;
            OnKeyUp := lvIPHistoryKeyUp;
            OnMouseMove := lvIPHistoryMouseMove;
            OnSelectItem := lvIPHistorySelectItem;
        end;
    end
    else begin
        with lvIPHistory do begin
            OnDblClick := nil;
            OnDragDrop := nil;
            OnDragOver := nil;
            OnKeyUp := nil;
            OnMouseMove := nil;
            OnSelectItem := nil;
        end;
    end;
end;

procedure TMainForm.atRestoreExecute(Sender:TObject);
begin
    TrayIcon.Restore
end;

function TMainForm.FCheck(ACheckConfigName:Boolean):Boolean;
var
    strTmp:string;
begin
    Result := False;

    if ACheckConfigName then begin
        strTmp := edtConfigName.Text;
        if strTmp = '' then begin
            SysInfo.ShowMLMessage('NoConfigName');
            edtConfigName.SetFocus;
            Exit;
        end;
    end;

    if cbAdapterList.ItemIndex = -1 then begin
        SysInfo.ShowMLMessage('NoAdapter');
        cbAdapterList.SetFocus;
        Exit;
    end;

    if SysInfo.CheckValid then begin
        if rgIpSet.ItemIndex = 1 then begin
            strTmp := Trim(edtIP.Text);
            if strTmp = '' then begin
                SysInfo.ShowMLMessage('NoIP');
                edtIP.SetFocus;
                Exit;
            end;
            if not TICMPUtil.CheckIPValid(strTmp) then begin
                SysInfo.ShowMLMessage('InvalidIP');
                edtIP.SetFocus;
                Exit;
            end;
            strTmp := Trim(edtMask.Text);
            if strTmp = '' then begin
                SysInfo.ShowMLMessage('NoMask');
                edtMask.SetFocus;
                Exit;
            end;
            if not TICMPUtil.CheckIPValid(strTmp) then begin
                SysInfo.ShowMLMessage('InvalidMask');
                edtMask.SetFocus;
                Exit;
            end;
            strTmp := Trim(edtGateway.Text);
            if strTmp = '' then begin
                SysInfo.ShowMLMessage('NoGate');
                edtGateway.SetFocus;
                Exit;
            end;
            if not TICMPUtil.CheckIPValid(strTmp) then begin
                SysInfo.ShowMLMessage('InvalidGate');
                edtGateway.SetFocus;
                Exit;
            end;
            case InSameSegment(edtIP.Text, edtGateway.Text) of
                -1:begin
                        SysInfo.ShowMLMessage('SameIPGate');
                        edtGateway.SetFocus;
                        Exit;
                    end;
                1:begin
                        SysInfo.ShowMLMessage('Segment');
                        edtGateway.SetFocus;
                        Exit;
                    end;
            end;
        end;
        if rgDNSSet.ItemIndex = 1 then begin
            strTmp := Trim(edtPrimaryDNS.Text);
            if strTmp = '' then begin
                SysInfo.ShowMLMessage('NoDNS');
                edtPrimaryDNS.SetFocus;
                Exit;
            end;
            if not TICMPUtil.CheckIPValid(strTmp) then begin
                SysInfo.ShowMLMessage('InvalidDNS');
                edtPrimaryDNS.SetFocus;
                Exit;
            end;
            strTmp := Trim(edtSecondaryDNS.Text);
            if (strTmp <> '') and (not TICMPUtil.CheckIPValid(strTmp)) then begin
                SysInfo.ShowMLMessage('InvalidDNS');
                edtGateway.SetFocus;
                Exit;
            end;
        end;
    end;
    Result := True;
end;

procedure TMainForm.ShowLicensedInfo;
var
    LicensedTo:string;
begin
    // ��ʾ��Ȩ��Ϣ
    LicensedTo := SysInfo.GetMessage('LicensedTo');
    if SysInfo.SystemInfo.wjwj_wjky__aaa then begin
        spLicensed.Caption := LicensedTo + ' ' + SysInfo.UserName
    end
    else begin
        spLicensed.Font.Color := clRed;
        spLicensed.Caption := LicensedTo + ' δ��Ȩ';
    end;
end;

procedure TMainForm.DefaultStyle;
begin
    case SysInfo.ListStyle of
        0:begin
                lvIPHistory.ViewStyle := vsIcon;
                atIcon.Checked := True;
            end;
        1:begin
                lvIPHistory.ViewStyle := vsSmallIcon;
                atSmallIcon.Checked := True;
            end;
        2:begin
                lvIPHistory.ViewStyle := vsReport;
                atReport.Checked := True;
            end;
    else begin
            lvIPHistory.ViewStyle := vsIcon;
            atIcon.Checked := True;
        end;
    end;
end;

procedure TMainForm.UpdateLanguage;
var
    i, J:Integer;
    AComponent:TComponent;
    AFormName:string;
    strComName:string;
    strDefault:string;
    strTmp:string;
    nWidth:Integer;
begin
    SysInfo.UpdateFormLanguage(Self);
    if SysInfo.LanguageList.Count = 0 then Exit;
    AFormName := Self.Name;
    nWidth := Self.Canvas.TextWidth('E'); // ���ֿ��
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
        else if AComponent is TRzCheckBox then begin
            strComName := TRzCheckBox(AComponent).Name + '';
            if AComponent is TCustomCheckBox then begin
                strDefault := '';
            end;
            strDefault := TRzCheckBox(AComponent).Caption;
            TRzCheckBox(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end
        else if AComponent is TRzRadioGroup then begin
            strComName := TRzRadioGroup(AComponent).Name;
            strDefault := '';
            for J := 0 to TRzRadioGroup(AComponent).Items.Count - 1 do begin
                strDefault := strDefault + TRzRadioGroup(AComponent).Items[J] + '|';
            end;

            strTmp := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
            strTmp := strTmp + '|';
            for J := 0 to TRzRadioGroup(AComponent).Items.Count - 1 do begin
                TRzRadioGroup(AComponent).Items[J] := Copy(strTmp, 0, Pos('|', strTmp) - 1);
                Delete(strTmp, 1, Pos('|', strTmp));
            end;
            ResetRadioGroupSize(TRzRadioGroup(AComponent), nWidth);
        end;
    end;
    for i := 0 to Self.MainMenu.Items.Count - 1 do begin
        AComponent := TMenuItem(Self.MainMenu.Items[i]);
        strComName := TMenuItem(AComponent).Name + '';
        strDefault := TMenuItem(AComponent).Caption;
        TMenuItem(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
    end;
end;

procedure TMainForm.ResetRadioGroupSize(ARadioGroup:TRzRadioGroup; APixWidth:Integer);
var
    nMaxLength:Integer;
    i:Integer;
begin
    // �������ô�С����Ҫ�������
    nMaxLength := 0;
    if not Assigned(ARadioGroup) then Exit;
    for i := 0 to ARadioGroup.Items.Count - 1 do begin
        if Length(ARadioGroup.Items.Strings[i]) > nMaxLength then
            nMaxLength := Length(ARadioGroup.Items.Strings[i]);
    end;
    ARadioGroup.Width := APixWidth * (nMaxLength + 4);
end;

procedure TMainForm.OnTrayDbClick(Sender:TObject);
begin
    Application.Restore;
end;

procedure TMainForm.OnTrayRestore(Sender:TObject);
begin
    Self.WindowState := wsNormal;
    Self.Position := poDesktopCenter;
    Self.Invalidate;
end;

procedure TMainForm.atShortCutExecute(Sender:TObject);
var
    item:TListItem;
    strDest:string;
begin
    // ���ɿ�ݷ�ʽ
    if not Assigned(lvIPHistory.Selected) then Exit;
    item := lvIPHistory.Selected;
    strDest := SysInfo.GetMessage('ShortCutTitle', '%d');
    strDest := Format(strDest, [item.Caption]);

    CreateShortcut(Application.ExeName, strDest, IntToStr(item.Index), item.Caption);
end;

procedure TMainForm.atRegExecute(Sender:TObject);
begin
    with TRegistryForm.Create(self) do begin
        ShowModal;
        Free;
    end;
end;

procedure TMainForm.atPingExecute(Sender:TObject);
begin
    // ����������
    PingGateDNS(edtGateway);
end;

procedure TMainForm.InitEvent;
begin
    // ��ֹ�ƽ�
    MainForm.OnCloseQuery := FormCloseQuery;
    sbMovePrev.Action := atMovePrev;
    sbMoveNext.Action := atMoveNext;
    EnabledListViewEvent(True); // Listview
    lvIPHistory.OnClick := lvIPHistoryClick;
    sbRefresh.Action := atRefresh;
    edtIP.OnChange := edtIPChange;
    edtGateway.OnChange := edtGatewayChange;
    edtMask.OnChange := edtIPChange;
    edtPrimaryDNS.OnChange := edtGatewayChange;
    edtSecondaryDNS.OnChange := edtGatewayChange;
    rgIpSet.OnClick := rgIpSetClick;
    rgDNSSet.OnClick := rgDNSSetClick;
    edtConfigName.OnChange := edtIPChange;
    with cbAdapterList do begin
        OnChange := cbAdapterListChange;
        OnDrawItem := cbAdapterListDrawItem;
    end;
    btnFrames.Action := atSaveConfig;
    btnComboBoxes.Action := atOption;
    btnCommon.Action := atExit;
    btnEdits.Action := atApply;
    btnTabs.Action := atDelConfig;
    btnWelcome.Action := atNewConfig;
    atNewConfig.OnExecute := atNewConfigExecute;
    atSaveConfig.OnExecute := atSaveConfigExecute;
    atDelConfig.OnExecute := atDelConfigExecute;
    atApply.OnExecute := atApplyExecute;
    atAdvance.OnExecute := atAdvanceExecute;
    atAbout.OnExecute := atAboutExecute;
    atRefresh.OnExecute := atRefreshExecute;
    atOption.OnExecute := atOptionExecute;
    atStopAdapter.OnExecute := atStopAdapterExecute;
    atStartAdapter.OnExecute := atStartAdapterExecute;
    atExit.OnExecute := atExitExecute;
    atIcon.OnExecute := atIconExecute;
    atSmallIcon.OnExecute := atSmallIconExecute;
    atReport.OnExecute := atReportExecute;
    atMovePrev.OnExecute := atMovePrevExecute;
    atMoveNext.OnExecute := atMoveNextExecute;
    atRestore.OnExecute := atRestoreExecute;
    atShortCut.OnExecute := atShortCutExecute;
    atReg.OnExecute := atRegExecute;
    sbStopAdapter.Action := atStopAdapter;
    sbStartAdapter.Action := atStartAdapter;
    atPing.OnExecute := atPingExecute;
    atSaveAsConfig.OnExecute := atSaveAsConfigExecute;
    K1.Action := atShortCut;
    X1.Action := atExit;
    N7.Action := atNewConfig;
    S2.Action := atSaveConfig;
    D2.Action := atDelConfig;
    A3.Action := atAdvance;
    A4.Action := atApply;
    N5.Action := atIcon;
    N4.Action := atSmallIcon;
    N6.Action := atReport;
    O1.Action := atOption;
    B1.Action := atAbout;
    N1.Action := atNewConfig;
    S1.Action := atSaveConfig;
    D1.Action := atDelConfig;
    E1.Action := atAdvance;
    A2.Action := atApply;
    N11.Action := atIcon;
    N12.Action := atSmallIcon;
    N13.Action := atReport;
    B2.Action := atAbout;
    X2.Action := atExit;
    R1.Action := atRestore;
    N15.Action := atReg;
    N3.Action := atPing;
    N9.Action := atPing;
    N16.Action := atSaveAsConfig;
    N17.Action := atSaveAsConfig;
end;

end.

