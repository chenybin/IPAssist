unit uSystemInfo;

interface

type
    TRegistry = class;

    // 系统信息类，主要是判断是否可用，并取得硬盘序列号等信息
    TMYSystemInfo = class
    private
        FReg:TRegistry;

        function GetIdeSN:string;
        function FWJ:Boolean;
    public
        property wjwj_wjky__aaa:Boolean read FWJ;
        property IDESN:string read GetIdeSN;
    public
        constructor Create;
        destructor Destroy; override;
    end;

    TRegistry = class
    private
        FOriginalData:string;
        FUserName:string;
        function DeCode(const ASource:string):string;
        function EnCode(const ASource:string):string;
        function Exchange(ASource:string):string;
    public
        function SetOriginalData(AOriginalData:string):Boolean;
        procedure SetUserName(AUserName:string);
        function CheckMM(AMM:string):Boolean;
        function GetIdeSN:string;
    end;
var
    SystemInfo:TMYSystemInfo;

function StringToHex(S:string):string; forward;
function HexToString(S:string):string; forward;

implementation
uses
    Windows, SysUtils, Classes, Math, uSysInfo;


function StringToHex(S:string):string;
var
    i:integer;
begin
    Result := '';
    for i := 1 to Length(S) do
        Result := Result + IntToHex(Ord(S[i]), 2);
end;

function HexToString(S:string):string;
var
    i:integer;
begin
    Result := '';
    for i := 1 to Length(S) do begin
        if ((i mod 2) = 1) then
            Result := Result + Chr(StrToInt('0x' + Copy(S, i, 2)));
    end;
end;

{ TSystemInfo }

function TMYSystemInfo.FWJ:Boolean;
begin

    Result := True;
end;

constructor TMYSystemInfo.Create;
begin
    FReg := TRegistry.Create;
end;

destructor TMYSystemInfo.Destroy;
begin
    FReg.Free;
    inherited;
end;

function TMYSystemInfo.GetIdeSN:string;
begin
    // 硬盘序号
    Result := FReg.GetIdeSN;
end;

{ TRegistry }

function TRegistry.Exchange(ASource:string):string;
begin
    // 字符串置换
    Result := ASource;
end;

function TRegistry.EnCode(const ASource:string):string;
begin

end;

function TRegistry.DeCode(const ASource:string):string;
begin

end;

procedure TRegistry.SetUserName(AUserName:string);
begin
    // 传入用户名

end;

function TRegistry.SetOriginalData(AOriginalData:string):Boolean;
begin

    Result := True;
end;

function TRegistry.CheckMM(AMM:string):Boolean;
begin
    Result := True;
end;

function TRegistry.GetIdeSN:string;
begin

    Result := '';
end;

end.

