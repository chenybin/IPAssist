unit frmOption;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, RzButton, RzTabs, RzRadChk, StdCtrls, RzCmboBx, uIPAssist,
    RzLabel;

type
    TOptionForm = class(TForm)
        pcMain:TRzPageControl;
        tsBasic:TRzTabSheet;
        btnOK:TRzButton;
        btnCancel:TRzButton;
        cbAutoRun:TRzCheckBox;
        tsPrompt:TRzTabSheet;
        cbAutoSave:TRzCheckBox;
        cbConfirmChangeItem:TRzCheckBox;
        cbAutoTray:TRzCheckBox;
        cbAutoApply:TRzCheckBox;
        cbAutoSearch:TRzCheckBox;
        cbApplyDefault:TRzCheckBox;
        cbConfigList:TRzComboBox;
        cbAdapterList:TRzComboBox;
        cbConfirmDelete:TRzCheckBox;
        tsInterface:TRzTabSheet;
        lbLanguage:TRzLabel;
        cbLanguage:TRzComboBox;
        lbListViewStyle:TRzLabel;
        cbListStyle:TRzComboBox;
        lbTrayMenu:TRzLabel;
        cbTrayMenu:TRzComboBox;
        cbAutoPing:TRzCheckBox;
        cbCheckValid:TRzCheckBox;
    private
        { Private declarations }
        FLanguageChanged:Boolean;
        procedure UpdateControls;
        procedure InitEvent;
        procedure UpdateLanguage;

        ///////////////  Evant  ////////////////////
        procedure btnOKClick(Sender:TObject);
        procedure cbAutoSearchClick(Sender:TObject);
        procedure cbLanguageChange(Sender:TObject);
        procedure cbApplyDefaultClick(Sender:TObject);
        /////////////////////////////////////////////
    public
        { Public declarations }
        constructor Create(AOwner:TComponent; AAdapterList:TStrings; AConfigList:string); reintroduce;
        destructor Destroy; override;
        procedure Initialize;
        property LanguageChanged:Boolean read FLanguageChanged;
    end;

var
    OptionForm:TOptionForm;

implementation
uses
    uSysInfo;
{$R *.dfm}

{ TOptionForm }

constructor TOptionForm.Create(AOwner:TComponent; AAdapterList:TStrings; AConfigList:string);
begin
    inherited Create(AOwner);
    cbAdapterList.Clear;
    cbAdapterList.Items.AddStrings(AAdapterList);
    cbConfigList.Clear;
    cbConfigList.Items.Text := AConfigList;
    Initialize;
end;

destructor TOptionForm.Destroy;
begin

    inherited;
end;

procedure TOptionForm.Initialize;
begin
    InitEvent;
    UpdateLanguage;
    UpdateControls;
    FLanguageChanged := False;
end;

procedure TOptionForm.btnOKClick(Sender:TObject);
begin
    with SysInfo do begin
        AutoRun := cbAutoRun.Checked;
        AutoTray := cbAutoTray.Checked;
        AutoApply := cbAutoApply.Checked;
        AutoSearch := cbAutoSearch.Checked;
        ConfirmChange := cbConfirmChangeItem.Checked;
        ConfirmDelete := cbConfirmDelete.Checked;
        ListStyle := cbListStyle.ItemIndex;
        ApplyDefault := cbApplyDefault.Checked;
        DefaultConfig := cbConfigList.Text;
        SearchAdapter := cbAdapterList.Text;
        AutoSave := cbAutoSave.Checked;
        Language := cbLanguage.Text;
        TrayMenuStyle := cbTrayMenu.ItemIndex;
        AutoPing := cbAutoPing.Checked;
        CheckValid := cbCheckValid.Checked;
    end;
end;

procedure TOptionForm.InitEvent;
begin
    btnOK.OnClick := btnOKClick;
    cbAutoSearch.OnClick := cbAutoSearchClick;
    cbApplyDefault.OnClick := cbApplyDefaultClick;
    cbLanguage.OnChange := cbLanguageChange;
