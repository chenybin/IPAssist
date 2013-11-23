unit uICMPUtil;

interface

uses
    Windows, WinSock;
const
    INADDR_NONE = $FFFFFFFF;

function inet_addr(const cp:PChar):DWord; stdcall; external 'WS2_32.DLL' name 'inet_addr';

type
    //用到的协议数据结构
    PIPOptionInfo = ^TIPOptionInfo; // IP 头选项
    TIPOptionInfo = packed record
        TTL:Byte; //存活时间
        TOS:Byte; //Type of Service，请求类型
        Flags:Byte; //标志
        OptionsSize:Byte; //选项长度
        OptionsData:PChar; //选项数据
    end;
    PIcmpEchoReply = ^TIcmpEchoReply;
    TIcmpEchoReply = packed record // ICMP 返回信息
        Address:DWORD; //IP地址
        Status:DWORD; //状态
        RTT:DWORD;
        DataSize:Word; //数据长度
        Reserved:Word; //保留
        Data:Pointer; //数据
        Options:TIPOptionInfo; //选项区
    end;

    //动态库中的函数声明
    TIcmpCreateFile = function:THandle; stdcall; //创建ICMP句柄
    TIcmpCloseHandle = function(IcmpHandle:THandle):Boolean; stdcall; //关闭ICMP句柄
    TIcmpSendEcho = function(IcmpHandle:THandle; DestinationAddress:DWORD;
        RequestData:Pointer; RequestSize:Word; RequestOptions:PIPOptionInfo;
        ReplyBuffer:Pointer; ReplySize:DWord; Timeout:DWord):DWord; stdcall; //发送ICMP探测数据报

    TICMPUtil = class
    private
        FEnabled:Boolean; // 表示是否可用，可能是Dll加载出错了

        FDllHandle:THandle;
        IcmpCreateFile:TIcmpCreateFile;
        IcmpCloseHandle:TIcmpCloseHandle;
        IcmpSendEcho:TIcmpSendEcho; // 几个函数句柄

        /////////////////////  为了提高效率，启动即分配内存 ///////////
        hIcmp:THandle;
        pIPE:PIcmpEchoReply; // ICMP Echo 回复缓冲区
        BufferSize:DWORD;
        FSize:DWORD;
        MyString:string;
        FTimeOut:DWORD;
        IPOpt:TIPOptionInfo; // 发包的 IP 选项
        pReqData, pRevData:PChar;
        ///////////////////////////////////////////////////////////////
        procedure InitAPI;

    public
        constructor Create;
        destructor Destroy; override;
        procedure Initilize;

        class function PingIP(AIPAddress:string; ALocalMac:string):Integer; overload;
        function PingIP(AIPAddress:string):Integer; overload;
        class function PingIP(AIPAddress:string; hops_count:PULong; rtt:PULong):Integer; overload;
        class function CheckIPValid(AIPAddress:string):Boolean;
    public
        property Enabled:Boolean read FEnabled;
    end;

implementation
uses
    IpHlpAPI, SysUtils;
{ TICMPUtil }

class function TICMPUtil.CheckIPValid(AIPAddress:string):Boolean;
begin
    Result := (INADDR_NONE <> inet_addr(PChar(AIPAddress)));
end;

constructor TICMPUtil.Create;
begin
    FEnabled := False;
    FDllHandle := 0;
    InitAPI;
    Initilize;
end;

destructor TICMPUtil.Destroy;
begin
    FreeMem(pRevData);
    FreeMem(pIPE);
    IcmpCloseHandle(hicmp);
    if FDllHandle <> 0 then
        FreeLibrary(FDllHandle);

    WSAcleanup();
    inherited;
end;

procedure TICMPUtil.InitAPI;
var
    WSAData:TWSAData;
    icmpHandle, IPHLPAPIHandle:THandle;
