unit uICMPUtil;

interface

uses
    Windows, WinSock;
const
    INADDR_NONE = $FFFFFFFF;

function inet_addr(const cp:PChar):DWord; stdcall; external 'WS2_32.DLL' name 'inet_addr';

type
    //�õ���Э�����ݽṹ
    PIPOptionInfo = ^TIPOptionInfo; // IP ͷѡ��
    TIPOptionInfo = packed record
        TTL:Byte; //���ʱ��
        TOS:Byte; //Type of Service����������
        Flags:Byte; //��־
        OptionsSize:Byte; //ѡ���
        OptionsData:PChar; //ѡ������
    end;
    PIcmpEchoReply = ^TIcmpEchoReply;
    TIcmpEchoReply = packed record // ICMP ������Ϣ
        Address:DWORD; //IP��ַ
        Status:DWORD; //״̬
        RTT:DWORD;
        DataSize:Word; //���ݳ���
        Reserved:Word; //����
        Data:Pointer; //����
        Options:TIPOptionInfo; //ѡ����
    end;

    //��̬���еĺ�������
    TIcmpCreateFile = function:THandle; stdcall; //����ICMP���
    TIcmpCloseHandle = function(IcmpHandle:THandle):Boolean; stdcall; //�ر�ICMP���
    TIcmpSendEcho = function(IcmpHandle:THandle; DestinationAddress:DWORD;
        RequestData:Pointer; RequestSize:Word; RequestOptions:PIPOptionInfo;
        ReplyBuffer:Pointer; ReplySize:DWord; Timeout:DWord):DWord; stdcall; //����ICMP̽�����ݱ�

    TICMPUtil = class
    private
        FEnabled:Boolean; // ��ʾ�Ƿ���ã�������Dll���س�����

        FDllHandle:THandle;
        IcmpCreateFile:TIcmpCreateFile;
        IcmpCloseHandle:TIcmpCloseHandle;
        IcmpSendEcho:TIcmpSendEcho; // �����������

        /////////////////////  Ϊ�����Ч�ʣ������������ڴ� ///////////
        hIcmp:THandle;
        pIPE:PIcmpEchoReply; // ICMP Echo �ظ�������
        BufferSize:DWORD;
        FSize:DWORD;
        MyString:string;
        FTimeOut:DWORD;
        IPOpt:TIPOptionInfo; // ������ IP ѡ��
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
    // ����IPHLPAPI����2000ϵͳ����icmp��
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

    // ������У��ٵ�icmp
    icmpHandle := LoadLibrary('icmp');
    if icmpHandle > 0 then begin
        @ICMPCreateFile := GetProcAddress(icmpHandle, 'IcmpCreateFile');
        if not Assigned(IcmpCreateFile) then Exit; // �������˵�����ز��ɹ�
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
    IPAddr := inet_addr(PChar(AIPAddress)); //ȡҪ̽���Զ������ip��ַ
    try
        Result := IcmpSendEcho(hICMP, IPAddr, pReqData, Length(MyString), @IPOpt, pIPE, BufferSize, FTimeOut);
        //����з��أ�����ֵ��ʾ�յ��Ļظ��ĸ��������Ϊ0��ʾû�лظ��������޷�����
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
    Result := -1; // ���ɹ�
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
    Result := 0; // ��ͨ��
    if dwResult <> 0 then Exit;
    Result := 1; // ͨ�ˣ��������Լ���
    if Pos(sMac, ALocalMac) > 1 then Exit;
    Result := 2; // ͨ�ˣ��Ǳ��˵�
end;

procedure TICMPUtil.Initilize;
begin
    hICMP := IcmpCreateFile; //���� icmp���

    FSize := 40;
    BufferSize := SizeOf(TICMPEchoReply) + FSize;
    GetMem(pRevData, FSize);
    GetMem(pIPE, BufferSize);

    FillChar(pIPE^, SizeOf(pIPE^), 0);
    pIPE^.Data := pRevData;
    MyString := 'TICMPUtil'; //�����ַ���
    pReqData := PChar(MyString);
    FillChar(IPOpt, Sizeof(IPOpt), 0);
    IPOpt.TTL := 64;
    FTimeOut := 500; //�ȴ�ʱ��

end;

class function TICMPUtil.PingIP(AIPAddress:string; hops_count:PULong; rtt:PULong):Integer;
const
    INADDR_NONE = $FFFFFFFF;
var
    ulIPAddr:DWord;
    bRet:Boolean;
begin
    // ʹ��GetRTTAndHopCount��ʽ����ΪSendARP����ping������IP

    Result := -1; // ���ɹ�
    ulIPAddr := inet_addr(PChar(AIPAddress));
    if ulIPAddr = INADDR_NONE then exit;

    Result := 0;
    //.. ���������Ҫע��һ�£��ر��ǵ�3��
    bRet := GetRTTAndHopCount(ulIPAddr, hops_count, 1, rtt);
    if bRet then Exit;
    Result := GetLastError;
end;

end.

