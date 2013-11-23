unit uUtiles;

interface

uses
    ComCtrls, Messages, Windows, Classes, Forms;
{$DEFINE DEBUG1}
const
    FILEORIGINALSIZE:Integer = 443904; // 原始大小
    FILECREATETIME:string = '2007-05-27'; // 原始创建日期
type
    ShortcutType = (ST_DESKTOP, ST_SENDTO, ST_QUICKLAUNCH, ST_STARTMENU); // 定义一个数据类型，表示快捷方式位置

    // Listview排序
procedure MoveListViewSelection(L:TListView; nDir:integer);
// 扁平化listview头
procedure FlatListViewHeader(AListView:TCustomListView);
// 取得配置文件名
function GetIPConfigName(ExName:string = ''):string;
// Windows 版本信息
function GetVersionInfo(var SProduct, SVersion, SServicePack:string):BOOL;
// 取得文件版本
procedure GetBuildInfo(var V1, V2, V3, V4:Word);
// 创建快捷方式
procedure CreateShortcut(FileName:string; Description:string; arguements:string; LinkName:string = ''; Location:ShortcutType = ST_DESKTOP);
// 指定适配器的网关地址
function GetGatewayByIPHLP(AAdapterName:string):string;
// 指定两个IP是否在同一网段
function InSameSegment(AIP1, AIP2:string):Integer;
// 输出调试信息
procedure OutputDebugInfo(ADebugInfo:string);
// 隐藏气泡
procedure HideBalloonTip;
// 发送邮件
function SendMail(AAddress, ASubject:string; ABody:TStringList):Boolean;

////////////////////  防破解部分 ///////////////////////
// 检查父进程
procedure CheckParentProc;
// 根据进程ID,杀死进程
function KillProcess(pid:THandle):Boolean;
// 获得提示对话框
function GetConfirmHandle:THandle;

////////////////////////////////////////////////////

//////////////////////// 文件保存部分 /////////////////////////////////
procedure SaveStringToMS(MS:TMemoryStream; const str:string);
procedure LoadStringFromMS(MS:TMemoryStream; var str:string);

procedure SaveStringListToMS(MS:TMemoryStream; StringList:TStringList);
procedure LoadStringListFromMS(MS:TMemoryStream; StringList:TStringList);
///////////////////////////////////////////////////////////////////////
//////////////////////// 注册表部分 //////////////////////////
function LastPos(Needle:Char; Haystack:string):integer;
function RegGetValue(RootKey:HKEY; Name:string; ValType:Cardinal; var PVal:Pointer; var ValSize:Cardinal):boolean;
function RegSetValue(RootKey:HKEY; Name:string; ValType:Cardinal; PVal:Pointer; ValSize:Cardinal):boolean;

function RegSetString(RootKey:HKEY; Name:string; Value:string):boolean;
function RegGetString(RootKey:HKEY; Name:string; var Value:string):boolean;

function RegGetDWORD(RootKey:HKEY; Name:string; var Value:Cardinal):boolean;
function RegSetDword(RootKey:HKEY; Name:string; Value:Cardinal):boolean;