begin
    // 先用IPHLPAPI，在2000系统是用icmp的
    FEnabled := False;
    WSAStartup($101, WSAData);
    IPHLPAPIHandle := LoadLibrary('IPHLPAPI');
    if IPHLPAPIHandle > 0 then begin
        @ICMPCreateFile := GetProcAddress(IPHLPAPIHandle, 'IcmpCreateFile');
        if Assigned(ICMPCreateFile) then begin
            @IcmpCloseHandle := GetProcAddress(IPHLPAPIHandle, 'IcmpCloseHandle');
            @IcmpSendEcho := GetProcAddress(IPHLPAPIHandle, 'IcmpSendEcho');
            FDllHandle := IPHLPAPIHandle;
            FEnabled := True;
            Exit;
        end;
    end;

    // 如果不行，再到icmp
    icmpHandle := LoadLibrary('icmp');
    if icmpHandle > 0 then begin
        @ICMPCreateFile := GetProcAddress(icmpHandle, 'IcmpCreateFile');
        if not Assigned(IcmpCreateFile) then Exit; // 如果不行说明加载不成功
        @IcmpCloseHandle := GetProcAddress(icmpHandle, 'IcmpCloseHandle');
        @IcmpSendEcho := GetProcAddress(icmpHandle, 'IcmpSendEcho');
        FDllHandle := icmpHandle;
        FreeLibrary(IPHLPAPIHandle);
    end;

    FEnabled := True;
end;

function TICMPUtil.PingIP(AIPAddress:string):Integer;
var
    IPAddr:DWORD;
begin
    Result := -1;
    if not FEnabled then Exit;
    IPAddr := inet_addr(PChar(AIPAddress)); //取要探测的远端主机ip地址
    try
        Result := IcmpSendEcho(hICMP, IPAddr, pReqData, Length(MyString), @IPOpt, pIPE, BufferSize, FTimeOut);
        //如果有返回，返回值表示收到的回复的个数。如果为0表示没有回复，主机无法到达
    finally
    end;
end;

class function TICMPUtil.PingIP(AIPAddress:string; ALocalMac:string):Integer;
var
    dwResult:DWord;
    ulIPAddr:DWord;
    ulMACAddr:array[0..5] of Byte;
    ulAddrLen:ULONG;
    sMac:string;
begin
    Result := -1; // 不成功
    ulIPAddr := inet_addr(PChar(AIPAddress));
    if ulIPAddr = INADDR_NONE then exit;
    ulAddrLen := 6;
    dwResult := SendARP(ulIPAddr, 0, @ulMACAddr, ulAddrLen);

    sMac := (IntToHex(ulMACAddr[0], 2) + '-' +
        IntToHex(ulMACAddr[1], 2) + '-' +
        IntToHex(ulMACAddr[2], 2) + '-' +
        IntToHex(ulMACAddr[3], 2) + '-' +
        IntToHex(ulMACAddr[4], 2) + '-' +
        IntToHex(ulMACAddr[5], 2));
    Result := 0; // 不通过
    if dwResult <> 0 then Exit;
    Result := 1; // 通了，但是是自己的
    if Pos(sMac, ALocalMac) > 1 then Exit;
    Result := 2; // 通了，是别人的
end;

procedure TICMPUtil.Initilize;
begin
    hICMP := IcmpCreateFile; //创建 icmp句柄

    FSize := 40;
    BufferSize := SizeOf(TICMPEchoReply) + FSize;
    GetMem(pRevData, FSize);
    GetMem(pIPE, BufferSize);

    FillChar(pIPE^, SizeOf(pIPE^), 0);
    pIPE^.Data := pRevData;
    MyString := 'TICMPUtil'; //任意字符串
    pReqData := PChar(MyString);
    FillChar(IPOpt, Sizeof(IPOpt), 0);
    IPOpt.TTL := 64;
    FTimeOut := 500; //等待时长

end;

class function TICMPUtil.PingIP(AIPAddress:string; hops_count:PULong; rtt:PULong):Integer;
const
    INADDR_NONE = $FFFFFFFF;
var
    ulIPAddr:DWord;
    bRet:Boolean;
begin
    // 使用GetRTTAndHopCount方式，因为SendARP不能ping异网段IP

    Result := -1; // 不成功
    ulIPAddr := inet_addr(PChar(AIPAddress));
    if ulIPAddr = INADDR_NONE then exit;

    Result := 0;
    //.. 这个参数需要注意一下，特别是第3个
    bRet := GetRTTAndHopCount(ulIPAddr, hops_count, 1, rtt);
    if bRet then Exit;
    Result := GetLastError;
end;

end.

