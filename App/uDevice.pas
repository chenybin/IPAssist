unit uDevice;

interface

uses
    SetupAPI, Windows, Messages, Classes, SysUtils,System.AnsiStrings;
{$DEFINE DEBUG}
const
    CfgMgr32ModuleName = 'cfgmgr32.dll';
    SetupApiModuleName = 'SetupApi.dll';
    REGSTR_VAL_NODISPLAYCLASS = 'NoDisplayClass';
    CR_SUCCESS = $00000000;
    CR_REMOVE_VETOED = $00000017;
    DN_HAS_PROBLEM = $00000400;
    DN_DISABLEABLE = $00002000;
    DN_REMOVABLE = $00004000;
    DN_NO_SHOW_IN_DM = $40000000;
    CM_PROB_DISABLED = $00000016;
    CM_PROB_HARDWARE_DISABLED = $0000001D;

type
    _PNP_VETO_TYPE = (
        PNP_VetoTypeUnknown,
        PNP_VetoLegacyDevice,
        PNP_VetoPendingClose,
        PNP_VetoWindowsApp,
        PNP_VetoWindowsService,
        PNP_VetoOutstandingOpen,
        PNP_VetoDevice,
        PNP_VetoDriver,
        PNP_VetoIllegalDeviceRequest,
        PNP_VetoInsufficientPower,
        PNP_VetoNonDisableable,
        PNP_VetoLegacyDriver
        );
    PNP_VETO_TYPE = _PNP_VETO_TYPE;
    PPNP_VETO_TYPE = ^_PNP_VETO_TYPE;
    TPNPVetoType = _PNP_VETO_TYPE;
    PPNPVetoType = PPNP_VETO_TYPE;

function CM_Get_DevNode_Status(pulStatus:PULong; pulProblemNumber:PULong;
    dnDevInst:DWord; ulFlags:ULong):DWord; stdcall;
external CfgMgr32ModuleName name 'CM_Get_DevNode_Status';

function CM_Request_Device_Eject(dnDevInst:DWord; out pVetoType:TPNPVetoType;
    pszVetoName:PChar; ulNameLength:ULong; ulFlags:ULong):DWord; stdcall;
external SetupApiModuleName name 'CM_Request_Device_EjectA';

type
    // 设备状态
    TDeviceStat = (dsNone, dsEnabled, dsDisabled, dsEject);

    TDevInfor = class
        ImageIndex:Integer;
        Overlay:Integer;
        DevName:string;
        DevIndex:Integer;
    end;

    TDevInforUtil = class
    private
        DevInfo:hDevInfo;
        ClassImageListData:TSPClassImageListData;
        ShowHidden:Boolean;
        FDeviceList:TStringList;
        FImageListHandle:THandle;

        procedure ClearDeviceList;

        function CheckStatus(SelectedItem:DWord; hDevInfo:hDevInfo; StatusFlag:LongWord):Boolean;
        function IsDisabled(SelectedItem:DWord; hDevInfo:hDevInfo):Boolean;
        function StateChange(NewState:DWord; SelectedItem:DWord; hDevInfo:hDevInfo):Boolean;

        function EnumAddDevices(ShowHidden:Boolean; DevInfo:hDevInfo):Boolean;
        procedure WMDeviceChange(var Msg:TMessage); message WM_DEVICECHANGE;
        procedure GetDevInfo;
        function ChangeDisableDevice(ADevIndex:Integer; bRefersh:Boolean = False):Integer;
        function ChangeEnableDevice(ADevIndex:Integer; bRefersh:Boolean = False):INteger;
        procedure EjectDevice(ADevIndex:Integer);

        function GetDeviceIndex(ADeviceName:string):Integer;
    public
        constructor Create;
        destructor Destroy; override;

        property ImageListHandle:THandle read FImageListHandle;
        function RestartDevice(ADeviceName:string):Integer;
        function GetDeviceState(ADeviceName:string):Integer;
        function SetDeviceState(ADeviceName:string; ADeviceStat:TDeviceStat):Integer;
        function GetImageIndex(ADeviceName:string):Integer;
        property DevList:TStringList read FDeviceList;
    end;

implementation
uses
    uUtiles;
{ TDevInforUtil }

