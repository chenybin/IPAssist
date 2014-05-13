unit uIPAssist;
{

    以后需要考虑文件类型和文件版本
}
interface

uses
    Classes, Windows, SysUtils, Messages,
    ComCtrls, StdCtrls, uDevice, uICMPUtil;

const
    NETWORKROOTKEY:string = 'SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}';
    TCPIPROOTKEY:string = 'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\';
    NETBIOSROOTKEY:string = 'SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_';
    NETCARDROOT:string = 'SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\';
    IEROOTKEY:string = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
    DEFAULTDIALROOTKEY:string = 'SOFTWARE\Microsoft\RAS AutoDial\Default';
    FileHeader:string = 'IPSTV1.1';
type
  TOnProcess = procedure (AControlName:string; nResult:Integer;
      bFinished:Boolean = False) of object;
    TIPConfig = class;
    // 连接信息，包括连接对应的适配器信息
  TConnection = class(TObject)
  private
    FAdapterDescription: string;
    FAdapterName: string;
    FConnectionName: string;
    FDeviceUtil: TDevInforUtil;
    FImageIndex: Integer;
    FIPConfig: TIPConfig;
    FMacAddress: string;
    FStat: Integer;
    function GetDeviceStat: Integer;
    function GetImageIndex: Integer;
    procedure SetDeviceStat(const Value: Integer);
  public
    constructor Create(ADeviceUtil:TDevInforUtil);
    destructor Destroy; override;
    procedure RefershStat;
    function RefreshIPConfig: Integer;
    function Restart: Integer;
  published
    property AdapterDescription: string read FAdapterDescription write
        FAdapterDescription;
    property AdapterName: string read FAdapterName write FAdapterName;
    property ConnectionName: string read FConnectionName write FConnectionName;
    property ImageIndex: Integer read FImageIndex;
    property IPConfig: TIPConfig read FIPConfig;
    property MacAddress: string read FMacAddress write FMacAddress;
    property Stat: Integer read FStat write SetDeviceStat;
  end;

    // 连接列表
  TConnectionList = class(TStringList)
  private
    FDeviceUtil: TDevInforUtil;
    procedure ClearObject;
    procedure GetAllConnectionsByReg;
    function GetConnection(AAdapterName:string): string;
  public
    constructor Create;
    destructor Destroy; override;
    function GetAdapertIndex(AAdapterName:string): Integer;
    function GetAdapterName(AAdapterDest:string): string;
    procedure GetAllConnections(AComboBox:TComboBox);
    function RestartConnection(AAdapterName:string): Integer;
  end;

    // IE代理服务器设置
  TIEProxySet = class(TObject)
  private
    FEnabled: Boolean;
    FProxyEnable: DWORD;
    FProxyOverride: string;
    FProxyPort: Integer;
    FProxyServer: string;
  public
    constructor Create;
    procedure Apply;
    procedure Assign(AIEProxySet:TIEProxySet);
    procedure LoadFromStream(MS:TMemoryStream);
    procedure SaveToStream(MS:TMemoryStream);
  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property ProxyEnable: DWORD read FProxyEnable write FProxyEnable;
    property ProxyOverride: string read FProxyOverride write FProxyOverride;
    property ProxyPort: Integer read FProxyPort write FProxyPort;
    property ProxyServer: string read FProxyServer write FProxyServer;
  end;

    // IE拨号设置
  TIEDialSet = class(TObject)
  private
    FConnectionList: TStringList;
    FDefaultConnection: string;
    FDialSet: Integer;
    FEnabled: Boolean;
    procedure GetConnectionList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Apply;
    procedure Assign(AIEDialSet:TIEDialSet);
    procedure LoadFromStream(MS:TMemoryStream);
    procedure SaveToStream(MS:TMemoryStream);
  published
    property ConnectionList: TStringList read FConnectionList;
    property DefaultConnection: string read FDefaultConnection;
    property DialSet: Integer read FDialSet write FDialSet;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

    // NetBios相关配置信息类
    // 包括WINS服务器信息
  TNetBIOS = class(TObject)
  private
    FEnabled: Boolean;
    FNameServerList: TStringList;
    FNetBIOSOptions: DWORD;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Apply(AAdapter:string);
    procedure Assign(ANetBios:TNetBios);
    procedure LoadFromStream(MS:TMemoryStream);
    procedure SaveToStream(MS:TMemoryStream);
  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property NameServerList: TStringList read FNameServerList write
        FNameServerList;
    property NetBIOSOptions: DWORD read FNetBIOSOptions write FNetBIOSOptions;
  end;

    // IP配置信息
  TIPConfig = class(TObject)
  private
    FAdapterName: string;
    FConfigName: string;
    FDHCP: Boolean;
    FDNSServerList: TStringList;
    FGatewayList: TStringList;
    FIEDialSet: TIEDialSet;
    FIEProxySet: TIEProxySet;
    FIPList: TStringList;
    FNetBios: TNetBios;
    FSubMaskList: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function Apply: Integer;
    procedure Assign(AIPConfig:TIPConfig);
    procedure Clear;
    procedure LoadFromStream(MS:TMemoryStream);
    procedure SaveToStream(MS:TMemoryStream);
  published
    property AdapterName: string read FAdapterName write FAdapterName;
    property ConfigName: string read FConfigName write FConfigName;
    property DHCP: Boolean read FDHCP write FDHCP;
    property DNSServerList: TStringList read FDNSServerList write
        FDNSServerList;
    property GatewayList: TStringList read FGatewayList write FGatewayList;
    property IEDialSet: TIEDialSet read FIEDialSet write FIEDialSet;
    property IEProxySet: TIEProxySet read FIEProxySet write FIEProxySet;
    property IPList: TStringList read FIPList write FIPList;
    property NetBios: TNetBios read FNetBios write FNetBios;
    property SubMaskList: TStringList read FSubMaskList write FSubMaskList;
  end;

  TIPConfigList = class(TStringList)
  public
    destructor Destroy; override;
    procedure ClearObject;
    procedure LoadAllFromFile(AFileName:string);
    procedure SaveAllToFile(AFileName:string);
  end;

    // IP助手类，用来设定和显示IP地址
  TIPSetUtil = class(TObject)
  private
    FConnectionList: TConnectionList;
    FICMPUtil: TICMPUtil;
    FIPConfigList: TIPConfigList;
    FLocalMacList: TStringList;
    FOnProcess: TOnProcess;
    function GetAllIPConfig(AFileName:string = ''): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function AddIPConfig(_IPConfig:TIPConfig): Integer;
    function AutoSearch(AAdapterDest:string): Integer;
    procedure DelIPConfig(nIndex:Integer);
    function GetAdapterIndex(AAdapterName:string): Integer;
    procedure GetAllConnections(AComboBox:TComboBox);
    procedure GetAllIPConfigs(AListView:TListView; AFileName:string = '');
    procedure GetOrignalIP(var _IpConfig:TIPConfig);
    procedure Initilize;
    function IPConfigExist(_ConfigName:string): Integer;
    function ModifyIPConfig(nIndex:Integer; _IPConfig:TIPConfig): Integer;
    procedure SaveAllConfigs(AFileName:string = ''); overload;
    procedure SaveAllConfigs(AListView:TListView; bSaveToFile:Boolean = False;
        AFileName:string = ''); overload;
    function SaveOrignalConfig: Integer;
    function SetIPInfor(nIndex:Integer): Integer; overload;
    function SetIPInfor(_IPConfig:TIPConfig): Integer; overload;
  published
    property ICMPUtil: TICMPUtil read FICMPUtil;
    property OnProcess: TOnProcess read FOnProcess write FOnProcess;
  end;