end;

procedure TOptionForm.UpdateControls;
begin
    with SysInfo do begin
        cbAutoRun.Checked := AutoRun;
        cbAutoTray.Checked := AutoTray;
        cbAutoApply.Checked := AutoApply;
        cbAutoSearch.Checked := AutoSearch;
        cbConfirmChangeItem.Checked := ConfirmChange;
        cbConfirmDelete.Checked := ConfirmDelete;
        cbListStyle.ItemIndex := ListStyle;
        // ÊÊÅäÆ÷
        cbAdapterList.ItemIndex := cbAdapterList.Items.IndexOf(SearchAdapter);
        cbAutoSave.Checked := AutoSave;
        // ÓïÑÔ
        cbLanguage.Clear;
        cbLanguage.Items.AddStrings(SysInfo.LanguageList);
        cbLanguage.ItemIndex := cbLanguage.Items.IndexOf(SysInfo.Language);
        // Ä¬ÈÏÅäÖÃ
        cbApplyDefault.Checked := ApplyDefault;
        cbConfigList.ItemIndex := cbConfigList.Items.IndexOf(SysInfo.DefaultConfig);
        // Tray²Ëµ¥
        cbTrayMenu.ItemIndex := TrayMenuStyle;
        cbAutoPing.Checked := AutoPing;
        cbCheckValid.Checked := CheckValid;
    end;
    pcMain.ActivePageIndex := 0;
end;

procedure TOptionForm.UpdateLanguage;
var
    i:Integer;
    AComponent:TComponent;
    AFormName:string;
    strComName:string;
    strDefault:string;
    strTmp:string;
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
        end
        else if AComponent is TRzCheckBox then begin
            strComName := TRzCheckBox(AComponent).Name + '';
            if AComponent is TCustomCheckBox then begin
                strDefault := '';
            end;
            strDefault := TRzCheckBox(AComponent).Caption;
            TRzCheckBox(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end
        else if AComponent is TRzTabSheet then begin
            strComName := TRzTabSheet(AComponent).Name + '';
            strDefault := TRzTabSheet(AComponent).Caption;
            TRzTabSheet(AComponent).Caption := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
        end
        else if AComponent is TRzComboBox then begin
            strComName := TRzComboBox(AComponent).Name + '';
            if (strComName = 'cbTrayMenu') or (strComName = 'cbListStyle') then begin
                strDefault := TRzComboBox(AComponent).Items.Text;

                strTmp := SysInfo.UpdateFormLanguage(AFormName, strComName, strDefault);
                strTmp := strTmp + '|';
                TRzComboBox(AComponent).Items.Clear;
                while Pos('|', strTmp) > 0 do begin
                    TRzComboBox(AComponent).Items.Add(Copy(strTmp, 0, Pos('|', strTmp) - 1));
                    Delete(strTmp, 1, Pos('|', strTmp));
                end;
            end;
        end;
    end;
end;

procedure TOptionForm.cbAutoSearchClick(Sender:TObject);
begin
    cbAdapterList.Enabled := (cbAutoSearch).Checked;
    cbApplyDefault.Enabled := not (cbAutoSearch).Checked;
end;

procedure TOptionForm.cbLanguageChange(Sender:TObject);
var
    nIndex1, nIndex2:Integer;
begin
    SysInfo.Language := cbLanguage.Text;
    nIndex1 := cbListStyle.ItemIndex;
    nIndex2 := cbTrayMenu.ItemIndex;
    UpdateLanguage;
    cbListStyle.ItemIndex := nIndex1;
    cbTrayMenu.ItemIndex := nIndex2;
    FLanguageChanged := True;
end;

procedure TOptionForm.cbApplyDefaultClick(Sender:TObject);
begin
    cbConfigList.Enabled := (cbApplyDefault).Checked;
    cbAutoSearch.Enabled := not (cbApplyDefault).Checked;
end;

end.