function RegSetMultiString(RootKey:HKEY; Name:string; Value:string):boolean;
function RegGetMultiString(RootKey:HKEY; Name:string; var Value:string):boolean;
function StringsToStr(Strings:TStrings; Delimiter:Char = #0):string;
procedure StrToStrings(str:string; Strings:TStringList; Delimiter:Char = #0);
//////////////////////////////////////////////////////////////
//////////////////
//////////////////////// api 部分 ////////////////////////////
function inet_addr(const cp:PChar):DWord; stdcall; external 'WS2_32.DLL' name 'inet_addr';

//////////////////////////////////////////////////////////////
type
    DHCPNOTIFYPROC = function(p1:PWideChar; p2:PWideChar; p3:BOOL; p4, p5, p6:dword; p7:Integer):Integer;
    {LPWSTR lpwszServerName, // 本地机器为NULL
LPWSTR lpwszAdapterName, // 适配器名称
BOOL bNewIpAddress, // TRUE表示更改IP
DWORD dwIpIndex, // 指明第几个IP地址,如果只有该接口只有一个IP地址则为0
DWORD dwIpAddress, // IP地址
DWORD dwSubNetMask, // 子网掩码
int nDhcpAction ); // 对DHCP的操作 0:不修改, 1:启用 DHCP,2:禁用 DHCP
}

implementation
uses
    SysUtils, TlHelp32, IPHlpapi,
    // 快捷方式
    Activex, ComObj, ShlObj,
    // 发送邮件
    ShellAPI
    ;

procedure MoveListViewSelection(L:TListView; nDir:integer);
var
    I:integer;
    nPos:integer;
    newItem:TListItem;
begin
    case nDir of
        1:begin
                //To top
                nPos := 0;
                for I := 0 to L.Items.Count - 1 do begin
                    if L.Items[I].Selected then begin
                        if (I = 0) then Inc(nPos);
                        if (I <> 0) and (not L.Items[I - 1].Selected) then begin
                            (L.Items.Insert(nPos)).Assign(L.Items[I]);
                            L.Items.Item[nPos].Selected := True; //保持选中的状态
                            L.Items.Delete(I + 1);
                            Inc(nPos);
                        end;
                    end
                end;
            end;
        2:begin // to prev
                for I := 0 to L.Items.Count - 1 do begin
                    if L.Items[I].Selected then begin
                        if (I <> 0) and (not L.Items[I - 1].Selected) then begin
                            newItem := TListItem.Create(L.Items);
                            newItem.Assign(L.Items[I]);
                            L.Items[I].Assign(L.Items[I - 1]);
                            L.Items[I - 1].Assign(newItem);
                            L.Items[I - 1].Selected := True; //保持选中的状态
                            FreeAndNil(newItem);
                        end;
                    end
                end;
            end;
        3:begin //to next
                for I := L.Items.Count - 1 downto 0 do begin
                    if L.Items[I].Selected then begin
                        if (I <> L.Items.Count - 1) and (not L.Items[I + 1].Selected) then begin
                            newItem := TListItem.Create(L.Items);
                            newItem.Assign(L.Items[I]);
                            L.Items[I].Assign(L.Items[I + 1]);
                            L.Items[I + 1].Assign(newItem);
                            L.Items[I + 1].Selected := True; //保持选中的状态
                            FreeAndNil(newItem);
                        end;
                    end
                end;
            end;
        4:begin
                //To bottom
                nPos := L.Items.Count - 1;
                for I := L.Items.Count - 1 downto 0 do begin
                    if L.Items[I].Selected then begin
                        if (I = L.Items.Count - 1) then Dec(nPos);
                        if (I <> L.Items.Count - 1) and (not L.Items[I + 1].Selected) then begin
                            if nPos = L.Items.Count - 1 then begin
                                (L.Items.Add).Assign(L.Items[I]);
                                L.Items.Item[L.Items.Count - 1].Selected := True; //保持选中的状态
                            end
                            else begin
                                (L.Items.Insert(nPos + 1)).Assign(L.Items[I]);
                                L.Items.Item[nPos + 1].Selected := True; //保持选中的状态
                            end;
                            L.Items.Delete(I);
                            Dec(nPos);
                        end;
                    end
                end;
            end;
    end;
end;

procedure FlatListViewHeader(AListView:TCustomListView);
const
    LVM_GETHEADER = $1000 + 31;
var
    hHeader:THandle;
    style:dWord;
begin
    // 使ListView的HeaderFlat
    if not Assigned(AListView) then Exit;
    hHeader := SendMessage(AListView.Handle, LVM_GETHEADER, 0, 0);
    style := GetWindowLong(hHeader, GWL_STYLE);
    style := style xor $2;
    SetWindowLong(hHeader, GWL_STYLE, style);
end;

function GetIPConfigName(ExName:string = ''):string;
begin
    if ExName = '' then ExName := '.isf';
    Result := ChangeFileExt(Application.ExeName, ExName);
end;

procedure CheckParentProc;
var //检查自己的进程的父进程
    Pn:TProcesseNtry32;
    sHandle:THandle;
    H, ExplProc, ParentProc:Hwnd;
    Found:Boolean;
    Buffer:array[0..1023] of Char;
    Path:string;
begin
    H := 0;
    ExplProc := 0;
    ParentProc := 0;
    //得到Windows的目录
    FillChar(Buffer, sizeof(Buffer), #0);
    GetWindowsDirectory(Buffer, Sizeof(Buffer) - 1);
    SetString(Path, Buffer, sizeof(Buffer));
    Path := UpperCase(Trim(Path)) + '\EXPLORER.EXE'; //得到Explorer的路径
    //得到所有进程的列表快照
    sHandle := CreateToolHelp32SnapShot(TH32CS_SNAPALL, 0);
    Found := Process32First(sHandle, Pn); //查找进程
    while Found do begin
        //遍历所有进程
        if Pn.szExeFile = ParamStr(0) then begin
            //自己的进程
            ParentProc := Pn.th32ParentProcessID; //得到父进程的进程ID
            //父进程的句柄
            H := OpenProcess(PROCESS_ALL_ACCESS, True, Pn.th32ParentProcessID);
        end
        else if UpperCase(Pn.szExeFile) = Path then
            ExplProc := Pn.th32ProcessID; //Ex plorer的PID
        Found := Process32Next(sHandle, Pn); //查找下一个
    end;
    //父进程不是Explorer,是调试器……
    if ParentProc <> ExplProc then begin
        TerminateProcess(H, 0); //杀之!除之而后快也! :)
        //你还可以加上其它什么死机代码来消遣消遣这位可爱的Cracker:)
    end;
end;

function KillProcess(pid:THandle):Boolean;
var
    bKilled:Boolean;
    hp:THandle;
begin
    // 我已经关闭了全部主窗口,现在等待进程死亡。
    bKilled := TRUE;
    hp := OpenProcess(SYNCHRONIZE + PROCESS_TERMINATE, FALSE, pid);
    if (hp <> 0) then begin
        if (WaitForSingleObject(hp, 5000) <> WAIT_OBJECT_0) then begin
            if (True) then TerminateProcess(hp, 0) // 不愿死,那不行,你必须死
            else bKilled := FALSE;
        end;
        CloseHandle(hp);
    end;
    Result := bKilled;
end;

function GetConfirmHandle:THandle;
begin
    Result := FindWindow('TMessageForm', 'Confirm');
end;

procedure SaveStringToMS(MS:TMemoryStream; const str:string);
var
    nLen:Integer;
begin
    if not Assigned(MS) then Exit;
    nLen := Length(str);
    MS.Write(nLen, sizeof(nLen));
    MS.Write(str[1], nLen);
end;

procedure LoadStringFromMS(MS:TMemoryStream; var str:string);
var
    nLen:Integer;
begin
    if not Assigned(MS) then Exit;
    MS.Read(nLen, sizeof(nLen));
    SetLength(str, nLen);
    MS.Read(str[1], nLen);
end;

procedure SaveStringListToMS(MS:TMemoryStream; StringList:TStringList);
var
    nLen, I:Integer;
begin
    if not Assigned(MS) then Exit;
    if not Assigned(StringList) then Exit;
    nLen := StringList.Count;
    MS.Write(nLen, sizeof(nLen));
    for I := 0 to StringList.Count - 1 do begin
        SaveStringToMS(MS, StringList.Strings[i]);
    end;
end;

procedure LoadStringListFromMS(MS:TMemoryStream; StringList:TStringList);
var
    nLen, I:Integer;
    strTmp:string;
begin
    if not Assigned(MS) then Exit;
    if not Assigned(StringList) then Exit;
    StringList.Clear;
    MS.Read(nLen, sizeof(nLen));
    for I := 0 to nLen - 1 do begin
        LoadStringFromMS(MS, strTmp);
        StringList.Add(strTmp);
    end;
end;

function RegSetMultiString(RootKey:HKEY; Name:string; Value:string):boolean;
begin
    Result := RegSetValue(RootKey, Name, REG_MULTI_SZ, PChar(Value + #0#0), Length(Value) + 2);
end;

function RegGetMultiString(RootKey:HKEY; Name:string; var Value:string):boolean;
var
    Buf:Pointer;
    BufSize:Cardinal;
begin
    Result := False;
    Value := '';
    if RegGetValue(RootKey, Name, REG_MULTI_SZ, Buf, BufSize) then begin
        Dec(BufSize);
        SetLength(Value, BufSize);
        if BufSize > 0 then
            Move(Buf^, Value[1], BufSize);
        FreeMem(Buf);
        Result := True;
    end;
end;

function StringsToStr(Strings:TStrings; Delimiter:Char):string;
begin
    // 转换Strings为string,
    Result := '';
    if not Assigned(Strings) then Exit;
    Strings.Delimiter := Delimiter;
    Result := Strings.DelimitedText;
end;

procedure StrToStrings(str:string; Strings:TStringList; Delimiter:Char = #0);
begin
    // 转换string为Strings,
    if not Assigned(Strings) then Exit;
    Strings.Delimiter := Delimiter;
    Strings.DelimitedText := str;
end;

function LastPos(Needle:Char; Haystack:string):integer;
begin
    for Result := Length(Haystack) downto 1 do
        if Haystack[Result] = Needle then
            Break;
end;

function RegGetValue(RootKey:HKEY; Name:string; ValType:Cardinal; var PVal:Pointer; var ValSize:Cardinal):boolean;
var
    SubKey:string;
    n:integer;
    MyValType:DWORD;
    hTemp:HKEY;
    Buf:Pointer;
    BufSize:Cardinal;
    PKey:PChar;
begin
    Result := False;
    n := LastPos('\', Name);
    if n > 0 then begin
        SubKey := Copy(Name, 1, n - 1);
        if RegOpenKeyEx(RootKey, PChar(SubKey), 0, KEY_READ, hTemp) = ERROR_SUCCESS then begin
            SubKey := Copy(Name, n + 1, Length(Name) - n);
            if SubKey = '' then
                PKey := nil
            else
                PKey := PChar(SubKey);
            if RegQueryValueEx(hTemp, PKey, nil, @MyValType, nil, @BufSize) = ERROR_SUCCESS then begin
                GetMem(Buf, BufSize);
                if RegQueryValueEx(hTemp, PKey, nil, @MyValType, Buf, @BufSize) = ERROR_SUCCESS then begin
                    if ValType = MyValType then begin
                        PVal := Buf;
                        ValSize := BufSize;
                        Result := True;
                    end else begin
                        FreeMem(Buf);
                    end;
                end else begin
                    FreeMem(Buf);
                end;
            end;
            RegCloseKey(hTemp);
        end;
    end;
end;

function RegSetValue(RootKey:HKEY; Name:string; ValType:Cardinal; PVal:Pointer; ValSize:Cardinal):boolean;
var
    SubKey:string;
    n:integer;
    dispo:DWORD;
    hTemp:HKEY;
begin
    Result := False;
    n := LastPos('\', Name);
    if n > 0 then begin
        SubKey := Copy(Name, 1, n - 1);
        if RegCreateKeyEx(RootKey, PChar(SubKey), 0, nil, REG_OPTION_NON_VOLATILE, KEY_WRITE, nil, hTemp, @dispo) = ERROR_SUCCESS then begin
            SubKey := Copy(Name, n + 1, Length(Name) - n);
            if SubKey = '' then
                Result := (RegSetValueEx(hTemp, nil, 0, ValType, PVal, ValSize) = ERROR_SUCCESS)
            else
                Result := (RegSetValueEx(hTemp, PChar(SubKey), 0, ValType, PVal, ValSize) = ERROR_SUCCESS);
            RegCloseKey(hTemp);
        end;
    end;
end;

function RegSetString(RootKey:HKEY; Name:string; Value:string):boolean;
begin
    Result := RegSetValue(RootKey, Name, REG_SZ, PChar(Value + #0), Length(Value) + 1);
end;

function RegGetString(RootKey:HKEY; Name:string; var Value:string):boolean;
var
    Buf:Pointer;
    BufSize:Cardinal;
begin
    Result := False;
    Value := '';
    if RegGetValue(RootKey, Name, REG_SZ, Buf, BufSize) then begin
        Dec(BufSize);
        SetLength(Value, BufSize);
        if BufSize > 0 then
            Move(Buf^, Value[1], BufSize);
        FreeMem(Buf);
        Result := True;
    end;
end;

function RegGetDWORD(RootKey:HKEY; Name:string; var Value:Cardinal):boolean;
var
    Buf:Pointer;
    BufSize:Cardinal;
begin
    Result := False;
    Value := 0;
    if RegGetValue(RootKey, Name, REG_DWORD, Buf, BufSize) then begin
        Value := PDWord(Buf)^;
        FreeMem(Buf);
        Result := True;
    end;
end;

function RegSetDword(RootKey:HKEY; Name:string; Value:Cardinal):boolean;
begin
    Result := RegSetValue(RootKey, Name, REG_DWORD, @Value, SizeOf(Cardinal));
end;

/////////////////////  获取IP地址 //////////////////////

function GetGatewayByIPHLP(AAdapterName:string):string;
const
    AddrLen = 6;
var
    PAdapterInfo:PTIP_ADAPTER_INFO;
    ret:DWORD;
    Next:PTIP_ADAPTER_INFO;
    OutBufLen:ULONG;
    strAdapterName:string;
begin
    /// 获得适配器信息
    OutBufLen := SizeOf(PAdapterInfo^);
    GetAdaptersInfo(nil, @OutBufLen); // to get the required size
    PAdapterInfo := AllocMem(OutBufLen);
    ret := GetAdaptersInfo(PAdapterInfo, @OutBufLen);
    // SetLength(strAdapterName, Length(AAdapterName) * 2);

    if ret = 0 then begin
        Next := PAdapterInfo;
        repeat
            strAdapterName := Next^.AdapterName;
            if Trim(strAdapterName) = AAdapterName then begin
                Result := (Next^.GatewayList.IpAddress);
                if Trim(Result) <> '' then Break;
            end;
            Next := Next^.Next;
        until Next = nil;
    end;
    FreeMem(PAdapterInfo, OutBufLen);
end;

function InSameSegment(AIP1, AIP2:string):Integer;
var
    nIndex:Integer;
    strTmp1, strTmp2:string;
begin
    // 判断是否在统一网段
    // 不判断Ip是否合法，纯粹的字符串比较
    // 相同
    Result := -1;
    Result := 0;
    Exit;//.. 判断没关系
    if Trim(AIP1) = Trim(AIP2) then Exit;

    nIndex := LastDelimiter('.', AIP1);
    strTmp1 := Copy(AIP1, 0, nIndex - 1);
    nIndex := LastDelimiter('.', AIP2);
    strTmp2 := Copy(AIP2, 0, nIndex - 1);

    if strTmp1 = strTmp2 then Result := 0
    else Result := 1;
end;

procedure OutputDebugInfo(ADebugInfo:string);
begin
    // 统一输出测试信息
    {$IFDEF DEBUG}
    OutputDebugString(PChar(ADebugInfo));
    {$ENDIF}
end;

procedure HideBalloonTip;
var
    h:THandle;
begin
    // 通过点击隐藏气泡
    sleep(800);
    h := FindWindow('tooltips_class32', nil);
    if h > 0 then begin
        SendMessage(h, WM_LBUTTONUP, 0, 0);
        SendMessage(h, WM_LBUTTONDOWN, 0, 0);
    end;
end;

function SendMail(AAddress, ASubject:string; ABody:TStringList):Boolean;
var
    strMail:string;
    function PreBody:string;
    var
        i:Integer;
    begin
        for i := 0 to ABody.Count - 1 do begin
            Result := Result + ABody.Strings[i] + '%0D%0A';
        end;
        Result := Result + FormatDateTime('yyyy-mm-dd', now);
    end;
begin
    // 发送邮件
    Result := False;
    if Trim(AAddress) = '' then Exit;
    if Trim(ASubject) = '' then Exit;
    strMail := 'mailto:' + AAddress;
    strMail := strMail + '?Subject=' + ASubject;
    strMail := strMail + '&body=' + PreBody;
    ShellExecute(GetActiveWindow, 'open', PChar(strMail), nil, nil, SW_SHOW);
    Result := True;
end;

////////////////////   获得系统Windows版本 ////////////////

function GetVersionInfo(var SProduct, SVersion, SServicePack:string):BOOL;
type
    _OSVERSIONINFOEXA = record
        dwOSVersionInfoSize:DWORD;
        dwMajorVersion:DWORD;
        dwMinorVersion:DWORD;
        dwBuildNumber:DWORD;
        dwPlatformId:DWORD;
        szCSDVersion:array[0..127] of AnsiChar;
        wServicePackMajor:WORD;
        wServicePackMinor:WORD;
        wSuiteMask:Word;
        wProductType:Byte;
        wReserved:Byte;
    end;
    _OSVERSIONINFOEXW = record
        dwOSVersionInfoSize:DWORD;
        dwMajorVersion:DWORD;
        dwMinorVersion:DWORD;
        dwBuildNumber:DWORD;
        dwPlatformId:DWORD;
        szCSDVersion:array[0..127] of WideChar;
        wServicePackMajor:WORD;
        wServicePackMinor:WORD;
        wSuiteMask:Word;
        wProductType:Byte;
        wReserved:Byte;
    end;
    { this record only support Windows 4.0 SP6 and latter , Windows 2000 ,XP, 2003 }
    OSVERSIONINFOEXA = _OSVERSIONINFOEXA;
    OSVERSIONINFOEXW = _OSVERSIONINFOEXW;
    OSVERSIONINFOEX = OSVERSIONINFOEXA;
const
    VER_PLATFORM_WIN32_CE = 3;
    { wProductType defines }
    VER_NT_WORKSTATION = 1;
    VER_NT_DOMAIN_CONTROLLER = 2;
    VER_NT_SERVER = 3;
    { wSuiteMask defines }
    VER_SUITE_SMALLBUSINESS = $0001;
    VER_SUITE_ENTERPRISE = $0002;
    VER_SUITE_BACKOFFICE = $0004;
    VER_SUITE_TERMINAL = $0010;
    VER_SUITE_SMALLBUSINESS_RESTRICTED = $0020;
    VER_SUITE_DATACENTER = $0080;
    VER_SUITE_PERSONAL = $0200;
    VER_SUITE_BLADE = $0400;
    VER_SUITE_SECURITY_APPLIANCE = $1000;
var
    Info:OSVERSIONINFOEX;
    bEx:BOOL;
    ProductType:string;
begin
    Result := False;
    FillChar(Info, SizeOf(OSVERSIONINFOEX), 0);
    Info.dwOSVersionInfoSize := SizeOf(OSVERSIONINFOEX);
    bEx := GetVersionEx(POSVERSIONINFO(@Info)^);
    if not bEx then begin
        Info.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);
        if not GetVersionEx(POSVERSIONINFO(@Info)^) then Exit;
    end;
    with Info do begin
        SVersion := IntToStr(dwMajorVersion) + '.' + IntToStr(dwMinorVersion)
            + '.' + IntToStr(dwBuildNumber and $0000FFFF);
        SProduct := 'Microsoft Windows unknown';
        case Info.dwPlatformId of
            VER_PLATFORM_WIN32s: { Windows 3.1 and earliest }
                SProduct := 'Microsoft Win32s';
            VER_PLATFORM_WIN32_WINDOWS:
                case dwMajorVersion of
                    4: { Windows95,98,ME }
                        case dwMinorVersion of
                            0:
                                if szCSDVersion[1] in ['B', 'C'] then begin
                                    SProduct := 'Microsoft Windows 95 OSR2';
                                    SVersion := SVersion + szCSDVersion[1];
                                end
                                else
                                    SProduct := 'Microsoft Windows 95';
                            10:
                                if szCSDVersion[1] = 'A' then begin
                                    SProduct := 'Microsoft Windows 98 SE';
                                    SVersion := SVersion + szCSDVersion[1];
                                end
                                else
                                    SProduct := 'Microsoft Windows  98';
                            90:
                                SProduct := 'Microsoft Windows Millennium Edition';
                        end;
                end;
            VER_PLATFORM_WIN32_NT:begin
                    SServicePack := szCSDVersion;
                    case dwMajorVersion of
                        0..4:
                            if bEx then begin
                                case wProductType of
                                    VER_NT_WORKSTATION:
                                        SProduct := 'Microsoft Windows NT Workstation 4.0';
                                    VER_NT_SERVER:
                                        if wSuiteMask and VER_SUITE_ENTERPRISE <> 0 then
                                            SProduct := 'Microsoft Windows NT Advanced Server 4.0'
                                        else
                                            SProduct := 'Microsoft Windows NT Server 4.0';
                                end;
                            end
                            else { NT351 and NT4.0 SP5 earliest}
                                if RegGetString(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\ProductOptions\ProductType', ProductType) then begin
                                if ProductType = 'WINNT' then
                                    SProduct := 'Microsoft Windows NT Workstation ' + SVersion
                                else if ProductType = 'LANMANNT' then
                                    SProduct := 'Microsoft Windows NT Server ' + SVersion
                                else if ProductType = 'LANMANNT' then
                                    SProduct := 'Microsoft Windows NT Advanced Server ' + SVersion;
                            end;
                        5:
                            case dwMinorVersion of
                                0: { Windows 2000 }
                                    case wProductType of
                                        VER_NT_WORKSTATION:
                                            SProduct := 'Microsoft Windows 2000 Professional';
                                        VER_NT_SERVER:
                                            if wSuiteMask and VER_SUITE_DATACENTER <> 0 then
                                                SProduct := 'Microsoft Windows 2000 Datacenter Server'
                                            else if wSuiteMask and VER_SUITE_ENTERPRISE <> 0 then
                                                SProduct := 'Microsoft Windows 2000 Advanced Server'
                                            else
                                                SProduct := 'Microsoft Windows 2000 Server';
                                    end;
                                1: { Windows XP }
                                    if wSuiteMask and VER_SUITE_PERSONAL <> 0 then
                                        SProduct := 'Microsoft Windows XP Home Edition'
                                    else
                                        SProduct := 'Microsoft Windows XP Professional';
                                2: { Windows Server 2003 }
                                    if wSuiteMask and VER_SUITE_DATACENTER <> 0 then
                                        SProduct := 'Microsoft Windows Server 2003 Datacenter Edition'
                                    else if wSuiteMask and VER_SUITE_ENTERPRISE <> 0 then
                                        SProduct := 'Microsoft Windows Server 2003 Enterprise Edition'
                                    else if wSuiteMask and VER_SUITE_BLADE <> 0 then
                                        SProduct := 'Microsoft Windows Server 2003 Web Edition'
                                    else
                                        SProduct := 'Microsoft Windows Server 2003 Standard Edition';
                            end;
                    end;
                end;
            VER_PLATFORM_WIN32_CE: { Windows CE }
                SProduct := SProduct + ' CE';
        end;
    end;
    Result := True;
end;

procedure GetBuildInfo(var V1, V2, V3, V4:Word);
var
    VerInfoSize:DWORD;
    VerInfo:Pointer;
    VerValueSize:DWORD;
    VerValue:PVSFixedFileInfo;
    Dummy:DWORD;
begin
    // 文件版本
    VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
    GetMem(VerInfo, VerInfoSize);
    GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
    with VerValue^ do begin
        V1 := dwFileVersionMS shr 16;
        V2 := dwFileVersionMS and $FFFF;
        V3 := dwFileVersionLS shr 16;
        V4 := dwFileVersionLS and $FFFF;
    end;
    FreeMem(VerInfo, VerInfoSize);
end;

procedure CreateShortcut(FileName:string; Description:string; arguements:string; LinkName:string; Location:ShortcutType);
const
    REGSTR_PATH_EXPLORER = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
var
    cObj:IUnknown;
    sLink:IShellLink;
    pFile:IPersistFile;
    sDir:string;
    lName:string;
    spath:string;
    wFileName:WideString;
    key:string;
begin
    cObj := CreateComObject(CLSID_ShellLink); //创建COM对象
    sLink := cObj as IShellLink; //COM对象转化为IShellLink型接口
    pFile := cObj as IPersistFile; //COM对象转化为IPersistFile型接口

    //获取路径
    sPath := ExtractFilePath(FileName);
    with sLink do begin
        SetPath(PChar(FileName)); //设置执行文件名
        SetArguments(PChar(arguements)); //设置执行参数
        SetDescription(Pchar(Description)); //设置描述信息
        SetWorkingDirectory(PChar(sPath)); //设置工作路径，即执行程序所在目录
    end;

    //获取各快捷方式的实际目录
    key := REGSTR_PATH_EXPLORER;
    case Location of
        ST_DESKTOP:RegGetString(HKEY_CURRENT_USER, key + '\Desktop', sDir);
        ST_SENDTO:RegGetString(HKEY_CURRENT_USER, key + '\SendTo', sDir);
        ST_STARTMENU:RegGetString(HKEY_CURRENT_USER, key + '\Start Menu', sDir);
        ST_QUICKLAUNCH:begin
                RegGetString(HKEY_CURRENT_USER, key + '\AppData', sDir);
                sDir := sDir + '\Microsoft\Internet Explorer\Quick Launch';
            end;
    end;
    //生成快捷方式文件名
    lName := ChangeFileExt(FileName, '.Lnk');
    if LinkName = '' then lName := ExtractFileName(lName)
    else lName := ChangeFileExt(LinkName, '.Lnk');
    if sDir <> '' then begin
        //生成快捷方式全路径名
        wFileName := sDir + '\' + lName;
        //保存生成的快捷方式文件
        pFile.Save(PWChar(wFileName), false);
    end;
end;

end.