implementation
uses
    Registry, uUtiles, IPHLPApi, uSysInfo;

{ TIPSetUtil }

{
********************************** TIPSetUtil **********************************
}
constructor TIPSetUtil.Create;
begin
  FConnectionList := TConnectionList.Create;
  FICMPUtil := TICMPUtil.Create;
  FIPConfigList := TIPConfigList.Create;
  FLocalMacList := TStringList.Create;
  Initilize;
end;

destructor TIPSetUtil.Destroy;
begin
  FLocalMacList.Free;
  FIPConfigList.Free;
  FICMPUtil.Free;
  FConnectionList.Free;
  inherited;
end;

function TIPSetUtil.AddIPConfig(_IPConfig:TIPConfig): Integer;
begin
  Result := -1;
  if not Assigned(_IPConfig) then Exit;
  Result := -2;
  // 重复了
  if FIPConfigList.IndexOf(_IPConfig.ConfigName) <> -1 then Exit;
  FIPConfigList.AddObject(_IPConfig.FConfigName, _IPConfig);
  Result := 0;
end;

function TIPSetUtil.AutoSearch(AAdapterDest:string): Integer;
var
  i, nPos: Integer;
  IPConfig: TIPConfig;
  AAdapterName: string;
  strIP: string;
  strTmp: string;
begin
  // 表示适配器不存在
  // 以后考虑dhcp只处理一次
  Result := -1;
  FConnectionList.GetAllConnectionsByReg;
  AAdapterName := FConnectionList.GetAdapterName(AAdapterDest);
  if not SysInfo.SystemInfo.wjwj_wjky__aaa then begin
      strTmp := SysInfo.GetMessage('NoRegStop');
      FOnProcess(strTmp, 100, True);
      Exit;
  end;
  if AAdapterName = '' then begin
      strTmp := SysInfo.GetMessage('NoSearchAdapter', '%s');
      strTmp := Format(strTmp, [AAdapterName]);
      FOnProcess(strTmp, 100, True);
      Exit;
  end;
  if FICMPUtil.PingIP(GetGatewayByIPHLP(AAdapterName)) > 0 then begin
      if Assigned(FOnProcess) then begin
          strTmp := SysInfo.GetMessage('OKIPNoSearch');
          FOnProcess(strTmp, 100, True);
      end;
      Exit;
  end;
  for i := 0 to FIPConfigList.Count - 1 do begin
      IPConfig := TIPConfig(FIPConfigList.Objects[i]);
      nPos := Round((I + 1) * 100 / FIPConfigList.Count);
      if Assigned(FOnProcess) then begin
          strTmp := SysInfo.GetMessage('PreApply', '%s');
          strTmp := Format(strTmp, [IPConfig.ConfigName]);
          FOnProcess(strTmp, nPos)
      end;

      if IPConfig.FAdapterName <> AAdapterName then begin
          if Assigned(FOnProcess) then begin
              strTmp := SysInfo.GetMessage('NoMatchAdapter', '%s');
              strTmp := Format(strTmp, [IPConfig.ConfigName]);
              FOnProcess(strTmp, nPos)
          end;
          Continue;
      end;

      if Assigned(FOnProcess) then begin
          strTmp := SysInfo.GetMessage('Appling', '%s');
          strTmp := Format(strTmp, [IPConfig.ConfigName]);
          FOnProcess(strTmp, nPos);
      end;

      if SetIPInfor(i) = 0 then begin
          if Assigned(FOnProcess) then begin
              strTmp := SysInfo.GetMessage('TestConfig', '%s');
              strTmp := Format(strTmp, [IPConfig.ConfigName]);
              FOnProcess(strTmp, nPos);
          end;
      end
      else begin
          if Assigned(FOnProcess) then begin
              strTmp := SysInfo.GetMessage('FailApply', '%s');
              strTmp := Format(strTmp, [IPConfig.ConfigName]);
              FOnProcess(strTmp, nPos);
          end;
      end;

      if IPConfig.DHCP then Sleep(5000) // dhcp要等个3m，给点面子
      else Sleep(2000);
      strIP := GetGatewayByIPHLP(AAdapterName);
      if (strIP = '') or (FICMPUtil.PingIP(strIP) <= 0) then begin
          if Assigned(FOnProcess) then begin
              strTmp := SysInfo.GetMessage('FailConnect', '%s');
              strTmp := Format(strTmp, [IPConfig.ConfigName]);
              FOnProcess(strTmp, nPos);
          end;
      end
      else begin
          if Assigned(FOnProcess) then begin
              strTmp := SysInfo.GetMessage('SuccConnect', '%s');
              strTmp := Format(strTmp, [IPConfig.ConfigName]);
              FOnProcess(strTmp, nPos, True);
          end;
          Break;
      end;
  end;

  Result := 0;