constructor TDevInforUtil.Create;
begin
    if (not LoadSetupAPI) then begin
        OutputDebugInfo('Could not load SetupAPI.dll');
        exit;
    end;
    DevInfo := nil;
    ShowHidden := True;
    GetDevInfo;
    FDeviceList := TStringList.Create;

    // Add the devices to the TreeView window.
    EnumAddDevices(ShowHidden, DevInfo);
end;

destructor TDevInforUtil.Destroy;
begin
    ClearDeviceList;
    FDeviceList.Free;
    SetupDiDestroyDeviceInfoList(DevInfo);
    SetupDiDestroyClassImageList(ClassImageListData);
    UnloadSetupApi;
    inherited;
end;

function TDevInforUtil.CheckStatus(SelectedItem:DWord; hDevInfo:hDevInfo; StatusFlag:LongWord):Boolean;
var
    DeviceInfoData:TSPDevInfoData;
    Status, Problem:DWord;
begin
    DeviceInfoData.cbSize := SizeOf(TSPDevInfoData);
    // Get a handle to the Selected Item.
    if (not SetupDiEnumDeviceInfo(hDevInfo, SelectedItem, DeviceInfoData)) then begin
        Result := false;
        exit;
    end;
    if (CM_Get_DevNode_Status(@Status, @Problem, DeviceInfoData.DevInst, 0) <> CR_SUCCESS) then begin
        Result := false;
        exit;
    end;
    Result := ((Status and StatusFlag = StatusFlag) and not (CM_PROB_HARDWARE_DISABLED = Problem));
end;

function TDevInforUtil.IsDisabled(SelectedItem:DWord; hDevInfo:hDevInfo):Boolean;
var
    DeviceInfoData:TSPDevInfoData;
    Status, Problem:DWord;
begin
    DeviceInfoData.cbSize := SizeOf(TSPDevInfoData);
    // Get a handle to the Selected Item.
    if (not SetupDiEnumDeviceInfo(hDevInfo, SelectedItem, DeviceInfoData)) then begin
        Result := false;
        exit;
    end;
    if (CM_Get_DevNode_Status(@Status, @Problem, DeviceInfoData.DevInst, 0) <> CR_SUCCESS) then begin
        Result := false;
        exit;
    end;
    Result := ((Status and DN_HAS_PROBLEM = DN_HAS_PROBLEM) and (CM_PROB_DISABLED = Problem));
end;

function TDevInforUtil.StateChange(NewState:DWord; SelectedItem:DWord; hDevInfo:hDevInfo):Boolean;
var
    PropChangeParams:TSPPropChangeParams;
    DeviceInfoData:TSPDevInfoData;
begin
    PropChangeParams.ClassInstallHeader.cbSize := SizeOf(TSPClassInstallHeader);
    DeviceInfoData.cbSize := SizeOf(TSPDevInfoData);
    // Get a handle to the Selected Item.
    if (not SetupDiEnumDeviceInfo(hDevInfo, SelectedItem, DeviceInfoData)) then begin
        Result := false;
        OutputDebugInfo('EnumDeviceInfo');
        exit;
    end;
    // Set the PropChangeParams structure.
    PropChangeParams.ClassInstallHeader.InstallFunction := DIF_PROPERTYCHANGE;
    PropChangeParams.Scope := DICS_FLAG_GLOBAL;
    PropChangeParams.StateChange := NewState;
    if (not SetupDiSetClassInstallParams(hDevInfo, @DeviceInfoData,
        PSPClassInstallHeader(@PropChangeParams), SizeOf(PropChangeParams))) then begin
        Result := false;
        OutputDebugInfo('SetClassInstallParams');
        exit;
    end;
    // Call the ClassInstaller and perform the change.
    if (not SetupDiCallClassInstaller(DIF_PROPERTYCHANGE, hDevInfo, @DeviceInfoData)) then begin
        Result := false;
        OutputDebugInfo('SetClassInstallParams');
        exit;
    end;
    Result := true;
end;

function TDevInforUtil.EnumAddDevices(ShowHidden:Boolean; DevInfo:hDevInfo):Boolean;
const
    DEV_CLASS_NAME = 'Net';
