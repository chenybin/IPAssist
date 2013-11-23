object AutoSearchForm: TAutoSearchForm
  Left = 193
  Top = 108
  Width = 404
  Height = 276
  BorderIcons = [biHelp]
  Caption = #27491#22312#25628#32034#21487#29992#37197#32622#8230#8230
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object pbPeople: TRzProgressBar
    Left = 12
    Top = 173
    Width = 371
    BackColor = 16119543
    BarColorStop = clGradientActiveCaption
    BarStyle = bsGradient
    BorderInner = fsFlat
    BorderOuter = fsNone
    BorderWidth = 1
    InteriorOffset = 0
    PartsComplete = 0
    Percent = 0
    TotalParts = 0
  end
  object lbInfor: TRzLabel
    Left = 12
    Top = 208
    Width = 6
    Height = 12
  end
  object memStatus: TRzMemo
    Left = 12
    Top = 16
    Width = 371
    Height = 149
    ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
    ScrollBars = ssVertical
    TabOrder = 0
    FrameHotStyle = fsFlat
    FrameHotTrack = True
    FrameVisible = True
  end
  object bbtnCancel: TRzBitBtn
    Left = 307
    Top = 205
    FrameColor = 7617536
    ModalResult = 2
    Caption = #20851#38381'(&E)'
    Color = 15791348
    Enabled = False
    HotTrack = True
    TabOrder = 1
  end
  object tmAutoSearch: TTimer
    Interval = 350
    Left = 260
    Top = 204
  end
  object tmAutoClose: TTimer
    Enabled = False
    Left = 228
    Top = 204
  end
end