end;

procedure TIPSetUtil.DelIPConfig(nIndex:Integer);
var
  IP: TIPConfig;
begin
  if (nIndex < 0) or (nIndex > FIPConfigList.Count - 1) then Exit;
  IP := TIPConfig(FIPConfigList.Objects[nIndex]);
  IP.Free;
  FIPConfigList.Delete(nIndex);
end;

function TIPSetUtil.GetAdapterIndex(AAdapterName:string): Integer;
begin
  Result := FConnectionList.GetAdapertIndex(AAdapterName);
end;

procedure TIPSetUtil.GetAllConnections(AComboBox:TComboBox);
begin
  FConnectionList.GetAllConnections(AComboBox);
end;

function TIPSetUtil.GetAllIPConfig(AFileName:string = ''): Integer;
begin
  Result := -1;
  if not FileExists(AFileName) then Exit;

  FIPConfigList.LoadAllFromFile(AFileName);
  Result := 0;
end;

procedure TIPSetUtil.GetAllIPConfigs(AListView:TListView; AFileName:string =
    '');
var
  I: Integer;
  Item: TListItem;
  IP: TIPConfig;
begin
  if not Assigned(AListView) then Exit;
  AListView.Clear;

  if not FileExists(AFileName) then Exit;

  for i := 0 to FIPConfigList.Count - 1 do begin
      IP := TIPConfig(FIPConfigList.Objects[i]);
      Item := AListView.Items.Add;
      Item.Caption := IP.ConfigName;
      if IP.IPList.Count > 0 then
          Item.SubItems.Add(IP.IPList.Strings[0])
      else Item.SubItems.Add('');

      if IP.SubMaskList.Count > 0 then
          Item.SubItems.Add(IP.SubMaskList.Strings[0])
      else Item.SubItems.Add('');

      if IP.GatewayList.Count > 0 then
          Item.SubItems.Add(IP.GatewayList.Strings[0])
      else Item.SubItems.Add('');

      if IP.DNSServerList.Count > 0 then
          Item.SubItems.Add(IP.DNSServerList.Strings[0])
      else Item.SubItems.Add('');

      if IP.DNSServerList.Count > 1 then
          Item.SubItems.Add(IP.DNSServerList.Strings[1])
      else Item.SubItems.Add('');

      Item.Data := IP;
  end;
end;

procedure TIPSetUtil.GetOrignalIP(var _IpConfig:TIPConfig);

  const
      AddrLen = 6;
  var
      PAdapterInfo:PTIP_ADAPTER_INFO;
      ret:DWORD;
      Next:PTIP_ADAPTER_INFO;
      OutBufLen:ULONG;
      pAddrStr:PIP_ADDR_STRING;
      pFixedInfo:PFIXED_INFO;
      I:Integer;
      FMAC:string;

begin
  /// 获得适配器信息
  if not Assigned(_IpConfig) then Exit;
  OutBufLen := SizeOf(PAdapterInfo^);
  GetAdaptersInfo(nil, @OutBufLen); // to get the required size
  PAdapterInfo := AllocMem(OutBufLen);
  ret := GetAdaptersInfo(PAdapterInfo, @OutBufLen);
  FLocalMacList.Clear;
  _IpConfig.Clear;
  if ret = 0 then begin
      Next := PAdapterInfo;
      repeat

          FMAC := '';
          for i := 0 to AddrLen do begin
              FMac := FMac + IntToHex(Next^.Address[i], 2);
              if i <> AddrLen then FMac := FMac + '-';
          end;
          FLocalMacList.Add(FMac);
          with _IpConfig do begin
              IPList.Add(Next^.IPAddressList.IpAddress);
              SubMaskList.Add(Next^.IPAddressList.IpMask);
              GatewayList.Add(Next^.GatewayList.IpAddress);
              if Next^.PrimaryWINSServer.IpAddress <> '' then
                  FNetBios.NameServerList.Add(Next^.PrimaryWINSServer.IpAddress);
              if Next^.SecondaryWINSServer.IpAddress <> '' then
                  FNetBios.NameServerList.Add(Next^.SecondaryWINSServer.IpAddress);
              DHCP := Boolean(Next^.DHCPEnabled);
          end;
          Next := Next^.Next;
      until Next = nil;
  end;
  FreeMem(PAdapterInfo, OutBufLen);

  // 获得DNS信息
  OutBufLen := SizeOf(pFixedInfo^);
  GetNetworkParams(nil, OutBufLen);
  pFixedInfo := AllocMem(OutBufLen);
  ret := GetNetworkParams(pFixedInfo, OutBufLen);
  if ret = 0 then begin
      with _IpConfig.DNSServerList do begin
          Add(pFixedInfo^.DnsServerList.IpAddress.S);
          pAddrStr := pFixedInfo^.DnsServerList.Next;
          while Assigned(pAddrStr) do begin
              Add(pAddrStr^.IpAddress.S);
              pAddrStr := pAddrStr^.Next;
          end;
      end;
      FreeMem(pFixedInfo, OutBufLen);
  end;
  //ImageList.Handle := FDeviceUtil.ImageListHandle;
