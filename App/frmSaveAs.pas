unit frmSaveAs;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, RzButton, StdCtrls, Mask, RzEdit, RzLabel, uIPAssist;

type
    TSaveAsForm = class(TForm)
        lbConfigName:TRzLabel;
        edtNewConfigName:TRzEdit;
        btnOK:TRzButton;
        btnCancel:TRzButton;
    private
        { Private declarations }
        FIPSetUtil:TIPSetUtil;
        function FCheck:Boolean;
        procedure UpdateControls;
        procedure InitEvent;
        procedure UpdateLanguage;

        procedure btnOKClick(Sender:TObject);
    public
        { Public declarations }
        constructor Create(AOwner:TComponent; AIPSetUtil:TIPSetUtil); reintroduce;
        procedure Initiliaze;
    end;

var
    SaveAsForm:TSaveAsForm;

implementation
uses
    uSysInfo;

{$R *.dfm}

{ TSaveAsForm }

function TSaveAsForm.FCheck:Boolean;
var
    nPos:Integer;
    strMsg:string;
begin
    Result := False;
    if Trim(edtNewConfigName.Text) = '' then begin
        SysInfo.ShowMLMessage('NoConfigName');
        edtNewConfigName.SetFocus;
        Exit;
    end;
    nPos := FIPSetUtil.IPConfigExist(edtNewConfigName.Text);
    if (nPos <> -1) then begin
        strMsg := SysInfo.GetMessage('ExistConfig', '%s');
        strMsg := Format(strMsg, [edtNewConfigName.Text]);
        SysInfo.ShowMLMessage(strMsg);
        edtNewConfigName.SetFocus;
        Exit;
    end;
    Result := True;
end;

constructor TSaveAsForm.Create(AOwner:TComponent; AIPSetUtil:TIPSetUtil);
begin
    inherited Create(AOwner);
    FIPSetUtil := AIPSetUtil;
    Initiliaze;
end;

procedure TSaveAsForm.InitEvent;
begin
    btnOK.OnClick := btnOKClick;
end;

procedure TSaveAsForm.UpdateControls;
var
    strTmp:string;
begin
    strTmp := SysInfo.GetMessage('NewConfig', '%s');
    edtNewConfigName.Text := Format(strTmp, [FormatDateTime('yymmddhhnnss', Now)]);
end;

procedure TSaveAsForm.UpdateLanguage;
begin
    SysInfo.UpdateFormLanguage(Self);
end;

procedure TSaveAsForm.btnOKClick(Sender:TObject);
begin
    if not FCheck then begin
        ModalResult := mrNone;
        Exit;
    end;
end;

procedure TSaveAsForm.Initiliaze;
begin
    InitEvent;
    UpdateLanguage;
    UpdateControls;
end;

end.

