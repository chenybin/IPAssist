program IPAssist;

{$R 'uac.res' 'uac.rc'}
{%File 'res/UAC.manifest'}

uses
  Forms,
    Windows,
    sysutils,
    uUtiles in 'uUtiles.pas',
    frmAbout in 'frmAbout.pas' {AboutForm},
    frmIPDetail in 'frmIPDetail.pas' {IPDetailForm},
    frmOption in 'frmOption.pas' {OptionForm},
    IPEdit in 'IPEdit.pas',
    IPHlpapi in 'IPHlpapi.pas',
    Main in 'Main.pas' {MainForm},
    SetupApi in 'SetupApi.pas',
    uDevice in 'uDevice.pas',
    uICMPUtil in 'uICMPUtil.pas',
    uIPAssist in 'uIPAssist.pas',
    uIPHintWindow in 'uIPHintWindow.pas',
    frmIPInput in 'frmIPInput.pas' {IPInputForm},
    uTrayIcon in 'uTrayIcon.pas',
    uSysInfo in 'uSysInfo.pas',
    uMutilLanguage in 'uMutilLanguage.pas',
    frmApply in 'frmApply.pas' {ApplyForm},
    frmAutoSearch in 'frmAutoSearch.pas' {AutoSearchForm},
    uPingThread in 'uPingThread.pas',
    uSystemInfo in 'uSystemInfo.pas',
    frmRegistry in 'frmRegistry.pas' {RegistryForm},
    uHDInfo in 'uHDInfo.pas',
    frmSaveAs in 'frmSaveAs.pas' {SaveAsForm};

{$R *.res}

begin
    Application.Initialize;
    Application.Title := 'IP Assistant';
    CheckParentProc;
    SysInfo := TSysInfo.Create;
    try
        Application.CreateForm(TMainForm, MainForm);
        Application.Run;
    finally
        SysInfo.Free;
    end;
end.

