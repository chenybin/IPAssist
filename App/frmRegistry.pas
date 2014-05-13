unit frmRegistry;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, RzButton, StdCtrls, RzLabel, Mask, RzEdit;

type
    TRegistryForm = class(TForm)
        edtMachineCode:TRzEdit;
        edtRegistryCode:TRzEdit;
        edtUserName:TRzEdit;
        lbMacCode:TRzLabel;
        lbRegCode:TRzLabel;
        lbUserName:TRzLabel;
        btnOk:TRzBitBtn;
        lbNote:TRzLabel;
        btnCancel:TRzBitBtn;
        btnSendMail:TRzBitBtn;
        btnPay:TRzBitBtn;
    private
        { Private declarations }
        procedure UpdateControls;
        procedure InitEvent;
        procedure UpdateLanguage;
        procedure Initilize;

        /////////////  Event ///////////////////
        procedure btnOkClick(Sender:TObject);
        procedure btnSendMailClick(Sender:TObject);
        procedure btnPayClick(Sender:TObject);
    public
        { Public declarations }
        constructor Create(AOwner:TComponent); override;
        destructor Destroy; override;
    end;

var
    RegistryForm:TRegistryForm;

implementation
uses
    uSysInfo, uUtiles, ShellAPI;
{$R *.dfm}

{ TRegistryForm }

constructor TRegistryForm.Create(AOwner:TComponent);
begin
    inherited;
    Initilize;
end;

destructor TRegistryForm.Destroy;
begin

    inherited;
end;

procedure TRegistryForm.InitEvent;
begin
    btnOk.OnClick := btnOkClick;
    btnSendMail.OnClick := btnSendMailClick;
    btnPay.OnClick := btnPayClick;
end;

procedure TRegistryForm.Initilize;
begin
    InitEvent;
    UpdateLanguage;
    UpdateControls;
end;

procedure TRegistryForm.UpdateControls;
begin
    edtUserName.Text := SysInfo.UserName;
    edtRegistryCode.Text := SysInfo.RegCode;
    edtMachineCode.Text := SysInfo.SystemInfo.IDESN;
    btnSendMail.Visible := not SysInfo.SystemInfo.wjwj_wjky__aaa;
end;

procedure TRegistryForm.UpdateLanguage;
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
            strComName := TRzBitBtn(AComponent).Name + '.Hint';
            strDefault := TRzBitBtn(AComponent).Hint;
            if strDefault <> '' then
                TRzBitBtn(AComponent).Hint := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end;
    end;
end;

procedure TRegistryForm.btnOkClick(Sender:TObject);
begin
    SysInfo.UserName := edtUserName.Text;
    SysInfo.RegCode := edtRegistryCode.Text;
end;

procedure TRegistryForm.btnSendMailClick(Sender:TObject);
var
    slBody:TStringList;
begin
    slBody := TStringList.Create;
    try
        slBody.Add('Hi,');
        slBody.Add('  I want to register your application which named ' + Application.Title + '.');
        slBody.Add('User Name:' + edtUserName.Text);
        slBody.Add('MachineCode:' + edtMachineCode.Text);
        slBody.Add('');
        SendMail('chenybin@126.com', 'Register Product:' + Application.Title, slBody);
    finally
        slBody.Free;
    end;
end;

procedure TRegistryForm.btnPayClick(Sender:TObject);
var
    URL:string;
begin
    URL := 'http://me.alipay.com/chenybin';
    ShellExecute(GetActiveWindow, 'open', PChar(URL), nil, nil, SW_SHOW)
end;

end.

