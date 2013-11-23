unit uMutilLanguage;

interface

uses
    iniFiles, Forms, Classes, Controls, Graphics, stdCtrls, ActnList;

const
    MESSAGESECTION:string = 'Message';
    HEADERSECTION:string = 'Language';

type
    // ��ȡ���԰汾
    TGetLanguageACP = function(var ALanguageName:PChar):Integer; stdcall;
    // ��ȡ��������
    TGetLanguageString = function: PChar; stdcall;

    TMutilLanguage = class
    protected
        FMemIniFile:TMemIniFile;
        // �����б�
        FLanguageNameList:THashedStringList;
        // ��Ϣ�б�
        FMessageName:THashedStringList;
        FMessageValue:THashedStringList;

        // �γ�ini�ļ��б�
        function BuildLanguageList:Boolean; virtual;
        // ��ini�ļ��ж�ȡ������Ϣ�б�
        function BuildMessage:Boolean; virtual;
        // ��ʼ��
        procedure Initialize; virtual;
        procedure SetLanguageName(const Value:string); virtual;
    public
        constructor Create;
        destructor Destroy; override;
        // ��Ч����
        function UpdateFormLanguage(AForm:TForm):Integer; overload; virtual;
        function UpdateFormLanguage(AFormName:string; AComponent:TComponent):Integer; overload; virtual;
        function UpdateFormLanguage(ASectionName:string; AResString:string; DefaultValue:string = ''):string; overload; virtual;
        // ȡ����Ϣ�ַ�
        function GetMessage(AMessageName:string):string; virtual;
    published
        property LanguageName:string write SetLanguageName;
        property LanguageList:THashedStringList read FLanguageNameList;
    end;

    TMutilLanguageFile = class(TMutilLanguage)
    protected
        FLanguageDir:string; // ����·����Ĭ��Ϊ��ǰ·����Lang
        FLangFile:string; // �ļ���
        // �ɶԳ��ֵ�Ŀ���Ǳ��ڼ���
        FLanguageFileList:THashedStringList;

        // �γ�ini�ļ��б�
        function BuildLanguageList:Boolean; override;
        // ��ini�ļ��ж�ȡ������Ϣ�б�
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
        // �γ�DLL�ļ��б�
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
        slTmp.Add('ExistConfig = [ %s ]�Ѵ��ڣ�����������');
        slTmp.Add('Confirm = ��ʾ');
        slTmp.Add('AutoGetIP = �Զ���ȡ');
        slTmp.Add('ConfirmDelConfig = ȷ��Ҫɾ�� [ %s ] ������');
        slTmp.Add('NotExistNetCard = �����õ����������ڣ��������');
        slTmp.Add('ConfigChanged = ������Ϣ�Ѿ����ģ��Ƿ�����л���');
        slTmp.Add('SelAdapter = ��ѡ��������');
        slTmp.Add('InvalidPara = ��ݷ�ʽ������Ч������');
        slTmp.Add('NotExistConfig = ָ����Ĭ��Ӧ�����ò����ڣ�����');
        slTmp.Add('ConfirmSave = ������Ϣ�Ѿ����ģ��Ƿ񱣴浽�ļ��У�');
        slTmp.Add('NewConfig = ������%s');
        slTmp.Add('PLSCheck = ,����');
        slTmp.Add('EConnect = ����ʧ��');
        slTmp.Add('SConnect = ���ӳɹ�,����%d');
        slTmp.Add('NoConfigName = �������Ʋ���Ϊ�գ�����');
        slTmp.Add('NoAdapter = ����������Ϊ�գ�����');
        slTmp.Add('NoIP = ��ַ����Ϊ�գ�����');
        slTmp.Add('InvalidIP = IP��ַ���Ϸ�');
        slTmp.Add('NoMask =�������벻��Ϊ�գ�����');
        slTmp.Add('InvalidMask=�������벻�Ϸ�������');
        slTmp.Add('NoGate=���ز���Ϊ�գ�����');
        slTmp.Add('InvalidGate = ���ز��Ϸ�������');
        slTmp.Add('SameIPGate = ���غ�IP��ͬ������');
        slTmp.Add('Segment = ���غ�IP����ͬһ���Σ�����');
        slTmp.Add('NoDNS = DNS��ַ����Ϊ�գ�����');
        slTmp.Add('InvalidDNS = DNS��ַ���Ϸ�������');
        slTmp.Add('LicensedTo = ��Ȩʹ��');
        slTmp.Add('ShortCutTitle = IP������������  %s');
        slTmp.Add('NoRegStop = δע��汾���ṩ����ܣ���ֹ����');
        slTmp.Add('NoSearchAdapter = ָ�������������� %s �����ڻ���δ�������磬��ο�ѡ���е�������Ϣ����ֹ����');
        slTmp.Add('OKIPNoSearch = ��ǰIP����ʹ�ã�����Ҫ����');
        slTmp.Add('PreApply = ׼��Ӧ������[ %s ]');
        slTmp.Add('NoMatchAdapter = ����[ %s ]����������ָ����������ͬ������');
        slTmp.Add('Appling = ����Ӧ������[ %s]');
        slTmp.Add('TestConfig = ����[ %s ]Ӧ�óɹ�, ���ڲ�������');
        slTmp.Add('FailApply = ����[ %s ]Ӧ��ʧ�ܣ�����');
        slTmp.Add('FailConnect = ����[ %s ]�޷����ӣ�����');
        slTmp.Add('SuccConnect = ����[ %s ]���ӳɹ�����ֹ����');
        slTmp.Add('WBuild = Build');
        slTmp.Add('AMemory = ���������ڴ棺');
        slTmp.Add('ApplingIP = ���ڸ���IP��ַ����');
        slTmp.Add('Success = �ɹ�');
        slTmp.Add('Faile = ʧ��');
        slTmp.Add('LastTime = ��ʱ %d ms');
        slTmp.Add('AutoClose = %d s ���Զ��ر�');
        slTmp.Add('ConfirmDelete = ȷ��Ҫɾ��ѡ��������');
        slTmp.Add('OneMoreIP = ������Ҫһ��IP��ַ��������');
        slTmp.Add('OneMoreGate = ������Ҫһ�����ص�ַ��������');
        slTmp.Add('MustProxyAdd = �����������ַ����Ϊ�գ�����');
        slTmp.Add('MustProxyPort = ����������˿ڲ���Ϊ�գ�����');
        slTmp.Add('OneMoreDialSet = ������Ҫѡ��һ���������ã�����');
        slTmp.Add('OneMoreNetBios = ������Ҫѡ��һ��NetBios���ã�����');
        slTmp.Add('Right = ��ȷ');
        slTmp.Add('Testing = ���ڲ������ӡ���');
        slTmp.Add('EndTest = �������');
        slTmp.Add('DisableDeving = ���ڽ��� %s ����');
        slTmp.Add('EnableDeving = �������� %s ����');
        slTmp.Add('EndDisableDev = ���� %s ���');
        slTmp.Add('EndEnableDev = ���� %s ���');
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
    //.. ��ʱ���������޸Ľ���õ�
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
    // �����ھͲ�������
    strSection := AForm.Name;
    slSection := TStringList.Create;
    try
        FMemIniFile.ReadSections(slSection);
        if slSection.IndexOf(strSection) < 0 then Exit;
    finally
        slSection.Free;
    end;

    // if not FMemIniFile.SectionExists(strSection) then Exit;
    // ����������⣬nnd

    // ��Ч
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
    //.. �Ժ�����Ҫɾ���ģ�����Ϊ�˱�̷���
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

