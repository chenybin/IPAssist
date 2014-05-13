object ApplyForm: TApplyForm
  Left = 193
  Top = 108
  Width = 384
  Height = 225
  BorderIcons = []
  Caption = #27491#22312#24212#29992#37197#32622
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object lbAdapter: TRzLabel
    Left = 20
    Top = 20
    Width = 72
    Height = 12
    Caption = #36866#37197#22120#21517#31216#65306
  end
  object lbAdapterName: TRzLabel
    Left = 106
    Top = 20
    Width = 257
    Height = 22
    AutoSize = False
    Caption = ' '
    WordWrap = True
  end
  object lbStatus: TRzLabel
    Left = 19
    Top = 144
    Width = 6
    Height = 12
  end
  object lbIP: TRzLabel
    Left = 43
    Top = 48
    Width = 48
    Height = 12
    Alignment = taRightJustify
    Caption = 'IP'#22320#22336#65306
  end
  object lbMask: TRzLabel
    Left = 31
    Top = 64
    Width = 60
    Height = 12
    Alignment = taRightJustify
    Caption = #23376#32593#25513#30721#65306
  end
  object lbGateway: TRzLabel
    Left = 31
    Top = 81
    Width = 60
    Height = 12
    Alignment = taRightJustify
    Caption = #40664#35748#32593#20851#65306
  end
  object lbPrimaryDNS: TRzLabel
    Left = 49
    Top = 97
    Width = 42
    Height = 12
    Alignment = taRightJustify
    Caption = #20027'DNS'#65306
  end
  object lbSecondaryDNS: TRzLabel
    Left = 49
    Top = 114
    Width = 42
    Height = 12
    Alignment = taRightJustify
    Caption = #27425'DNS'#65306
  end
  object bbtnOK: TRzBitBtn
    Left = 189
    Top = 161
    FrameColor = 7617536
    Caption = #24212#29992'(&O)'
    Color = 15791348
    HotTrack = True
    TabOrder = 3
    OnClick = bbtnOKClick
  end
  object bbtnCancel: TRzBitBtn
    Left = 283
    Top = 161
    FrameColor = 7617536
    ModalResult = 2
    Caption = #20851#38381'(&E)'
    Color = 15791348
    HotTrack = True
    TabOrder = 4
  end
  object memSource: TRzMemo
    Left = 95
    Top = 46
    Width = 123
    Height = 85
    Alignment = taRightJustify
    BorderStyle = bsNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
    Lines.Strings = (
      '192.192.192.19'
      '2'
      'asfdasdfasdf'
      'asfd')
    ParentFont = False
    TabOrder = 0
  end
  object memDest: TRzMemo
    Left = 240
    Top = 46
    Width = 126
    Height = 85
    BorderStyle = bsNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
    Lines.Strings = (
      '192.192.192.192'
      'g'
      'ag'
      'h')
    ParentFont = False
    TabOrder = 1
  end
  object memArrow: TRzMemo
    Left = 218
    Top = 46
    Width = 23
    Height = 85
    Alignment = taCenter
    BorderStyle = bsNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
    Lines.Strings = (
      '=>'
      '=>'
      '=>'
      '=>'
      '=>'
      '=>'
      '=>'
      '=>')
    ParentFont = False
    TabOrder = 2
  end
  object tmApply: TTimer
    Interval = 350
    Left = 212
  end
end
