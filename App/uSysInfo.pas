unit uSysInfo;

interface

uses
    iniFiles, uMutilLanguage, uSystemInfo, Forms, Classes;

const
    SYSTEMSECTION:string = 'SYSTEM';
type
    TMessageType = (mtWarning, mtError);

    TMessageStyle = (msOK, msOKCancel, msYesNoCancel);
    // 基类，以后语言类可以是处理dll或者xml等

    // 系统配置信息
    TSysInfo = class
    private
        FIniFile:TIniFile;
        FMutilLanguage:TMutilLanguage;
        FSystemInfo:TMYSystemInfo;

        function GetAutoRun:Boolean;
        procedure SetAutoRun(const Value:Boolean);
        function GetAutoApply:Boolean;
        procedure SetAutoApply(const Value:Boolean);
        function GetAutoSearch:Boolean;
        procedure SetAutoSearch(const Value:Boolean);
        function GetAutoTray:Boolean;
        procedure SetAutoTray(const Value:Boolean);
        function GetDefaultConfig:string;
        procedure SetDefaultConfig(const Value:string);
        function GetSearchAdapter:string;
        procedure SetSearchAdapter(const Value:string);
        procedure SetAutoSave(const Value:Boolean);
        function GetAutoSave:Boolean;
        function GetLanguage:string;
        procedure SetLanguage(const Value:string);
        function GetApplyDefault:Boolean;
        procedure SetApplyDefault(const Value:Boolean);
        function GetConfimChange:Boolean;
        procedure SetConfirmChange(const Value:Boolean);
        function GetConfirmDelete:Boolean;
        procedure SetConfirmDelete(const Value:Boolean);
        function GetListStyle:Integer;
        procedure SetListStyle(const Value:Integer);
        function GetRegCode:string;
        function GetUserName:string;
        procedure SetRegCode(const Value:string);
        procedure SetUserName(const Value:string);
        function GetAutoClearDHCPIP:Boolean;
        procedure SetAutoClearDHCPIP(const Value:Boolean);
        function GetTrayMenuStyle:Integer;
        procedure SetTrayMenuStyle(const Value:Integer);
        function GetLanguageList():TStringList;
        function GetAutoPing:Boolean;
        function GetCheckValid:Boolean;
        procedure SetAutoPing(const Value:Boolean);
        procedure SetCheckValid(const Value:Boolean);
    public
        constructor Create();
        destructor Destroy; override;
        // 取MutilLanguage类的方法
        function UpdateFormLanguage(AForm:TForm):Integer; overload;
        function UpdateFormLanguage(ASectionName:string; AResString:string; DefaultValue:string = ''):string; overload;
        function GetMessage(AMessageName:string; ADelimer:string = ''):string;
        // 显示消息对话框
        function ShowMLMessage(AMessage:string;
            ADelemer:string = '';
            AMessageStyle:TMessageStyle = msOK;
            AMessageType:TMessageType = mtWarning):Integer;
    published
        // 自动运行
        property AutoRun:Boolean read GetAutoRun write SetAutoRun;
        // 直接生效
        property AutoApply:Boolean read GetAutoApply write SetAutoApply;
        // 自动搜索
        property AutoSearch:Boolean read GetAutoSearch write SetAutoSearch;
        // 自动搜索的适配器
        property SearchAdapter:string read GetSearchAdapter write SetSearchAdapter;
        // 自动最小化
        property AutoTray:Boolean read GetAutoTray write SetAutoTray;
        // 切换不同项目时提示保存
        property ConfirmChange:Boolean read GetConfimChange write SetConfirmChange;
        // 删除提示
        property ConfirmDelete:Boolean read GetConfirmDelete write SetConfirmDelete;
        // 列表显示方式
        property ListStyle:Integer read GetListStyle write SetListStyle;
        // 自动应用选定配置
        property ApplyDefault:Boolean read GetApplyDefault write SetApplyDefault;
        // 默认配置
        property DefaultConfig:string read GetDefaultConfig write SetDefaultConfig;
        // 自动保存
        property AutoSave:Boolean read GetAutoSave write SetAutoSave;
        // 语言
        property Language:string read GetLanguage write SetLanguage;
        // 自动获取IP时清除设置
        property AutoClearDHCPIP:Boolean read GetAutoClearDHCPIP write SetAutoClearDHCPIP;
        // 语言列表
        property LanguageList:TStringList read GetLanguageList;
        // 用户名
        property UserName:string read GetUserName write SetUserName;
        // 注册码
        property RegCode:string read GetRegCode write SetRegCode;
        // 注册对象
        property SystemInfo:TMYSystemInfo read FSystemInfo;
        // 显示IP，配置名或两个都做
        property TrayMenuStyle:Integer read GetTrayMenuStyle write SetTrayMenuStyle;
        // 自动测试连接性
        property AutoPing:Boolean read GetAutoPing write SetAutoPing;
        // 保存数据时校验合法性
        property CheckValid:Boolean read GetCheckValid write SetCheckValid;
    end;
