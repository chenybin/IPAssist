unit uMutilLanguage;

interface

uses
    iniFiles, Forms, Classes, Controls, Graphics, stdCtrls, ActnList;

const
    MESSAGESECTION:string = 'Message';
    HEADERSECTION:string = 'Language';

type
    // 获取语言版本
    TGetLanguageACP = function(var ALanguageName:PChar):Integer; stdcall;
    // 获取语言内容
    TGetLanguageString = function: PChar; stdcall;

    TMutilLanguage = class
    protected
        FMemIniFile:TMemIniFile;
        // 语言列表
        FLanguageNameList:THashedStringList;
        // 消息列表
        FMessageName:THashedStringList;
        FMessageValue:THashedStringList;

        // 形成ini文件列表
        function BuildLanguageList:Boolean; virtual;
        // 从ini文件中读取建立消息列表
        function BuildMessage:Boolean; virtual;
        // 初始化
        procedure Initialize; virtual;
        procedure SetLanguageName(const Value:string); virtual;
    public
        constructor Create;
        destructor Destroy; override;
        // 生效窗体
        function UpdateFormLanguage(AForm:TForm):Integer; overload; virtual;
        function UpdateFormLanguage(AFormName:string; AComponent:TComponent):Integer; overload; virtual;
        function UpdateFormLanguage(ASectionName:string; AResString:string; DefaultValue:string = ''):string; overload; virtual;
        // 取得消息字符
        function GetMessage(AMessageName:string):string; virtual;
    published
        property LanguageName:string write SetLanguageName;
        property LanguageList:THashedStringList read FLanguageNameList;
    end;

    TMutilLanguageFile = class(TMutilLanguage)
    protected
        FLanguageDir:string; // 所在路径，默认为当前路径加Lang
        FLangFile:string; // 文件名
        // 成对出现的目的是便于检索
        FLanguageFileList:THashedStringList;

        // 形成ini文件列表
        function BuildLanguageList:Boolean; override;
        // 从ini文件中读取建立消息列表
        function BuildMessage:Boolean; override;
        procedure BuildDefaultMessage;

        procedure Initialize; override;
        procedure SetLanguageDir(const Value:string); virtual;
        procedure SetLanguageName(const Value:string); override;
    public
        constructor Create;
        destructor Destroy; override;
    published
        property LanguageName:string write SetLanguageName;
        property LanguageDir:string write SetLanguageDir;
        property LanguageList:THashedStringList read FLanguageNameList;
    end;

    TMutilLanguageFileDLL = class(TMutilLanguageFile)
    protected
        // 形成DLL文件列表
        function BuildLanguageList:Boolean; override;

        procedure SetLanguageName(const Value:string); override;
    public
        constructor Create;
        destructor Destroy; override;
    end;

implementation

uses SysUtils, Math, ComCtrls, Windows;

{ TFormLanguage }

procedure TMutilLanguageFile.BuildDefaultMessage;
var
    slTmp:TStringList;