var
    i, Status, Problem:DWord;
    pszText:PAnsiChar;
    DeviceInfoData:TSPDevInfoData;
    iImage:Integer;
    Dev:TDevInfor;
    ClassName:PAnsiChar;
    ClassSize, ReqClassSize:DWORD;

    function IsClassHidden(ClassGuid:TGuid):Boolean;
    var
        bHidden:Boolean;
        hKeyClass:HKey;
    begin
        bHidden := false;
        hKeyClass := SetupDiOpenClassRegKey(@ClassGuid, KEY_READ);
        if (hKeyClass <> 0) then begin
            bHidden := (RegQueryValueEx(hKeyClass, REGSTR_VAL_NODISPLAYCLASS, nil, nil, nil, nil) = ERROR_SUCCESS);
            RegCloseKey(hKeyClass);
        end;
        Result := bHidden;
    end;

    function ConstructDeviceName(DeviceInfoSet:hDevInfo;
        DeviceInfoData:TSPDevInfoData; Buffer:PAnsiChar; dwLength:DWord):Boolean;
    const
        UnknownDevice = '<Unknown Device>';

        function GetRegistryProperty(PnPHandle:hDevInfo; DevData:TSPDevInfoData; Prop:DWord; Buffer:PAnsiChar; dwLength:DWord):Boolean;
        var
            aBuffer:array[0..256] of AnsiChar;
        begin
            dwLength := 0;
            aBuffer[0] := #0;
            SetupDiGetDeviceRegistryProperty(PnPHandle, DevData, Prop, Prop, PBYTE(@aBuffer[0]), SizeOf(aBuffer), dwLength);
            System.AnsiStrings.StrCopy(Buffer, aBuffer);
            Result := Buffer^ <> #0;
        end;
    begin
        if (not GetRegistryProperty(DeviceInfoSet, DeviceInfoData, SPDRP_FRIENDLYNAME, Buffer, dwLength)) then begin
            if (not GetRegistryProperty(DeviceInfoSet, DeviceInfoData, SPDRP_DEVICEDESC, Buffer, dwLength)) then begin
                if (not GetRegistryProperty(DeviceInfoSet, DeviceInfoData, SPDRP_CLASS, Buffer, dwLength)) then begin
                    if (not GetRegistryProperty(DeviceInfoSet, DeviceInfoData, SPDRP_CLASSGUID, Buffer, dwLength)) then begin
                        dwLength := DWord(SizeOf(UnknownDevice));
                        Buffer := Pointer(LocalAlloc(LPTR, Cardinal(dwLength)));
                        System.AnsiStrings.StrCopy(Buffer, UnknownDevice);
                    end;
                end;
            end;
        end;
        Result := true;
    end;

    function GetClassImageIndex(ClassGuid:TGuid; Index:PInt):Boolean;
    begin
        Result := SetupDiGetClassImageIndex(ClassImageListData, ClassGuid, Index^);
    end;

begin
    DeviceInfoData.cbSize := SizeOf(TSPDevInfoData);
    Result := False;
    ClearDeviceList;
    i := 0;
    ClassSize := 255;
    GetMem(ClassName, 256);
    GetMem(pszText, 256);
    try
        // Enumerate though all the devices.
        while SetupDiEnumDeviceInfo(DevInfo, i, DeviceInfoData) do begin
            inc(i);
            // Should we display this device, or move onto the next one.
            if (CM_Get_DevNode_Status(@Status, @Problem, DeviceInfoData.DevInst, 0) <> CR_SUCCESS) then break;

            if (not (ShowHidden or not (Boolean(Status and DN_NO_SHOW_IN_DM) or IsClassHidden(DeviceInfoData.ClassGuid)))) then break;

            if not SetupDiClassNameFromGuid(DeviceInfoData.ClassGuid, ClassName, ClassSize, @ReqClassSize) then begin
                if ReqClassSize > ClassSize then begin
                    FreeMem(ClassName);
                    ClassSize := ReqClassSize;
                    GetMem(ClassName, ClassSize + 1);
                    if not SetupDiClassNameFromGuid(DeviceInfoData.ClassGuid, ClassName, ClassSize,
                        @ReqClassSize) then
                        Exit;
                end
                else
                    Exit;
            end;
            ConstructDeviceName(DevInfo, DeviceInfoData, pszText, DWord(nil));

            // 这里指定，需要查的类型是网络设备
            if not SameText(ClassName, DEV_CLASS_NAME) then
                Continue;

            // Get a friendly name for the device.
            ConstructDeviceName(DevInfo, DeviceInfoData, pszText, DWord(nil)); OutputDebugInfo(pszText);
            // Try to get an icon index for this device.
            if (GetClassImageIndex(DeviceInfoData.ClassGuid, @iImage)) then begin
                Dev := TDevInfor.Create;
                Dev.ImageIndex := iImage;
                Dev.DevName := pszText;
                Dev.DevIndex := i - 1;
                FDeviceList.AddObject(pszText, Dev);

                if (Problem = CM_PROB_DISABLED) then begin
                    // red (X)
                    Dev.Overlay := IDI_DISABLED_OVL - IDI_CLASSICON_OVERLAYFIRST;
                end else begin
                    if (Boolean(Problem)) then begin
                        // yellow (!)
                        Dev.Overlay := IDI_PROBLEM_OVL - IDI_CLASSICON_OVERLAYFIRST;
                    end;
                end;
                if (Status and DN_NO_SHOW_IN_DM = DN_NO_SHOW_IN_DM) then begin
                    // Greyed out
                              //..TTreeView(hWndTree).Items[i - 1].Cut := true;
                end;
            end;
        end;
    finally
        FreeMem(pszText);
        FreeMem(ClassName);
    end;
    Result := true;