end;

procedure TIPSetUtil.Initilize;
begin
  GetAllIPConfig(GetIPConfigName());
  SaveOrignalConfig;
end;

function TIPSetUtil.IPConfigExist(_ConfigName:string): Integer;
begin
  Result := FIPConfigList.IndexOf(_ConfigName);
end;

function TIPSetUtil.ModifyIPConfig(nIndex:Integer; _IPConfig:TIPConfig):
    Integer;
var
  IP: TIPConfig;
  nPos: Integer;
begin
  Result := -1;
  if not Assigned(_IPConfig) then Exit;
  Result := -2;
  if (nIndex < 0) or (nIndex > FIPConfigList.Count - 1) then Exit;
  Result := -3;
  // 重复了
  nPos := IPConfigExist(_IPConfig.ConfigName);
  if (nPos <> -1) and (nPos <> nIndex) then Exit;
  IP := TIPConfig(FIPConfigList.Objects[nIndex]);
  Result := -4;
  if not Assigned(IP) then Exit;
  IP.Assign(_IPConfig);
  Result := 0;
end;

procedure TIPSetUtil.SaveAllConfigs(AFileName:string = '');
begin
  FIPConfigList.SaveAllToFile(AFileName);
end;

procedure TIPSetUtil.SaveAllConfigs(AListView:TListView; bSaveToFile:Boolean =
    False; AFileName:string = '');
var
  i: Integer;
  _IPConfig: TIPConfig;
begin
  for i := 0 to AListView.Items.Count - 1 do begin
      _IPConfig := TIPConfig(FIPConfigList.Objects[i]);
      _IPConfig.ConfigName := AListView.Items.Item[i].Caption;
      FIPConfigList.Strings[i] := _IPConfig.ConfigName
  end;
  if bSaveToFile then
      SaveAllConfigs(AFileName);
end;

function TIPSetUtil.SaveOrignalConfig: Integer;
var
  _IP: TIPConfig;
  _Connection: TConnection;
  i: Integer;
begin
  // 保存原始配置，第一次运行时，如果配置文件不存在，则自动创建
  // 表示文件已经存在
  Result := -1;
  if GetAllIPConfig(GetIPConfigName) <> -1 then Exit;

  FConnectionList.GetAllConnectionsByReg;

  // 保存到对象
  for i := 0 to FConnectionList.Count - 1 do begin
      _IP := TIPConfig.Create;
      _Connection := TConnection(FConnectionList.Objects[i]);
      _IP.Assign(_Connection.IPConfig);
      _IP.ConfigName := _Connection.ConnectionName;
      // 装了VPN的客户端，居然没有连接，所以没办法了，
      if _Connection.ConnectionName = '' then
          _IP.ConfigName := FormatDateTime('mmddhhnnss', now);
      _IP.AdapterName := _Connection.AdapterName;
      AddIPConfig(_IP);
  end;

  // 保存到文件
  SaveAllConfigs(GetIPConfigName);
end;

function TIPSetUtil.SetIPInfor(nIndex:Integer): Integer;
var
  IPConfig: TIPConfig;
begin
  Result := -100;
  if (nIndex < 0) or (nIndex > FIPConfigList.Count) then Exit;
  IPConfig := TIPConfig(FIPConfigList.Objects[nIndex]);
  Result := SetIPInfor(IPConfig);
end;

function TIPSetUtil.SetIPInfor(_IPConfig:TIPConfig): Integer;
var
  nRet: Integer;
begin
  Result := -1;
  if not Assigned(_IPConfig) then Exit;
  OutputDebugInfo('SetIPInfor');
  Result := _IPConfig.Apply;

  OutputDebugInfo('IPConfig.Apply');

  if Result = 0 then begin
      nRet := FConnectionList.RestartConnection(_IPConfig.AdapterName); // SetupAPI方式
      OutputDebugInfo('RestartConnection');
      if nRet <> 0 then Exit
      else Result := nRet;
  end;
end;

{ TIPConfigList }

{
******************************** TIPConfigList *********************************
}
destructor TIPConfigList.Destroy;
begin
  ClearObject;
  inherited;
end;

procedure TIPConfigList.ClearObject;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do begin
      TIPConfig(Objects[i]).Free;
  end;
  Clear;
end;

procedure TIPConfigList.LoadAllFromFile(AFileName:string);
var
  i: Integer;
  nCount, nSize: Integer;
  MS: TMemoryStream;
  strTmp: string;
  obj: TIPConfig;
