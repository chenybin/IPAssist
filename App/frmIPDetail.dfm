object IPDetailForm: TIPDetailForm
  Left = 192
  Top = 107
  Width = 403
  Height = 381
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #35814#32454#20449#24687
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  ShowHint = True
  PixelsPerInch = 96
  TextHeight = 12
  object pcMain: TRzPageControl
    Left = 8
    Top = 8
    Width = 377
    Height = 305
    ActivePage = tsIP
    TabIndex = 0
    TabOrder = 0
    FixedDimension = 18
    object tsIP: TRzTabSheet
      Caption = 'IP'#22320#22336
      object gbIP: TRzGroupBox
        Left = 12
        Top = 9
        Width = 349
        Height = 137
        Caption = 'IP'#22320#22336
        FrameController = RzFrameController1
        TabOrder = 0
        object lvIP: TRzListView
          Left = 8
          Top = 16
          Width = 269
          Height = 113
          Columns = <
            item
              Caption = 'IP'#22320#22336
              Width = 130
            end
            item
              Caption = #23376#32593#25513#30721
              Width = 119
            end>
          FlatScrollBars = True
          FrameHotTrack = True
          FrameHotStyle = fsFlat
          FrameVisible = True
          GridLines = True
          HideSelection = False
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
        object AddIP: TRzButton
          Left = 287
          Top = 40
          Width = 53
          FrameColor = 7617536
          Caption = #22686#21152
          Color = 15791348
          HotTrack = True
          TabOrder = 1
        end
        object ModifyIP: TRzButton
          Left = 287
          Top = 72
          Width = 53
          FrameColor = 7617536
          Caption = #20462#25913
          Color = 15791348
          Enabled = False
          HotTrack = True
          TabOrder = 2
        end
        object DelIP: TRzButton
          Left = 287
          Top = 104
          Width = 53
          FrameColor = 7617536
          Caption = #21024#38500
          Color = 15791348
          Enabled = False
          HotTrack = True
          TabOrder = 3
        end
      end
      object gbGateway: TRzGroupBox
        Left = 12
        Top = 150
        Width = 353
        Height = 126
        Caption = #40664#35748#32593#20851
        TabOrder = 1
        object lvGateway: TRzListView
          Left = 8
          Top = 18
          Width = 268
          Height = 92
          Columns = <
            item
              Caption = #40664#35748#32593#20851
              Width = 248
            end>
          FlatScrollBars = True
          FrameHotTrack = True
          FrameHotStyle = fsFlat
          FrameVisible = True
          GridLines = True
          HideSelection = False
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
        object AddGateway: TRzButton
          Left = 288
          Top = 29
          Width = 53
          FrameColor = 7617536
          Caption = #22686#21152
          Color = 15791348
          HotTrack = True
          TabOrder = 1
        end
        object ModifyGateway: TRzButton
          Left = 288
          Top = 57
          Width = 53
          FrameColor = 7617536
          Caption = #20462#25913
          Color = 15791348
          Enabled = False
          HotTrack = True
          TabOrder = 2
        end
        object DelGateway: TRzButton
          Left = 288
          Top = 85
          Width = 53
          FrameColor = 7617536
          Caption = #21024#38500
          Color = 15791348
          Enabled = False
          HotTrack = True
          TabOrder = 3
        end
      end
    end
    object tsDNS: TRzTabSheet
      Caption = 'DNS'#21644'WINS'
      object gbDNS: TRzGroupBox
        Left = 12
        Top = 9
        Width = 349
        Height = 137
        Caption = 'DNS'#22320#22336
        FrameController = RzFrameController1
        TabOrder = 0
        object lvDNS: TRzListView
          Left = 8
          Top = 16
          Width = 269
          Height = 113
          Columns = <
            item
              AutoSize = True
              Caption = 'IP'#22320#22336
            end>
          DragMode = dmAutomatic
          FlatScrollBars = True
          FrameHotTrack = True
          FrameHotStyle = fsFlat
          FrameVisible = True
          GridLines = True
          HideSelection = False
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
        object AddDNS: TRzButton
          Left = 287
          Top = 40
          Width = 53
          FrameColor = 7617536
          Caption = #22686#21152
          Color = 15791348
          HotTrack = True
          TabOrder = 1
        end
        object ModifyDNS: TRzButton
          Left = 287
          Top = 72
          Width = 53
          FrameColor = 7617536
          Caption = #20462#25913
          Color = 15791348
          Enabled = False
          HotTrack = True
          TabOrder = 2
        end
        object DelDNS: TRzButton
          Left = 287
          Top = 104
          Width = 53
          FrameColor = 7617536
          Caption = #21024#38500
          Color = 15791348
          Enabled = False
          HotTrack = True
          TabOrder = 3
        end
      end
      object gbWINS: TRzGroupBox
        Left = 12
        Top = 150
        Width = 353
        Height = 126
        Caption = 'WINS'#22320#22336
        TabOrder = 1
        object lvWINS: TRzListView
          Left = 8
          Top = 18
          Width = 268
          Height = 92
          Columns = <
            item
              AutoSize = True
              Caption = 'IP'#22320#22336
            end>
          DragMode = dmAutomatic
          FlatScrollBars = True
          FrameHotTrack = True
          FrameHotStyle = fsFlat
          FrameVisible = True
          GridLines = True
          HideSelection = False
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
        object AddWINS: TRzButton
          Left = 288
          Top = 29
          Width = 53
          FrameColor = 7617536
          Caption = #22686#21152
          Color = 15791348
          HotTrack = True
          TabOrder = 1
        end
        object ModifyWINS: TRzButton
          Left = 288
          Top = 57
          Width = 53
          FrameColor = 7617536
          Caption = #20462#25913
          Color = 15791348
          Enabled = False
          HotTrack = True
          TabOrder = 2
        end
        object DelWINS: TRzButton
          Left = 288
          Top = 85
          Width = 53
          FrameColor = 7617536
          Caption = #21024#38500
          Color = 15791348
          Enabled = False
          HotTrack = True
          TabOrder = 3
        end
      end
    end
    object tsIE: TRzTabSheet
      Caption = 'IE'#35774#32622
      object gbProxy: TRzGroupBox
        Left = 12
        Top = 9
        Width = 349
        Height = 75
        Caption = 'IE'#20195#29702#26381#21153#22120
        FrameController = RzFrameController1
        TabOrder = 1
        object lbAddress: TRzLabel
          Left = 28
          Top = 44
          Width = 36
          Height = 12
          Caption = #22320#22336#65306
        end
        object lbPort: TRzLabel
          Left = 236
          Top = 44
          Width = 36
          Height = 12
          Caption = #31471#21475#65306
        end
        object cbProxyEnabled: TRzCheckBox
          Left = 28
          Top = 20
          Width = 115
          Height = 17
          Caption = #20351#29992#20195#29702#26381#21153#22120
          Enabled = False
          FrameColor = 8409372
          HighlightColor = 2203937
          HotTrack = True
          HotTrackStyle = htsFrame
          State = cbUnchecked
          TabOrder = 0
        end
        object edtProxyServer: TRzEdit
          Left = 76
          Top = 41
          Width = 137
          Height = 20
          Enabled = False
          FrameController = MainForm.RzFrameController1
          ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
          TabOrder = 1
        end
        object edtProxyPort: TRzMaskEdit
          Left = 284
          Top = 41
          Width = 39
          Height = 20
          Enabled = False
          EditMask = '!999999;1; '
          FrameController = MainForm.RzFrameController1
          ImeName = #20013#25991' ('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
          MaxLength = 6
          TabOrder = 2
          Text = '      '
        end
      end
      object gbDial: TRzGroupBox
        Left = 12
        Top = 90
        Width = 349
        Height = 90
        Caption = 'IE'#25320#21495#35774#32622
        TabOrder = 3
        object rbIEDialSet0: TRzRadioButton
          Left = 64
          Top = 20
          Width = 229
          Height = 17
          Caption = #20174#19981#36827#34892#25320#21495#36830#25509'(&C)'
          Enabled = False
          FrameColor = 8409372
          HighlightColor = 2203937
          HotTrack = True
          HotTrackStyle = htsFrame
          TabOrder = 0
        end
        object rbIEDialSet1: TRzRadioButton
          Left = 64
          Top = 42
          Width = 229
          Height = 17
          Caption = #19981#35770#32593#32476#25320#21495#26159#21542#23384#22312#37117#36827#34892#25320#21495'(&W)'
          Enabled = False
          FrameColor = 8409372
          HighlightColor = 2203937
          HotTrack = True
          HotTrackStyle = htsFrame
          TabOrder = 1
        end
        object rbIEDialSet2: TRzRadioButton
          Left = 64
          Top = 64
          Width = 229
          Height = 17
          Caption = #22987#32456#25320#40664#35748#36830#25509'(&O)'
          Enabled = False
          FrameColor = 8409372
          HighlightColor = 2203937
          HotTrack = True
          HotTrackStyle = htsFrame
          TabOrder = 2
        end
      end
      object gbNetBIOS: TRzGroupBox
        Left = 12
        Top = 186
        Width = 349
        Height = 88
        Caption = 'NetBIOS'#35774#32622
        TabOrder = 5
        object rbNetbios0: TRzRadioButton
          Left = 64
          Top = 15
          Width = 243
          Height = 17
          Caption = #40664#35748'(&F)'
          Enabled = False
          FrameColor = 8409372
          HighlightColor = 2203937
          HotTrack = True
          HotTrackStyle = htsFrame
          TabOrder = 0
        end
        object rbNetbios1: TRzRadioButton
          Left = 64
          Top = 35
          Width = 243
          Height = 17
          Caption = #21551#21160'TCP/IP'#30340'NetBIOS(&N)'
          Enabled = False
          FrameColor = 8409372
          HighlightColor = 2203937
          HotTrack = True
          HotTrackStyle = htsFrame
          TabOrder = 1
        end
        object rbNetbios2: TRzRadioButton
          Left = 64
          Top = 56
          Width = 243
          Height = 17
          Caption = #31105#29992'TCP/IP'#30340'NetBIOS(&S)'
          Enabled = False
          FrameColor = 8409372
          HighlightColor = 2203937
          HotTrack = True
          HotTrackStyle = htsFrame
          TabOrder = 2
        end
      end
      object cbIEProxyEnabled: TRzCheckBox
        Left = 19
        Top = 6
        Width = 94
        Height = 17
        Caption = 'IE'#20195#29702#26381#21153#22120
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        HotTrackStyle = htsFrame
        State = cbUnchecked
        TabOrder = 0
      end
      object cbIEDialEnabled: TRzCheckBox
        Left = 20
        Top = 88
        Width = 84
        Height = 17
        Caption = 'IE'#25320#21495#35774#32622
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        HotTrackStyle = htsFrame
        State = cbUnchecked
        TabOrder = 2
      end
      object cbNetBIOSEnabled: TRzCheckBox
        Left = 20
        Top = 184
        Width = 87
        Height = 17
        Caption = 'NetBIOS'#35774#32622
        FrameColor = 8409372
        HighlightColor = 2203937
        HotTrack = True
        HotTrackStyle = htsFrame
        State = cbUnchecked
        TabOrder = 4
      end
    end
  end
  object btnOK: TRzButton
    Left = 108
    Top = 316
    Default = True
    FrameColor = 7617536
    ModalResult = 1
    Caption = #30830#23450'(&O)'
    Color = 15791348
    HotTrack = True
    TabOrder = 1
  end
  object btnCancel: TRzButton
    Left = 200
    Top = 316
    Cancel = True
    FrameColor = 7617536
    ModalResult = 2
    Caption = #21462#28040'(&C)'
    Color = 15791348
    HotTrack = True
    TabOrder = 2
  end
  object RzFrameController1: TRzFrameController
    FrameHotTrack = True
    FrameVisible = True
    Top = 172
  end
end