begin
    slTmp := TStringList.Create;
    try
        slTmp.Add('[Message]');
        slTmp.Add('ExistConfig = [ %s ]已存在，请重新输入');
        slTmp.Add('Confirm = 提示');
        slTmp.Add('AutoGetIP = 自动获取');
        slTmp.Add('ConfirmDelConfig = 确定要删除 [ %s ] 配置吗？');
        slTmp.Add('NotExistNetCard = 该配置的网卡不存在，请检查更正');
        slTmp.Add('ConfigChanged = 配置信息已经更改，是否继续切换？');
        slTmp.Add('SelAdapter = 请选择适配器');
        slTmp.Add('InvalidPara = 快捷方式参数无效，请检查');
        slTmp.Add('NotExistConfig = 指定的默认应用配置不存在，请检查');
        slTmp.Add('ConfirmSave = 配置信息已经更改，是否保存到文件中？');
        slTmp.Add('NewConfig = 新配置%s');
        slTmp.Add('PLSCheck = ,请检查');
        slTmp.Add('EConnect = 连接失败');
        slTmp.Add('SConnect = 连接成功,返回%d');
        slTmp.Add('NoConfigName = 配置名称不能为空，请检查');
        slTmp.Add('NoAdapter = 适配器不能为空，请检查');
        slTmp.Add('NoIP = 地址不能为空，请检查');
        slTmp.Add('InvalidIP = IP地址不合法');
        slTmp.Add('NoMask =子网掩码不能为空，请检查');
        slTmp.Add('InvalidMask=子网掩码不合法，请检查');
        slTmp.Add('NoGate=网关不能为空，请检查');
        slTmp.Add('InvalidGate = 网关不合法，请检查');
        slTmp.Add('SameIPGate = 网关和IP相同，请检查');
        slTmp.Add('Segment = 网关和IP不在同一网段，请检查');
        slTmp.Add('NoDNS = DNS地址不能为空，请检查');
        slTmp.Add('InvalidDNS = DNS地址不合法，请检查');
        slTmp.Add('LicensedTo = 授权使用');
        slTmp.Add('ShortCutTitle = IP设置助手配置  %s');
        slTmp.Add('NoRegStop = 未注册版本不提供此项功能，终止搜索');
        slTmp.Add('NoSearchAdapter = 指定的搜索适配器 %s 不存在或尚未连接网络，请参考选项中的配置信息，终止搜索');
        slTmp.Add('OKIPNoSearch = 当前IP可以使用，不需要更新');
        slTmp.Add('PreApply = 准备应用配置[ %s ]');
        slTmp.Add('NoMatchAdapter = 配置[ %s ]的适配器和指定适配器不同，跳过');
        slTmp.Add('Appling = 正在应用配置[ %s]');
        slTmp.Add('TestConfig = 配置[ %s ]应用成功, 正在测试连接');
        slTmp.Add('FailApply = 配置[ %s ]应用失败，跳过');
        slTmp.Add('FailConnect = 配置[ %s ]无法连接，跳过');
        slTmp.Add('SuccConnect = 配置[ %s ]连接成功，终止搜索');
        slTmp.Add('WBuild = Build');
        slTmp.Add('AMemory = 可用物理内存：');
        slTmp.Add('ApplingIP = 正在更新IP地址……');
        slTmp.Add('Success = 成功');
        slTmp.Add('Faile = 失败');
        slTmp.Add('LastTime = 耗时 %d ms');
        slTmp.Add('AutoClose = %d s 后自动关闭');
        slTmp.Add('ConfirmDelete = 确定要删除选定数据吗？');
        slTmp.Add('OneMoreIP = 至少需要一个IP地址，请增加');
        slTmp.Add('OneMoreGate = 至少需要一个网关地址，请增加');
        slTmp.Add('MustProxyAdd = 代理服务器地址不能为空，请检查');
        slTmp.Add('MustProxyPort = 代理服务器端口不能为空，请检查');
        slTmp.Add('OneMoreDialSet = 至少需要选择一个拨号设置，请检查');
        slTmp.Add('OneMoreNetBios = 至少需要选择一个NetBios设置，请检查');
        slTmp.Add('Right = 正确');
        slTmp.Add('Testing = 正在测试连接……');
        slTmp.Add('EndTest = 测试完成');
        slTmp.Add('DisableDeving = 正在禁用 %s ……');
        slTmp.Add('EnableDeving = 正在启用 %s ……');
        slTmp.Add('EndDisableDev = 禁用 %s 完成');
        slTmp.Add('EndEnableDev = 启用 %s 完成');
        //slTmp.Add()
        FMemIniFile.SetStrings(slTmp);
        BuildMessage;
    finally
        slTmp.Free;
    end;
end;

function TMutilLanguageFile.BuildLanguageList:Boolean;
var
    nRet:Integer;
    SearchRec:TSearchRec;
    tmpIniFile:TIniFile;
begin
    FLanguageFileList.Clear;
    FLanguageNameList.Clear;
    nRet := FindFirst(FLanguageDir + '*.ini', faAnyFile, SearchRec);
    while nRet = 0 do begin
        tmpIniFile := TIniFile.Create(FLanguageDir + SearchRec.Name);
        try
            if tmpIniFile.ValueExists(HEADERSECTION, 'Language') then begin
                FLanguageNameList.Add(tmpIniFile.ReadString(HEADERSECTION, 'Language', 'error'));
                FLanguageFileList.Add(FLanguageDir + SearchRec.Name);
            end
        finally
            tmpIniFile.Free;
        end;
        nRet := FindNext(SearchRec);
    end;
    SysUtils.FindClose(SearchRec);
    Result := True;
end;

function TMutilLanguageFile.BuildMessage:Boolean;
var
    i:Integer;
