object OptionForm: TOptionForm
  Left = 193
  Top = 108
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #31995#32479#37197#32622
  ClientHeight = 274
  ClientWidth = 427
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object pcMain: TRzPageControl
    Left = 8
    Top = 8
    Width = 409
    Height = 221
    ActivePage = tsBasic
    TabIndex = 0
    TabOrder = 0
    FixedDimension = 18
    object tsBasic: TRzTabSheet
      Caption = #24120#35268#35774#32622
      object cbAutoRun: TRzCheckBox
        Left = 41
        Top = 20
        Width = 308
        Height = 17
        Caption = #24320#26426#33258#21160#36816#34892
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 0
      end
      object cbAutoTray: TRzCheckBox
        Left = 41
        Top = 57
        Width = 296
        Height = 17
        Caption = #21551#21160#26102#33258#21160#26368#23567#21270
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 1
      end
      object cbAutoApply: TRzCheckBox
        Left = 41
        Top = 94
        Width = 332
        Height = 17
        Caption = #25171#24320#24212#29992#23545#35805#26694#26102#30452#25509#24212#29992#35774#32622
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 2
      end
      object cbAutoSearch: TRzCheckBox
        Left = 41
        Top = 131
        Width = 193
        Height = 17
        Caption = #21551#21160#26102#25628#32034#35813#36866#37197#22120#21487#29992#37197#32622
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 3
      end
      object cbApplyDefault: TRzCheckBox
        Left = 41
        Top = 168
        Width = 140
        Height = 17
        Caption = #21551#21160#26102#33258#21160#24212#29992#37197#32622
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 5
      end
      object cbConfigList: TRzComboBox
        Left = 236
        Top = 167
        Width = 145
        Height = 20
        Style = csDropDownList
        Ctl3D = False
        Enabled = False
        FlatButtons = True
        FrameHotTrack = True
        FrameHotStyle = fsFlat
        FrameVisible = True
        ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
        ItemHeight = 12
        ParentCtl3D = False
        TabOrder = 6
      end
      object cbAdapterList: TRzComboBox
        Left = 236
        Top = 129
        Width = 145
        Height = 20
        Style = csDropDownList
        Ctl3D = False
        Enabled = False
        FlatButtons = True
        FrameHotTrack = True
        FrameHotStyle = fsFlat
        FrameVisible = True
        ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
        ItemHeight = 12
        ParentCtl3D = False
        TabOrder = 4
      end
    end
    object tsPrompt: TRzTabSheet
      Caption = #25552#31034#20449#24687
      object cbAutoSave: TRzCheckBox
        Left = 41
        Top = 20
        Width = 310
        Height = 17
        Caption = #36864#20986#31995#32479#26102#33258#21160#20445#23384#20869#20462#25913#23481#21040#25991#20214#20013
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 0
      end
      object cbConfirmChangeItem: TRzCheckBox
        Left = 41
        Top = 57
        Width = 310
        Height = 17
        Caption = #20999#25442#19981#21516#37197#32622#26102#25552#31034#20445#23384
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 1
      end
      object cbConfirmDelete: TRzCheckBox
        Left = 41
        Top = 94
        Width = 310
        Height = 17
        Caption = #21024#38500#37197#32622#26102#25552#31034
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 2
      end
      object cbAutoPing: TRzCheckBox
        Left = 41
        Top = 131
        Width = 310
        Height = 17
        Caption = #20999#25442#19981#21516#37197#32622#26102#33258#21160#27979#35797#32593#32476#36830#25509
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 3
      end
      object cbCheckValid: TRzCheckBox
        Left = 41
        Top = 168
        Width = 310
        Height = 17
        Caption = #20445#23384#25968#25454#26102#26816#39564#25968#25454#21512#27861#24615
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        State = cbUnchecked
        TabOrder = 4
      end
    end
    object tsInterface: TRzTabSheet
      Caption = #30028#38754#20449#24687
      object lbLanguage: TRzLabel
        Left = 41
        Top = 20
        Width = 93
        Height = 12
        Caption = #30028#38754#35821#35328
      end
      object lbListViewStyle: TRzLabel
        Left = 41
        Top = 57
        Width = 93
        Height = 12
        Caption = #37197#32622#21015#34920#26174#31034
      end
      object lbTrayMenu: TRzLabel
        Left = 41
        Top = 94
        Width = 93
        Height = 12
        Caption = #25176#30424#33756#21333#26174#31034
      end
      object cbLanguage: TRzComboBox
        Left = 140
        Top = 17
        Width = 145
        Height = 20
        Style = csDropDownList
        Ctl3D = False
        FlatButtons = True
        FrameHotTrack = True
        FrameHotStyle = fsFlat
        FrameVisible = True
        ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
        ItemHeight = 12
        ParentCtl3D = False
        TabOrder = 0
      end
      object cbListStyle: TRzComboBox
        Left = 140
        Top = 53
        Width = 145
        Height = 20
        Style = csDropDownList
        Ctl3D = False
        FlatButtons = True
        FrameHotTrack = True
        FrameHotStyle = fsFlat
        FrameVisible = True
        ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
        ItemHeight = 12
        ParentCtl3D = False
        TabOrder = 1
        Items.Strings = (
          #22823#22270#26631
          #23567#22270#26631
          #21015#34920)
      end
      object cbTrayMenu: TRzComboBox
        Left = 140
        Top = 90
        Width = 145
        Height = 20
        Style = csDropDownList
        Ctl3D = False
        FlatButtons = True
        FrameHotTrack = True
        FrameHotStyle = fsFlat
        FrameVisible = True
        ImeName = #20013#25991' ('#31616#20307') - '#35895#27468#25340#38899#36755#20837#27861
        ItemHeight = 12
        ParentCtl3D = False
        TabOrder = 2
        Items.Strings = (
          #20165#26174#31034'IP'
          #20165#26174#31034#37197#32622#21517
          #37197#32622#21517#21644'IP')
      end
    end
  end
  object btnOK: TRzButton
    Left = 128
    Top = 236
    Default = True
    FrameColor = 7617536
    ModalResult = 1
    Caption = #30830#23450'(&O)'
    Color = 15791348
    HotTrack = True
    TabOrder = 1
  end
  object btnCancel: TRzButton
    Left = 216
    Top = 236
    Cancel = True
    FrameColor = 7617536
    ModalResult = 2
    Caption = #21462#28040'(&C)'
    Color = 15791348
    HotTrack = True
    TabOrder = 2
  end
end