begin
  // 文件不存在
  if not FileExists(AFileName) then Exit;
  MS := TMemoryStream.Create;
  try
      MS.LoadFromFile(AFileName);
      SetLength(strTmp, Length(FileHeader));
      MS.Read(strTmp[1], Length(FileHeader));
      // 文件头错误
      if strTmp <> FileHeader then Exit;
      MS.Seek(-sizeof(Integer), soFromEnd);
      MS.Read(nSize, sizeof(nSize));
      // 文件大小错误
      if (nSize <> MS.Size - sizeof(Integer)) then Exit;
      MS.Position := Length(FileHeader);
      MS.Read(nCount, sizeof(nCount));
      ClearObject;
      for i := 0 to nCount - 1 do begin
          obj := TIPConfig.Create;
          obj.LoadFromStream(MS);
          Self.AddObject(obj.FConfigName, obj);
      end;
  finally
      MS.Free;
  end;
end;

procedure TIPConfigList.SaveAllToFile(AFileName:string);
var
  i: Integer;
  nCount, nSize: Integer;
  MS: TMemoryStream;
begin
  MS := TMemoryStream.Create;
  try
      MS.Write(FileHeader[1], Length(FileHeader));
      nCount := Count;
      MS.Write(nCount, sizeof(nCount));
      for i := 0 to nCount - 1 do
          TIPConfig(self.Objects[i]).SaveToStream(MS);
      nSize := MS.Size;
      MS.Write(nSize, sizeof(nSize));
      MS.SaveToFile(AFileName);
  finally
      MS.Free;
  end;
end;

{ TIPConfig }

{
********************************** TIPConfig ***********************************
}
constructor TIPConfig.Create;
begin
  FIEProxySet := TIEProxySet.Create;
  FNetBios := TNetBios.Create;
  FIPList := TStringList.Create;
  FSubMaskList := TStringList.Create;
  FGatewayList := TStringList.Create;
  FDNSServerList := TStringList.Create;
  FIEDialSet := TIEDialSet.Create;
end;

destructor TIPConfig.Destroy;
begin
  FIEDialSet.Free;
  FDNSServerList.Free;
  FGatewayList.Free;
  FSubMaskList.Free;
  FIPList.Free;

  FNetBios.Free;
  FIEProxySet.Free;
  inherited;
end;

function TIPConfig.Apply: Integer;
var
  FReg: TRegistry;
  KeyName: string;
  strTemp: string;
begin
  FReg := TRegistry.Create;
  try

      OutputDebugInfo('Apply');
      FReg.RootKey := HKEY_LOCAL_MACHINE;
      Result := -2;
      if not FReg.OpenKeyReadOnly(TCPIPROOTKEY) then Exit;

      OutputDebugInfo('TCPIPROOTKEY');
      Result := -3;
      if not FReg.OpenKeyReadOnly(FAdapterName) then Exit;

      OutputDebugInfo('FAdapterName');
      KeyName := TCPIPROOTKEY + FAdapterName;

      RegSetDword(HKEY_LOCAL_MACHINE, KeyName + '\EnableDHCP', Integer(FDHCP));
      if not FDHCP then begin
          RegSetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\IPAddress', StringsToStr(FIPList));

          OutputDebugInfo(PChar(KeyName + '\IPAddress'));
          OutputDebugInfo(PChar(StringsToStr(FIPList)));
          RegSetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\DefaultGateway', StringsToStr(FGatewayList));
          RegSetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\SubnetMask', StringsToStr(FSubMaskList));
      end
      else begin
          RegSetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\IPAddress', '0.0.0.0');
          RegSetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\DefaultGateway', '');
          RegSetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\SubnetMask', '0.0.0.0');
      end;

      OutputDebugInfo('DHCP');
      FDNSServerList.Delimiter := ',';
      strTemp := FDNSServerList.DelimitedText;
      if (strTemp <> '') and (strTemp[Length(strTemp)] = ',') then Delete(strTemp, Length(strTemp), 1);
      RegSetString(HKEY_LOCAL_MACHINE, KeyName + '\NameServer', strTemp);

      OutputDebugInfo('DNSServerList');
      FIEProxySet.Apply;

      OutputDebugInfo('FIEProxySet');
      FIEDialSet.Apply;

      OutputDebugInfo('FIEDialSet');
      FNetBios.Apply(FAdapterName);

      OutputDebugInfo('FNetBios');
      Result := 0;
  finally
      FReg.CloseKey;
      FReg.Free;
  end;
end;

procedure TIPConfig.Assign(AIPConfig:TIPConfig);
begin
  // IP设置
  Self.FConfigName := AIPConfig.FConfigName;
  Self.FAdapterName := AIPConfig.FAdapterName;
  Self.FIPList.Assign(AIPConfig.FIPList);
  Self.FSubMaskList.Assign(AIPConfig.FSubMaskList);
  Self.FGatewayList.Assign(AIPConfig.FGatewayList);
  Self.FDNSServerList.Assign(AIPConfig.FDNSServerList);
  Self.FIEProxySet.Assign(AIPConfig.FIEProxySet);
  Self.FIEDialSet.Assign(AIPConfig.FIEDialSet);
  Self.FNetBios.Assign(AIPConfig.FNetBios);
  Self.FDHCP := AIPConfig.FDHCP;
end;

procedure TIPConfig.Clear;
begin
  // 清空
  FConfigName := '';
  FIPList.Clear;
  FSubMaskList.Clear;
  FGatewayList.Clear;
  FDNSServerList.Clear;
  FNetBios.NameServerList.Clear;
end;

procedure TIPConfig.LoadFromStream(MS:TMemoryStream);
begin
  // 从文件读取IP信息
  if not Assigned(MS) then Exit;
  LoadStringFromMS(MS, FConfigName);
  LoadStringFromMS(MS, FAdapterName);
  LoadStringListFromMS(MS, FIPList);
  LoadStringListFromMS(MS, FSubMaskList);
  LoadStringListFromMS(MS, FGatewayList);
  LoadStringListFromMS(MS, FDNSServerList);
  MS.Read(FDHCP, sizeof(FDHCP));

  FIEProxySet.LoadFromStream(MS);

  FIEDialSet.LoadFromStream(MS);

  FNetBios.LoadFromStream(MS);