end;

procedure TDevInforUtil.GetDevInfo;
begin
    if (assigned(DevInfo)) then begin
        SetupDiDestroyDeviceInfoList(DevInfo);
        SetupDiDestroyClassImageList(ClassImageListData);
    end;
    // Get a handle to all devices in all classes present on system
    DevInfo := SetupDiGetClassDevs(nil, nil, 0, DIGCF_PRESENT or DIGCF_ALLCLASSES);
    if (DevInfo = Pointer(INVALID_HANDLE_VALUE)) then begin
        OutputDebugInfo('GetClassDevs');
        exit;
    end;
    // Get the Images for all classes, and bind to the TreeView
    ClassImageListData.cbSize := SizeOf(TSPClassImageListData);
    if (not SetupDiGetClassImageList(ClassImageListData)) then begin
        OutputDebugInfo('GetClassImageList');
        exit;
    end;
    FImageListHandle := ClassImageListData.ImageList;
end;

function TDevInforUtil.ChangeEnableDevice(ADevIndex:Integer; bRefersh:Boolean):Integer;
begin
    //    if (MessageBox(0, 'Enable this Device?', 'Change Device Status', MB_OKCANCEL) = IDOK) then begin
    Result := -1;
    if (StateChange(DICS_ENABLE, ADevIndex, DevInfo)) then begin
        if bRefersh then EnumAddDevices(ShowHidden, DevInfo)
    end
    else Exit;
    Result := 0;
    //    end;
end;

function TDevInforUtil.ChangeDisableDevice(ADevIndex:Integer; bRefersh:Boolean = False):Integer;
begin
    //    if (MessageBox(0, 'Disable this Device?', 'Change Device Status', MB_OKCANCEL) = IDOK) then begin
    Result := -1;
    if (StateChange(DICS_DISABLE, ADevIndex, DevInfo)) then begin
        if bRefersh then EnumAddDevices(ShowHidden, DevInfo)
    end
    else Exit;
    Result := 0;
    //    end;
end;

procedure TDevInforUtil.EjectDevice(ADevIndex:Integer);
var
    DeviceInfoData:TSPDevInfoData;
    Status, Problem:DWord;
    VetoType:TPNPVetoType;
    VetoName:array[0..256] of Char;
begin
    if (MessageBox(0, 'Eject this Device?', 'Eject Device', MB_OKCANCEL) = IDOK) then begin
        DeviceInfoData.cbSize := SizeOf(TSPDevInfoData);
        // Get a handle to the Selected Item.
        if (not SetupDiEnumDeviceInfo(DevInfo, ADevIndex, DeviceInfoData)) then begin
            exit;
        end;
        if (CM_Get_DevNode_Status(@Status, @Problem, DeviceInfoData.DevInst, 0) <> CR_SUCCESS) then begin
            exit;
        end;
        VetoName[0] := #0;
        case CM_Request_Device_Eject(DeviceInfoData.DevInst, VetoType, @VetoName, SizeOf(VetoName), 0) of
            CR_SUCCESS:begin
                    EnumAddDevices(ShowHidden, DevInfo);
                end;
            CR_REMOVE_VETOED:begin
                    MessageBox(0, PChar('Failed to eject the Device (Veto: ' + VetoName + ')'), 'Vetoed', MB_OK);
                end;
        else begin
                MessageBox(0, PChar('Failed to eject the Device (' + SysErrorMessage(GetLastError) + ')'), 'Failure', MB_OK);
            end;
        end;
    end;
