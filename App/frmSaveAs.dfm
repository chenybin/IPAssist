object SaveAsForm: TSaveAsForm
  Left = 294
  Top = 257
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #37197#32622#21517#31216
  ClientHeight = 109
  ClientWidth = 291
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
  object lbConfigName: TRzLabel
    Left = 12
    Top = 20
    Width = 66
    Height = 12
    Caption = #37197#32622#21517#31216'(&C)'
    FocusControl = edtNewConfigName
  end
  object edtNewConfigName: TRzEdit
    Left = 12
    Top = 39
    Width = 265
    Height = 20
    FrameHotTrack = True
    FrameHotStyle = fsFlat
    FrameSides = [sdBottom]
    FrameVisible = True
    ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
    TabOrder = 0
  end
  object btnOK: TRzButton
    Left = 116
    Top = 65
    Default = True
    FrameColor = 7617536
    ModalResult = 1
    Caption = #30830#23450'(&O)'
    Color = 15791348
    HotTrack = True
    TabOrder = 1
  end
  object btnCancel: TRzButton
    Left = 203
    Top = 65
    Cancel = True
    FrameColor = 7617536
    ModalResult = 2
    Caption = #21462#28040'(&C)'
    Color = 15791348
    HotTrack = True
    TabOrder = 2
  end
end