end;

procedure TIPConfig.SaveToStream(MS:TMemoryStream);
begin
  // 保存IP配置到文件
  if not Assigned(MS) then Exit;

  SaveStringToMS(MS, FConfigName);
  SaveStringToMS(MS, FAdapterName);
  SaveStringListToMS(MS, FIPList);
  SaveStringListToMS(MS, FSubMaskList);
  SaveStringListToMS(MS, FGatewayList);
  SaveStringListToMS(MS, FDNSServerList);
  MS.Write(FDHCP, sizeof(FDHCP));

  FIEProxySet.SaveToStream(MS);

  FIEDialSet.SaveToStream(MS);

  FNetBios.SaveToStream(MS);
end;

{ TIEProxySet }

{
********************************* TIEProxySet **********************************
}
constructor TIEProxySet.Create;
begin
  FEnabled := False;
  FProxyEnable := 0;
  FProxyServer := '';
  FProxyOverride := '*';
end;

procedure TIEProxySet.Apply;
begin
  { 　　
      "ProxyEnable"=dword:00000001    // 1是启用，0为不启用
  　　"ProxyServer"="*.*.*.*:*"       // 代理服务器地址端口，如果多个，则按分号分隔，如
                                      "ProxyServer"="ftp=*.*.*.*:*;gopher=*.*.*.*:*;http=*.*.*.*:*"
      "ProxyOverride"=""              // 指不使用代理服务器的IP段，或者域名段，可以用*代表任意长字符串
                                      对应的是“局域网（LAN）设置”对话框下的“对于本地地址不
  }
  if not FEnabled then Exit;

  RegSetDword(HKEY_CURRENT_USER, IEROOTKEY + '\ProxyEnable', FProxyEnable);
  RegSetString(HKEY_CURRENT_USER, IEROOTKEY + '\ProxyServer', FProxyServer);
  RegSetString(HKEY_CURRENT_USER, IEROOTKEY + '\ProxyOverride', FProxyOverride);
end;

procedure TIEProxySet.Assign(AIEProxySet:TIEProxySet);
begin
  FProxyEnable := AIEProxySet.ProxyEnable;
  FProxyServer := AIEProxySet.ProxyServer;
  FProxyOverride := AIEProxySet.ProxyOverride;
  FProxyPort := AIEProxySet.ProxyPort;
  FEnabled := AIEProxySet.Enabled;
end;

procedure TIEProxySet.LoadFromStream(MS:TMemoryStream);
begin
  if not Assigned(MS) then Exit;

  MS.Read(FProxyEnable, sizeof(DWORD));
  LoadStringFromMS(MS, FProxyServer);
  LoadStringFromMS(MS, FProxyOverride);
  MS.Read(FProxyPort, sizeof(FProxyPort));
  MS.Read(FEnabled, sizeof(Boolean));
end;

procedure TIEProxySet.SaveToStream(MS:TMemoryStream);
begin
  if not Assigned(MS) then Exit;

  MS.Write(FProxyEnable, sizeof(DWORD));
  SaveStringToMS(MS, FProxyServer);
  SaveStringToMS(MS, FProxyOverride);
  MS.Write(FProxyPort, sizeof(FProxyPort));
  MS.Write(FEnabled, sizeof(Boolean));
end;

{ TNetBios }

{
*********************************** TNetBIOS ***********************************
}
constructor TNetBIOS.Create;
begin
  NameServerList := TStringList.Create;
end;

destructor TNetBIOS.Destroy;
begin
  NameServerList.Free;
  inherited;
end;

procedure TNetBIOS.Apply(AAdapter:string);
begin
  if not FEnabled then Exit;

  RegSetDword(HKEY_LOCAL_MACHINE, NETBIOSROOTKEY + AAdapter + '\NetbiosOptions', FNetbiosOptions);
  RegSetMultiString(HKEY_LOCAL_MACHINE, NETBIOSROOTKEY + AAdapter, StringsToStr(FNameServerList));
end;

procedure TNetBIOS.Assign(ANetBios:TNetBios);
begin
  FNetbiosOptions := ANetBios.NetbiosOptions;
  FNameServerList.Assign(ANetBios.NameServerList);
  FEnabled := ANetBios.Enabled;
end;

procedure TNetBIOS.LoadFromStream(MS:TMemoryStream);
begin
  if not Assigned(MS) then Exit;
  MS.Read(FNetbiosOptions, sizeof(DWORD));
  LoadStringListFromMS(MS, FNameServerList);
  MS.Read(FEnabled, sizeof(Boolean));
end;

procedure TNetBIOS.SaveToStream(MS:TMemoryStream);
begin
  if not Assigned(MS) then Exit;

  MS.Write(FNetbiosOptions, sizeof(DWORD));
  SaveStringListToMS(MS, FNameServerList);
  MS.Write(FEnabled, sizeof(Boolean));
end;

{ TConnectionList }

{
******************************* TConnectionList ********************************
}
constructor TConnectionList.Create;
begin
  FDeviceUtil := TDevInforUtil.Create;
end;

destructor TConnectionList.Destroy;
begin
  FDeviceUtil.Free;
  ClearObject();
  inherited;
end;

procedure TConnectionList.ClearObject;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do begin
      TConnection(Objects[i]).Free;
  end;
  Clear;