end;

procedure TDevInforUtil.WMDeviceChange(var Msg:TMessage);
const
    DBT_DEVNODES_CHANGED = $0007;
begin
    case Msg.wParam of
        DBT_DEVNODES_CHANGED:begin
                GetDevInfo;
                EnumAddDevices(ShowHidden, DevInfo);
            end;
    end;
end;

procedure TDevInforUtil.ClearDeviceList;
var
    i:Integer;
begin
    for i := 0 to FDeviceList.Count - 1 do begin
        TDevInfor(FDeviceList.Objects[i]).Free;
    end;
    FDeviceList.Clear;
end;

function TDevInforUtil.RestartDevice(ADeviceName:string):Integer;
var
    DeviceIndex:Integer;
begin
    // 重启设备
    Result := -1;
    OutputDebugInfo(PChar(ADeviceName));
    DeviceIndex := GetDeviceIndex(ADeviceName);
    if DeviceIndex = -1 then Exit;

    Result := -2;
    OutputDebugInfo('Disabled');
    if (ChangeDisableDevice(DeviceIndex) <> 0) then Exit;

    Result := -3;
    OutputDebugInfo('Enable');
    if (ChangeEnableDevice(DeviceIndex) <> 0) then Exit;
    //..EnumAddDevices(False, DevInfo);
    Result := 0;
end;

function TDevInforUtil.GetDeviceState(ADeviceName:string):Integer;
var
    DeviceIndex:Integer;
begin
    // 获得设备状态
    // 2 为当前不可用
    // 3 为当前可用
    // 4 为当前可移除,不可用
    // 5 为当前可移除，可用
    Result := -1;
    DeviceIndex := GetDeviceIndex(ADeviceName);
    if DeviceIndex = -1 then Exit;

    Result := 0;
    if (IsDisabled(DeviceIndex, DevInfo)) then Result := 2
    else begin
        if (CheckStatus(DeviceIndex, DevInfo, DN_DISABLEABLE)) then Result := 3;
    end;
    //.. 这种情况暂时不考虑
    {if (CheckStatus(DeviceIndex, DevInfo, DN_REMOVABLE)) then begin
        Result := Result + 3;
    end;}
end;

function TDevInforUtil.SetDeviceState(ADeviceName:string; ADeviceStat:TDeviceStat):Integer;
var
    DeviceIndex:Integer;
begin
    // 重启设备
    Result := -1;
    OutputDebugInfo(PChar('SetDeviceStatus   ' + ADeviceName));
    DeviceIndex := GetDeviceIndex(ADeviceName);
    if DeviceIndex = -1 then Exit;

    Result := -2;
    OutputDebugInfo('SetDeviceStatus');
    case ADeviceStat of
        dsNone:;
        dsEnabled:if ChangeEnableDevice(DeviceIndex) <> 0 then Exit;
        dsDisabled:if ChangeDisableDevice(DeviceIndex) <> 0 then Exit;
        dsEject:EjectDevice(DeviceIndex);
    end;
    OutputDebugInfo('SetDeviceStatus OK');
    Result := 0;
end;

function TDevInforUtil.GetDeviceIndex(ADeviceName:string):Integer;
var
    I:Integer;
begin
    // 获得设备在FDeviceList中的对应的设备序号
    Result := -1;
    for i := 0 to FDeviceList.Count - 1 do begin
        if FDeviceList.Strings[i] = ADeviceName then begin
            Result := TDevInfor(FDeviceList.Objects[i]).DevIndex;
            Break;
        end;
    end;
end;

function TDevInforUtil.GetImageIndex(ADeviceName:string):Integer;
var
    DeviceIndex:Integer;
begin
    // 获得设备的图片序号
    // 2 为当前不可用
    // 3 为当前可用
    // 4 为当前可移除,不可用
    // 5 为当前可移除，可用
    Result := -1;
    DeviceIndex := GetDeviceIndex(ADeviceName);
    if DeviceIndex = -1 then Exit
    else Result := DeviceIndex;
end;

end.

