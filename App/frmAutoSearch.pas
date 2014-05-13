unit frmAutoSearch;

interface

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, uIPAssist, RzLabel, ExtCtrls, RzButton, RzEdit,
    RzPrgres, uTrayIcon;

type
    TAutoSearchForm = class(TForm)
        tmAutoSearch:TTimer;
        pbPeople:TRzProgressBar;
        memStatus:TRzMemo;
        bbtnCancel:TRzBitBtn;
        tmAutoClose:TTimer;
        lbInfor:TRzLabel;

    private
        { Private declarations }
        FIPSetUtil:TIPSetUtil;
        FOldTime:Cardinal;
        TrayIcon:TTrayIcon;
        procedure Search;
        procedure UpdateControls;
        procedure InitEvent;
        procedure UpdateLanguage;
        procedure OnProcess(AInfor:string; APosition:Integer; AFinished:Boolean);
        procedure tmAutoSearchTimer(Sender:TObject);
        procedure tmAutoCloseTimer(Sender:TObject);
    public
        { Public declarations }
        constructor Create(AOwner:TComponent; IPSetUtil:TIPSetUtil); reintroduce;
        destructor Destroy; override;
        procedure Initialize;
    end;

var
    AutoSearchForm:TAutoSearchForm;

implementation
uses
    uSysInfo;
{$R *.dfm}

{ TAutoSearchForm }

constructor TAutoSearchForm.Create(AOwner:TComponent; IPSetUtil:TIPSetUtil);
begin
    inherited Create(AOwner);
    FIPSetUtil := IPSetUtil;
    FIPSetUtil.OnProcess := OnProcess;
    TrayIcon := TTrayIcon.Create(Self);
    Initialize;
end;

destructor TAutoSearchForm.Destroy;
begin
    TrayIcon.Free;
    inherited;
end;

procedure TAutoSearchForm.OnProcess(AInfor:string; APosition:Integer; AFinished:Boolean);
begin
    if AInfor <> '' then begin
        memStatus.Lines.Add(AInfor);
        TrayIcon.BalloonTipInfo := AInfor;
        TrayIcon.ShowBalloonTip := True;
    end;

    pbPeople.Percent := APosition;
    Invalidate;
    if AFinished then begin
        FOldTime := GetTickCount;
        tmAutoClose.Enabled := True;
    end;
end;

procedure TAutoSearchForm.Search;
begin
    FIPSetUtil.AutoSearch(SysInfo.SearchAdapter);
    bbtnCancel.Enabled := True;
end;

procedure TAutoSearchForm.tmAutoSearchTimer(Sender:TObject);
begin
    // 加这个东西的目的是为了在界面显示出来以后才进行搜索
    if GetTickCount - FOldTime > 800 then begin
        Search;
        TTimer(Sender).Enabled := False;
    end;
end;

procedure TAutoSearchForm.tmAutoCloseTimer(Sender:TObject);
begin
    if GetTickCount - FOldTime > 10000 then begin
        Close;
    end;
    lbInfor.Caption := Format(SysInfo.GetMessage('AutoClose', '%d'), [11 - Round((GetTickCount - FOldTime) / 1000)]);
end;

procedure TAutoSearchForm.InitEvent;
begin
    tmAutoSearch.OnTimer := tmAutoSearchTimer;
    tmAutoClose.OnTimer := tmAutoCloseTimer;
end;

procedure TAutoSearchForm.Initialize;
begin
    FOldTime := GetTickCount;
    InitEvent;
    UpdateLanguage;
    UpdateControls;
end;

procedure TAutoSearchForm.UpdateControls;
begin
    tmAutoClose.Enabled := False;
    lbInfor.Caption := '';
end;

procedure TAutoSearchForm.UpdateLanguage;
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
        end
    end;
end;

end.

