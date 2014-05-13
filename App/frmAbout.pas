unit frmAbout;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, jpeg, ExtCtrls, RzButton;

type
    TAboutForm = class(TForm)
        Panel1:TPanel;
        Image1:TImage;
        lbAppName:TLabel;
        lbVersion:TLabel;
        lbCopyRight:TLabel;
        memDescription:TMemo;
        Bevel1:TBevel;
        lbSystemInfo:TLabel;
        btnOK:TRzBitBtn;
        btnBug:TRzBitBtn;
        procedure btnBugClick(Sender:TObject);
    private
        { Private declarations }
        procedure lbCopyRightClick(Sender:TObject);
        procedure UpdateControls;
        procedure InitEvent;
        procedure UpdateLanguage;
    public
        { Public declarations }
        constructor Create(AOwner:TComponent); override;
        procedure Initiliaze;
    end;

var
    AboutForm:TAboutForm;

implementation
uses
    Shellapi, uUtiles, uSysInfo;
{$R *.dfm}

procedure TAboutForm.lbCopyRightClick(Sender:TObject);
begin
    ShellExecute(handle, 'open', 'mailto:chenybin@126.com?subject=IP助手问题', nil, nil, SW_SHOW);
end;

constructor TAboutForm.Create(AOwner:TComponent);
begin
    inherited;

    Initiliaze;
end;

procedure TAboutForm.InitEvent;
begin
    lbCopyRight.OnClick := lbCopyRightClick;
end;

procedure TAboutForm.UpdateControls;
var
    strProduct, strVersion, strServicePack:string;
    meminfo:TMemoryStatus;
    v1, v2, v3, v4:Word;
    strTmp:string;
begin
    // 文件版本
    GetBuildInfo(v1, v2, v3, v4);
    strTmp := SysInfo.GetMessage('WBuild') + '%d.%d.%d.%d';
    lbVersion.Caption := Format(strTmp, [v1, v2, v3, v4]);
    lbCopyRight.Caption := 'Create By chenybin@126.com';
    lbAppName.Caption := Application.Title;
    // windows 版本
    GetVersionInfo(strProduct, strVersion, strServicePack);
    GlobalMemoryStatus(meminfo);
    strTmp := '%s  '#13#10'(Build %s %s)'#13#10#13#10 + SysInfo.GetMessage('AMemory') + '：%d KB';
    lbSystemInfo.Caption := Format(strTmp, [strProduct, strVersion, strServicePack,
        meminfo.dwTotalPhys div 1024]);
end;

procedure TAboutForm.UpdateLanguage;
var
    i:Integer;
    AComponent:TComponent;
    AFormName:string;
    strComName:string;
    strDefault:string;
begin
    SysInfo.UpdateFormLanguage(Self);
    if SysInfo.LanguageList.Count = 0 then Exit;
    AFormName := Self.Name;

    for i := 0 to Self.ComponentCount - 1 do begin
        AComponent := TComponent(Self.Components[i]);

        if AComponent is TRzBitBtn then begin
            strComName := TRzBitBtn(AComponent).Name + '';
            strDefault := TRzBitBtn(AComponent).Caption;
            TRzBitBtn(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end;
    end;
end;

procedure TAboutForm.Initiliaze;
begin
    InitEvent;
    UpdateLanguage;
    UpdateControls;
end;

procedure TAboutForm.btnBugClick(Sender:TObject);
var
    slBody:TStringList;
begin
    slBody := TStringList.Create;
    try
        slBody.Add('Hi');
        slBody.Add('   Your Application ' + Application.Title + '  has some bugs.');
        slBody.Add('   Bug Description:');
        slBody.Add('   ');
        slBody.Add('   ');
        slBody.Add('   ');
        SendMail('chenybin@126.com', 'Bug Report:' + Application.Title, slBody);
    finally
        slBody.Free;
    end;
end;

end.