end;

function TConnectionList.GetAdapertIndex(AAdapterName:string): Integer;
var
  i: Integer;
  obj: TConnection;
begin
  Result := -1;
  for i := 0 to Self.Count - 1 do begin
      obj := TConnection(Self.Objects[i]);
      // 在2003系统需要加trim，不知道为什么取出来是空的
      if Trim(obj.FAdapterName) = Trim(AAdapterName) then begin
          Result := I;
          Exit;
      end;
  end;
end;

function TConnectionList.GetAdapterName(AAdapterDest:string): string;
var
  i: Integer;
  obj: TConnection;
begin
  Result := '';

  // 传入适配器描述 获取适配器名称
  for i := 0 to Self.Count - 1 do begin
      obj := TConnection(Self.Objects[i]);
      // 在2003系统需要加trim，不知道为什么取出来是空的
      if Trim(obj.FAdapterDescription) = Trim(AAdapterDest) then begin
          Result := Trim(obj.FAdapterName);
          Exit;
      end;
  end;

end;

procedure TConnectionList.GetAllConnections(AComboBox:TComboBox);
var
  I: Integer;
  Connection: TConnection;
begin
  GetAllConnectionsByReg;

  AComboBox.Items.Clear;
  for I := 0 to Self.Count - 1 do begin
      Connection := TConnection(self.Objects[i]);
      AComboBox.Items.AddObject(Connection.AdapterDescription, Connection);
  end;
end;

procedure TConnectionList.GetAllConnectionsByReg;
var
  FReg: TRegistry;
  slKeys: TStringList;
  I: Integer;
  Connection: TConnection;
begin
  // 通过注册表读取适配器
  ClearObject;
  FReg := TRegistry.Create;
  slKeys := TStringList.Create;
  try
      FReg.RootKey := HKEY_LOCAL_MACHINE;

      if not FReg.OpenKeyReadOnly(NETCARDROOT) then Exit;

      FReg.GetKeyNames(slKeys);
      for i := 0 to slKeys.Count - 1 do begin
          FReg.CloseKey;
          if not FReg.OpenKeyReadOnly(NETCARDROOT + slKeys[i]) then Continue;
          if not FReg.OpenKeyReadOnly('Ndi\Interfaces') then Continue;
          // 无线网卡还多个东西wifimon
          // vmware这些鸟东西是ndis5的，我kao
          OutputDebugInfo(PChar(FReg.ReadString('LowerRange')));
          OutputDebugInfo(PChar(FReg.ReadString('UpperRange')));
          if (Pos('ethernet', FReg.ReadString('LowerRange')) = 0) and
              (Pos('ndis5', FReg.ReadString('UpperRange')) = 0)
               then continue;

          FReg.CloseKey;
          if not FReg.OpenKeyReadOnly(NETCARDROOT + slKeys[i]) then Continue;
          // 通过设备来过滤
          if FDeviceUtil.DevList.IndexOf(FReg.ReadString('DriverDesc')) = -1 then Exit;
          Connection := TConnection.Create(FDeviceUtil);
          with Connection do begin
              AdapterName := FReg.ReadString('NetCfgInstanceId');
              AdapterDescription := FReg.ReadString('DriverDesc'); // 这里会有一个 -
              ConnectionName := GetConnection(AdapterName);
              RefershStat;
              RefreshIPConfig;
              Self.AddObject(AdapterName, Connection);
          end;
      end;
  finally
      slKeys.Free;
      FReg.Free;
  end;
end;

function TConnectionList.GetConnection(AAdapterName:string): string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create;
  try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if not Reg.OpenKeyReadOnly(NETWORKROOTKEY) then Exit;
      if not Reg.OpenKeyReadOnly(AAdapterName) then Exit;
      if not Reg.OpenKeyReadOnly('Connection') then Exit;
      Result := Reg.ReadString('Name');
      Reg.CloseKey;
  finally
      Reg.Free;
  end;
end;

function TConnectionList.RestartConnection(AAdapterName:string): Integer;
var
  obj: TConnection;
begin
  Result := -100;
  try
      obj := TConnection(Self.Objects[GetAdapertIndex(AAdapterName)]);
      Result := obj.Restart;
  except
  end;
end;

{ TConnection }

{
********************************* TConnection **********************************
}
constructor TConnection.Create(ADeviceUtil:TDevInforUtil);
begin
  FIPConfig := TIPConfig.Create;
  FDeviceUtil := ADeviceUtil;
end;

destructor TConnection.Destroy;
begin
  FIPConfig.Free;
  inherited;
end;

function TConnection.GetDeviceStat: Integer;
begin
  // 设备状态， 1为可用，2为不可以，0为状态未知
  Result := Ord(dsNone);
  case FDeviceUtil.GetDeviceState(FAdapterDescription) of
      2:Result := Ord(dsDisabled);
      3:Result := Ord(dsEnabled);
  end;
end;

function TConnection.GetImageIndex: Integer;
begin
  // 0 是可用，1是不可用
  case Stat of
      1:Result := 0;
  else
      Result := 1;
  end;
end;

procedure TConnection.RefershStat;
begin
  // 更新状态
  FStat := GetDeviceStat;
  FImageIndex := GetImageIndex;
end;

function TConnection.RefreshIPConfig: Integer;
var
  FReg: TRegistry;
  KeyName: string;
  strIP, strSubnetMask, strGateway, strDNS: string;
  nDHCP: Cardinal;