var
    SysInfo:TSysInfo;
implementation
uses
    Registry, Windows, SysUtils, uUtiles;
{ TSysInfo }

constructor TSysInfo.Create;
var
    FileName:string;
begin
    FileName := GetIPConfigName('.ini');
    FIniFile := TIniFile.Create(FileName);
    FMutilLanguage := TMutilLanguageFile.Create;
    if (Language = '') and (FMutilLanguage.LanguageList.Count > 0) then begin
        Language := FMutilLanguage.LanguageList.Strings[0];
        FMutilLanguage.LanguageName := Language;
    end
    else
        FMutilLanguage.LanguageName := Language;
    FSystemInfo := TMYSystemInfo.Create;
end;

destructor TSysInfo.Destroy;
begin
    FSystemInfo.Free;
    FMutilLanguage.Free;
    FIniFile.Free;
    inherited;
end;

function TSysInfo.UpdateFormLanguage(AForm:TForm):Integer;
begin
    Result := FMutilLanguage.UpdateFormLanguage(AForm);
end;

function TSysInfo.UpdateFormLanguage(ASectionName, AResString, DefaultValue:string):string;
begin
    Result := FMutilLanguage.UpdateFormLanguage(ASectionName, AResString, DefaultValue);
end;

function TSysInfo.GetMessage(AMessageName, ADelimer:string):string;
begin
    Result := FMutilLanguage.GetMessage(AMessageName);
    if Result = '' then Result := AMessageName;
    if Pos(ADelimer, Result) = 0 then
        Result := Result + ADelimer;
end;

function TSysInfo.ShowMLMessage(AMessage:string; ADelemer:string;
    AMessageStyle:TMessageStyle; AMessageType:TMessageType):Integer;
var
    strMsg:string;
    strConfim:string;
begin
    Result := 0;
    strMsg := GetMessage(AMessage, ADelemer);
    strConfim := GetMessage('Confirm');
    if strConfim = '' then strConfim := '提示';
    case AMessageStyle of
        msOK:Result := MessageBox(0, PChar(strMsg), PChar(strConfim), MB_OK + MB_ICONWARNING);
        msOKCancel:Result := MessageBox(0, PChar(strMsg), PChar(strConfim), MB_OKCANCEL + MB_ICONQUESTION);
        msYesNoCancel:Result := MessageBox(0, PChar(strMsg), PChar(strConfim), MB_YESNOCANCEL + MB_ICONQUESTION);
    end;
end;

function TSysInfo.GetAutoApply:Boolean;
begin
    Result := False;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'AutoApply', False);
end;

function TSysInfo.GetApplyDefault:Boolean;
begin
    Result := False;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'ApplyDefault', False);
end;

function TSysInfo.GetAutoRun:Boolean;
var
    Reg:TRegistry;
begin
    Result := False;
    Reg := TRegistry.Create;
    try
        Reg.RootKey := HKEY_LOCAL_MACHINE;
        if Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', True) then begin
            Result := Reg.ValueExists(Application.Title);
            Reg.CloseKey;
        end;
    finally
        Reg.Free;
    end;
end;

function TSysInfo.GetAutoSave:Boolean;
begin
    Result := False;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'AutoSave', False);
end;

function TSysInfo.GetAutoSearch:Boolean;
begin
    Result := False;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'AutoSearch', False);
end;

function TSysInfo.GetAutoTray:Boolean;
begin
    Result := False;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'AutoTray', False);
end;

function TSysInfo.GetDefaultConfig:string;
begin
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadString(SYSTEMSECTION, 'DefaultConfig', '');
end;

function TSysInfo.GetLanguage:string;
begin
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadString(SYSTEMSECTION, 'Language', '');
end;

function TSysInfo.GetSearchAdapter:string;
begin
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadString(SYSTEMSECTION, 'SearchAdapter', '');
end;

