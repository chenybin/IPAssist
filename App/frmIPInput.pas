unit frmIPInput;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, RzButton, RzCommon, StdCtrls, Mask, RzEdit, RzLabel, ExtCtrls,
    ImgList;

type
    TIPInputForm = class(TForm)
        btnOK:TRzButton;
        btnCancel:TRzButton;
        Image1:TImage;
        lbIP:TRzLabel;
        lbMask:TRzLabel;
        edtMask:TRzEdit;
        edtIP:TRzEdit;
        RzFrameController1:TRzFrameController;
        imgIP:TImage;
        ImageList1:TImageList;
        imgMask:TImage;
    private
        { Private declarations }
        procedure edtIPChange(Sender:TObject);
        procedure btnOKClick(Sender:TObject);
        procedure InitEvent;
        procedure UpdateControls;
        procedure UpdateLanguage;
        function FCheck:Boolean;
    public
        { Public declarations }
        constructor Create(AOwner:TComponent); override;
        procedure Initialize(_IP, _Mask:string; bHaveMaks:Boolean = False);
    end;

var
    IPInputForm:TIPInputForm;

implementation
uses
    uICMPUtil, uSysInfo;
{$R *.dfm}

{ TIPInputForm }

constructor TIPInputForm.Create(AOwner:TComponent);
begin
    inherited Create(AOwner);
end;

procedure TIPInputForm.edtIPChange(Sender:TObject);
var
    strIP:string;
    imgName:string;
    img:TImage;
    bValid:Boolean;
begin
    strIP := TEdit(Sender).Text;
    imgName := StringReplace(TEdit(Sender).Name, 'edt', 'img', []);
    img := TImage(FindComponent(imgName));
    if Assigned(img) then begin

        with img.Picture.Bitmap do begin
            Width := ImageList1.Width;
            Height := ImageList1.Height;
            PixelFormat := pf24bit;
        end;
        img.Canvas.FillRect(img.Canvas.ClipRect);
        bValid := (Trim(strIP) <> '') and TICMPUtil.CheckIPValid(strIP);
        if bValid then begin
            ImageList1.Draw(img.Canvas, 0, 0, 1);
            img.Hint := SysInfo.GetMessage('Right');
        end
        else begin
            ImageList1.Draw(img.Canvas, 0, 0, 0);
            img.Hint := SysInfo.GetMessage('InvalidIP');
        end;
    end;
end;

function TIPInputForm.FCheck:Boolean;
begin
    Result := False;
    if Trim(edtIP.Text) = '' then begin
        SysInfo.ShowMLMessage('NoIP');
        edtIP.SetFocus;
        Exit;
    end;

    if not TICMPUtil.CheckIPValid(edtIP.Text) then begin
        SysInfo.ShowMLMessage('InvlidIP');
        edtIP.SetFocus;
        Exit;
    end;

    if edtMask.Visible then begin
        if Trim(edtMask.Text) = '' then begin
            SysInfo.ShowMLMessage('NoMask');
            edtIP.SetFocus;
            Exit;
        end;

        if not TICMPUtil.CheckIPValid(edtMask.Text) then begin
            SysInfo.ShowMLMessage('InvalidMask');
            edtIP.SetFocus;
            Exit;
        end;
    end;
    Result := True;
end;

procedure TIPInputForm.InitEvent;
begin
    edtMask.OnChange := edtIPChange;
    edtIP.OnChange := edtIPChange;
    btnOK.OnClick := btnOKClick;
end;

procedure TIPInputForm.Initialize(_IP, _Mask:string; bHaveMaks:Boolean);
begin
    lbMask.Visible := bHaveMaks;
    edtMask.Visible := bHaveMaks;
    edtIP.Text := _IP;
    edtMask.Text := _Mask;
    InitEvent;
    UpdateLanguage;
    UpdateControls;
end;

procedure TIPInputForm.btnOKClick(Sender:TObject);
begin
    if not FCheck then ModalResult := mrNone;
end;

procedure TIPInputForm.UpdateControls;
begin

end;

procedure TIPInputForm.UpdateLanguage;
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

end.