begin
    Result := False;
    if not Assigned(FMemIniFile) then Exit;
    if not FMemIniFile.SectionExists(MESSAGESECTION) then Exit;
    FMemIniFile.ReadSection(MESSAGESECTION, FMessageName);
    FMessageValue.Clear;
    for i := 0 to FMessageName.Count - 1 do begin
        FMessageValue.Add(FMemIniFile.ReadString(MESSAGESECTION, FMessageName.Strings[i], 'language error'));
    end;
    Result := True;
end;

constructor TMutilLanguageFile.Create;
begin
    inherited;
    FLanguageFileList := THashedStringList.Create;
    Initialize;
    BuildDefaultMessage;
end;

destructor TMutilLanguageFile.Destroy;
var
    tmp:TStringList;
begin
    //.. 临时用来保存修改结果用的
    if Assigned(FMemIniFile) and FileExists(FLangFile) then begin
        tmp := TStringList.Create;
        try
            FMemIniFile.GetStrings(tmp);
            tmp.SaveToFile(FLangFile);
        finally
            tmp.Free;
        end;
    end;

    FLanguageFileList.Free;
    inherited;
end;

procedure TMutilLanguageFile.Initialize;
begin
    inherited;
    FLanguageFileList.Clear;
    FLanguageDir := ExtractFilePath(ParamStr(0)) + 'Lang\';
    BuildLanguageList;
end;

procedure TMutilLanguageFile.SetLanguageDir(const Value:string);
begin
    if Value = FLanguageDir then Exit;
    if not DirectoryExists(Value) then Exit;
    FLanguageDir := Value;
    BuildLanguageList;
end;

procedure TMutilLanguageFile.SetLanguageName(const Value:string);
var
    slTmp:TStringList;
    nIndex:Integer;
begin
    nIndex := FLanguageNameList.IndexOf(Value);
    if nIndex < 0 then Exit;

    slTmp := TStringList.Create;
    try
        FLangFile := FLanguageFileList.Strings[nIndex];
        slTmp.LoadFromFile(FLangFile);
        FMemIniFile.SetStrings(slTmp);
        BuildMessage;
    finally
        slTmp.Free;
    end;
end;

{ TMutilLanguage }

function TMutilLanguage.BuildLanguageList:Boolean;
begin
    Result := True;
end;

function TMutilLanguage.BuildMessage:Boolean;
begin
    Result := True;
end;

constructor TMutilLanguage.Create;
begin
    FLanguageNameList := THashedStringList.Create;
    FMessageName := THashedStringList.Create;
    FMessageValue := THashedStringList.Create;
    FMemIniFile := TMemIniFile.Create('');
end;

destructor TMutilLanguage.Destroy;
begin
    FMessageValue.Free;
    FMessageName.Free;
    FMemIniFile.Free;
    FLanguageNameList.Free;
    inherited;
end;

function TMutilLanguage.GetMessage(AMessageName:string):string;
var
    nIndex:Integer;
begin
    Result := '';
    nIndex := FMessageName.IndexOf(AMessageName);
    if nIndex = -1 then Exit;
    if nIndex > FMessageValue.Count - 1 then Exit;
    Result := FMessageValue.Strings[nIndex];
end;

procedure TMutilLanguage.Initialize;
begin
    FLanguageNameList.Clear;
    FMessageName.Clear;
    FMessageValue.Clear;
end;

procedure TMutilLanguage.SetLanguageName(const Value:string);
begin

end;

function TMutilLanguage.UpdateFormLanguage(AForm:TForm):Integer;
var
    i:Integer;
    com:TComponent;
    strSection:string;
    slSection:TStrings;
begin
    Result := -1;
    if FLanguageNameList.Count = 0 then Exit;

    Result := -2;
    if not Assigned(AForm) then Exit;

    Result := -3;
    if not Assigned(FMemIniFile) then Exit;

    Result := -4;
    // 不存在就不更新了
    strSection := AForm.Name;
    slSection := TStringList.Create;
    try
        FMemIniFile.ReadSections(slSection);
        if slSection.IndexOf(strSection) < 0 then Exit;
    finally
        slSection.Free;
    end;

    // if not FMemIniFile.SectionExists(strSection) then Exit;
    // 用这个有问题，nnd

    // 生效
    Result := -5;
    // Caption
    AForm.Caption := UpdateFormLanguage(strSection, 'Caption', AForm.Caption);
    for i := 0 to AForm.ComponentCount - 1 do begin
        com := TComponent(AForm.Components[i]);
        if UpdateFormLanguage(strSection, Com) <> 0 then Exit;
    end;

    Result := 0;
end;