procedure TSysInfo.SetAutoApply(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'AutoApply', Value);
end;

procedure TSysInfo.SetApplyDefault(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'ApplyDefault', Value);
end;

procedure TSysInfo.SetAutoRun(const Value:Boolean);
var
    Reg:TRegistry;
begin
    if Value = GetAutoRun then Exit;
    Reg := TRegistry.Create;
    try
        Reg.RootKey := HKEY_LOCAL_MACHINE;
        if Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', True) then begin
            if Value then Reg.WriteString(Application.Title, '"' + ParamStr(0) + '"')
            else Reg.DeleteValue(Application.Title);
            Reg.CloseKey;
        end;
    finally
        Reg.Free;
    end;
end;

procedure TSysInfo.SetAutoSave(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'AutoSave', Value);
end;

procedure TSysInfo.SetAutoSearch(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'AutoSearch', Value);
end;

procedure TSysInfo.SetAutoTray(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'AutoTray', Value);
end;

procedure TSysInfo.SetDefaultConfig(const Value:string);
begin
    FIniFile.WriteString(SYSTEMSECTION, 'DefaultConfig', Value);
end;

procedure TSysInfo.SetLanguage(const Value:string);
begin
    FIniFile.WriteString(SYSTEMSECTION, 'Language', Value);
    FMutilLanguage.LanguageName := Value;
end;

procedure TSysInfo.SetSearchAdapter(const Value:string);
begin
    FIniFile.WriteString(SYSTEMSECTION, 'SearchAdapter', Value);
end;

function TSysInfo.GetConfimChange:Boolean;
begin
    Result := True;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'ConfirmChange', True);
end;

procedure TSysInfo.SetConfirmChange(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'ConfirmChange', Value);
end;

function TSysInfo.GetConfirmDelete:Boolean;
begin
    Result := True;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'ConfirmDelete', True);
end;

procedure TSysInfo.SetConfirmDelete(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'ConfirmDelete', Value);
end;

function TSysInfo.GetListStyle:Integer;
begin
    Result := 0;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadInteger(SYSTEMSECTION, 'ListStyle', 0);
end;

procedure TSysInfo.SetListStyle(const Value:Integer);
begin
    FIniFile.WriteInteger(SYSTEMSECTION, 'ListStyle', Value);
end;

function TSysInfo.GetRegCode:string;
begin
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadString(SYSTEMSECTION, 'RegCode', '');
end;

function TSysInfo.GetUserName:string;
begin
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadString(SYSTEMSECTION, 'UserName', '');
end;

procedure TSysInfo.SetRegCode(const Value:string);
begin
    FIniFile.WriteString(SYSTEMSECTION, 'RegCode', Value);
end;

procedure TSysInfo.SetUserName(const Value:string);
begin
    FIniFile.WriteString(SYSTEMSECTION, 'UserName', Value);
end;

function TSysInfo.GetAutoClearDHCPIP:Boolean;
begin
    Result := False;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'AutoClearDHCPIP', False);
end;

procedure TSysInfo.SetAutoClearDHCPIP(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'AutoClearDHCPIP', Value);
end;

function TSysInfo.GetTrayMenuStyle:Integer;
begin
    Result := 0;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadInteger(SYSTEMSECTION, 'TrayMenuStyle', 0);
end;

procedure TSysInfo.SetTrayMenuStyle(const Value:Integer);
var
    tmp:Integer;
begin
    tmp := Value;
    if tmp < 0 then tmp := 0;
    if tmp > 2 then tmp := 2;
    FIniFile.WriteInteger(SYSTEMSECTION, 'TrayMenuStyle', tmp);
end;

function TSysInfo.GetLanguageList():TStringList;
begin
    Result := FMutilLanguage.LanguageList;
end;

function TSysInfo.GetAutoPing:Boolean;
begin
    Result := False;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'AutoPing', False);
end;

function TSysInfo.GetCheckValid:Boolean;
begin
    Result := True;
    if FIniFile.SectionExists(SYSTEMSECTION) then
        Result := FIniFile.ReadBool(SYSTEMSECTION, 'CheckValid', True);
end;

procedure TSysInfo.SetAutoPing(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'AutoPing', Value);
end;

procedure TSysInfo.SetCheckValid(const Value:Boolean);
begin
    FIniFile.WriteBool(SYSTEMSECTION, 'CheckValid', Value);
end;

end.