begin
  // 刷新IP地址，从注册表读取
  FReg := TRegistry.Create;
  try
      FReg.RootKey := HKEY_LOCAL_MACHINE;
      Result := -2;
      if not FReg.OpenKeyReadOnly(TCPIPROOTKEY) then Exit;
      Result := -3;
      if not FReg.OpenKeyReadOnly(FAdapterName) then Exit;

      KeyName := TCPIPROOTKEY + FAdapterName;

      RegGetDWORD(HKEY_LOCAL_MACHINE, KeyName + '\EnableDHCP', nDHCP);
      if nDHCP = 0 then begin
          RegGetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\IPAddress', strIP);
          RegGetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\DefaultGateway', strGateway);
          RegGetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\SubnetMask', strSubnetMask);
      end
      else begin
          // 注意这里只有网关是Multi
          RegGetString(HKEY_LOCAL_MACHINE, KeyName + '\DhcpIPAddress', strIP);
          RegGetMultiString(HKEY_LOCAL_MACHINE, KeyName + '\DhcpDefaultGateway', strGateway);
          RegGetString(HKEY_LOCAL_MACHINE, KeyName + '\DhcpSubnetMask', strSubnetMask);
      end;

      RegGetString(HKEY_LOCAL_MACHINE, KeyName + '\NameServer', strDNS);
      with FIPConfig do begin
          FDHCP := (nDHCP = 1);
          StrToStrings(strIP, IPList);
          StrToStrings(strSubnetMask, SubMaskList);
          StrToStrings(strGateway, GatewayList);
          StrToStrings(strDNS, DNSServerList, ',');
      end;

      Result := 0;
  finally
      FReg.CloseKey;
      FReg.Free;
  end;
end;

function TConnection.Restart: Integer;
begin
  Result := FDeviceUtil.RestartDevice(Trim(FAdapterDescription));
end;

procedure TConnection.SetDeviceStat(const Value: Integer);
begin
  FDeviceUtil.SetDeviceState(FAdapterDescription, TDeviceStat(Value));
end;

{ TIEDialSet }

{
********************************** TIEDialSet **********************************
}
constructor TIEDialSet.Create;
begin
  FConnectionList := TStringList.Create;
  GetConnectionList;
end;

destructor TIEDialSet.Destroy;
begin
  FConnectionList.Free;
  inherited;
end;

procedure TIEDialSet.Apply;
begin
  if not FEnabled then Exit;
  {
      完整的对应关系:在"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"下
      EnableAutodial=0   且NoNetAutodial=0是"从不进行拨号连接"
      EnableAutodial=1   且NoNetAutodial=1是"无论网络连接是否存在都拨号"
      EnableAutodial=1   且NoNetAutodial=0是"始终拨默认连接"
  }

  case FDialSet of
      0:begin
              RegSetDword(HKEY_CURRENT_USER, IEROOTKEY + '\EnableAutodial', 0);
              RegSetDword(HKEY_CURRENT_USER, IEROOTKEY + '\NoNetAutodial', 0);
          end;
      1:begin
              RegSetDword(HKEY_CURRENT_USER, IEROOTKEY + '\EnableAutodial', 1);
              RegSetDword(HKEY_CURRENT_USER, IEROOTKEY + '\NoNetAutodial', 1);
          end;
      2:begin
              RegSetDword(HKEY_CURRENT_USER, IEROOTKEY + '\EnableAutodial', 1);
              RegSetDword(HKEY_CURRENT_USER, IEROOTKEY + '\NoNetAutodial', 0);
          end;
  end;
end;

procedure TIEDialSet.Assign(AIEDialSet:TIEDialSet);
begin
  FEnabled := AIEDialSet.Enabled;
  FDialSet := AIEDialSet.DialSet;
end;

procedure TIEDialSet.GetConnectionList;
var
  FReg: TRegistry;
  i: Integer;
begin
  { 　　
      "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RAS AutoDial\Default   默认拨号
      HKEY_CURRENT_USER\Soft ware\Microsoft\Windows\CurrentVersion\ Internet Settings\Connections
      下面除SavedLegacySettings  // DefaultConnectionSettings 外所有连接
  }
  FReg := TRegistry.Create;
  try
      // 取当前所有连接
      FReg.RootKey := HKEY_CURRENT_USER;
      if not FReg.OpenKeyReadOnly(IEROOTKEY + '\Connections') then Exit;
      FReg.GetValueNames(FConnectionList);
      for i := FConnectionList.Count - 1 downto 0 do begin
          if FConnectionList.Strings[i] = 'SavedLegacySettings' then begin
              FConnectionList.Delete(i);
              Continue;
          end;
          if FConnectionList.Strings[i] = 'DefaultConnectionSettings' then begin
              FConnectionList.Delete(i);
              Continue;
          end;
      end;

      // 取当前默认连接
      if FConnectionList.Count = 0 then Exit;
      FReg.CloseKey;
      FReg.RootKey := HKEY_LOCAL_MACHINE;
      if not FReg.OpenKeyReadOnly(DEFAULTDIALROOTKEY) then Exit;
      if not FReg.ValueExists('DefaultInternet') then Exit;
      FDefaultConnection := FReg.ReadString('DefaultInternet');
  finally
      FReg.CloseKey;
      FReg.Free;
  end;
end;

procedure TIEDialSet.LoadFromStream(MS:TMemoryStream);
begin
  MS.Read(FDialSet, sizeof(Integer));
  MS.Read(FEnabled, sizeof(Boolean));
end;

procedure TIEDialSet.SaveToStream(MS:TMemoryStream);
begin
  if not Assigned(MS) then Exit;

  MS.Write(FDialSet, sizeof(Integer));
  MS.Write(FEnabled, sizeof(Boolean));
end;

end.