function TMutilLanguage.UpdateFormLanguage(ASectionName:string; AResString:string; DefaultValue:string):string;
begin
    //.. 以后这里要删除的，至少为了编程方便
    //if FMemIniFile.ValueExists(ASectionName, AResString) then
    Result := FMemIniFile.ReadString(ASectionName, AResString, 'language Error')
        //else
        //FMemIniFile.WriteString(ASectionName, AResString, DefaultValue)
end;

function TMutilLanguage.UpdateFormLanguage(AFormName:string; AComponent:TComponent):Integer;
var
    strComName:string;
    strDefault:string;
    strTmp:string;
    i:Integer;
begin
    Result := -1;
    if not Assigned(AComponent) then Exit;

    Result := -2;
    if Trim(AFormName) = '' then Exit;

    if AComponent is TLabel then begin
        strComName := TLabel(AComponent).Name + '';
        strDefault := TLabel(AComponent).Caption;
        TLabel(AComponent).Caption := UpdateFormLanguage(AFormName, strComName, strDefault);
    end
    else if AComponent is TAction then begin
        strComName := TAction(AComponent).Name + '';
        strDefault := TAction(AComponent).Caption;
        TAction(AComponent).Caption := UpdateFormLanguage(AFormName, strComName, strDefault);
        strComName := TAction(AComponent).Name + '.Hint';
        strDefault := TAction(AComponent).Hint;
        TAction(AComponent).Hint := UpdateFormLanguage(AFormName, strComName, strDefault);
    end
    else if AComponent is TGroupBox then begin
        strComName := TGroupBox(AComponent).Name + '';
        strDefault := TGroupBox(AComponent).Caption;
        TGroupBox(AComponent).Caption := UpdateFormLanguage(AFormName, strComName, strDefault);
    end
    else if AComponent is TRadioButton then begin
        strComName := TRadioButton(AComponent).Name + '';
        strDefault := TRadioButton(AComponent).Caption;
        TRadioButton(AComponent).Caption := UpdateFormLanguage(AFormName, strComName, strDefault);
    end
    else if AComponent is TCustomListView then begin
        strComName := TListView(AComponent).Name;
        strDefault := '';
        for i := 0 to TListView(AComponent).Columns.Count - 1 do begin
            strDefault := strDefault + TListView(AComponent).Column[i].Caption + '|';
        end;

        strTmp := UpdateFormLanguage(AFormName, strComName, strDefault);
        strTmp := strTmp + '|';
        for i := 0 to TListView(AComponent).Columns.Count - 1 do begin
            TListView(AComponent).Column[i].Caption := Copy(strTmp, 0, Pos('|', strTmp) - 1);
            Delete(strTmp, 1, Pos('|', strTmp));
        end;
    end;
    Result := 0;
end;

{ TMutilLanguageDLLFile }

function TMutilLanguageFileDLL.BuildLanguageList: Boolean;
var
    nRet:Integer;
    SearchRec:TSearchRec;
    tmpIniFile:TIniFile;
begin
    FLanguageFileList.Clear;
    FLanguageNameList.Clear;
    nRet := FindFirst(FLanguageDir + '*.dll', faAnyFile, SearchRec);
    while nRet = 0 do begin
        tmpIniFile := TIniFile.Create(FLanguageDir + SearchRec.Name);
        try
            if tmpIniFile.ValueExists(HEADERSECTION, 'Language') then begin
                FLanguageNameList.Add(tmpIniFile.ReadString(HEADERSECTION, 'Language', 'error'));
                FLanguageFileList.Add(FLanguageDir + SearchRec.Name);
            end
        finally
            tmpIniFile.Free;
        end;
        nRet := FindNext(SearchRec);
    end;
    SysUtils.FindClose(SearchRec);
    Result := True;
end;

constructor TMutilLanguageFileDLL.Create;
begin
    inherited;

end;

destructor TMutilLanguageFileDLL.Destroy;
begin

    inherited;
end;

procedure TMutilLanguageFileDLL.SetLanguageName(const Value: string);
var
    slTmp:TStringList;
    nIndex:Integer;
begin
    nIndex := FLanguageNameList.IndexOf(Value);
    if nIndex < 0 then Exit;

    slTmp := TStringList.Create;
    try
        FLangFile := FLanguageFileList.Strings[nIndex];
        slTmp.LoadFromFile(FLangFile);
        FMemIniFile.SetStrings(slTmp);
        BuildMessage;
    finally
        slTmp.Free;
    end;
end;

end.

