object MainForm: TMainForm
  Left = 754
  Top = 128
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 453
  ClientWidth = 556
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object VersionLabel: TLabel
    Left = 16
    Top = 424
    Width = 33
    Height = 11
    Caption = 'version:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object StartButton: TButton
    Left = 256
    Top = 416
    Width = 130
    Height = 25
    Caption = '&Start downloading'
    Default = True
    TabOrder = 1
    OnClick = StartButtonClick
  end
  object QuitButton: TButton
    Left = 472
    Top = 416
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Close'
    TabOrder = 3
    OnClick = QuitButtonClick
  end
  object SettingsGroupBox: TGroupBox
    Left = 8
    Top = 232
    Width = 540
    Height = 177
    Caption = ' Statistics and settings '
    TabOrder = 0
    object PathsLabel: TLabel
      Left = 112
      Top = 52
      Width = 25
      Height = 11
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'paths:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
    end
    object SubDirsLabel: TLabel
      Left = 93
      Top = 66
      Width = 44
      Height = 11
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'directories:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
    end
    object FilesLabel: TLabel
      Left = 118
      Top = 80
      Width = 19
      Height = 11
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'files:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
    end
    object TimeLeftLabel: TLabel
      Left = 80
      Top = 24
      Width = 57
      Height = 11
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'time duration:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
    end
    object HostsLabel: TLabel
      Left = 63
      Top = 38
      Width = 74
      Height = 11
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'remained servers:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
    end
    object FtpLabel: TLabel
      Left = 320
      Top = 24
      Width = 72
      Height = 13
      Caption = '&FTP server list:'
      FocusControl = FtpComboBox
    end
    object DestinationLabel: TLabel
      Left = 322
      Top = 120
      Width = 104
      Height = 13
      Caption = '&Destination directory:'
      FocusControl = DestinationEdit
    end
    object ErrorsLabel: TLabel
      Left = 111
      Top = 94
      Width = 26
      Height = 11
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = 'errors:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
    end
    object ReconnectionsLabel: TLabel
      Left = 16
      Top = 124
      Width = 151
      Height = 13
      Caption = '&Number of connection attemps:'
      FocusControl = ReconnectionsSpinEdit
    end
    object FtpComboBox: TComboBox
      Left = 320
      Top = 40
      Width = 201
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object ShowDetailsCheckBox: TCheckBox
      Left = 322
      Top = 76
      Width = 199
      Height = 17
      Caption = '&Display FTP connection details'
      TabOrder = 1
    end
    object DestinationEdit: TEdit
      Left = 322
      Top = 136
      Width = 119
      Height = 21
      TabOrder = 3
    end
    object BrowseButton: TButton
      Left = 445
      Top = 134
      Width = 75
      Height = 25
      Caption = '&Browse'
      TabOrder = 4
      OnClick = BrowseButtonClick
    end
    object CompressCheckBox: TCheckBox
      Left = 322
      Top = 92
      Width = 191
      Height = 17
      Caption = '&Compress files after downloading'
      TabOrder = 2
    end
    object ReconnectionsSpinEdit: TSpinEdit
      Left = 176
      Top = 120
      Width = 49
      Height = 22
      Hint = 
        'Ilo'#347#263' ponownych pr'#243'b w przypadku tylko jednego zerwanego po'#322#261'cze' +
        'nia'
      MaxValue = 255
      MinValue = 1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      Value = 5
    end
    object BreakCheckBox: TCheckBox
      Left = 16
      Top = 142
      Width = 297
      Height = 17
      Caption = 'stop &working after all unsuccessful connection attempts'
      TabOrder = 6
    end
    object StatusPanel: TPanel
      Left = 144
      Top = 18
      Width = 161
      Height = 95
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Ctl3D = True
      ParentBackground = False
      ParentCtl3D = False
      TabOrder = 7
      object TimeLeftCountLabel: TLabel
        Left = 9
        Top = 6
        Width = 48
        Height = 11
        Caption = '00:00:00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object HostsCountLabel: TLabel
        Left = 10
        Top = 20
        Width = 7
        Height = 11
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object PathsCountLabel: TLabel
        Left = 10
        Top = 34
        Width = 7
        Height = 11
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SubDirsCountLabel: TLabel
        Left = 10
        Top = 48
        Width = 7
        Height = 11
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object FilesCountLabel: TLabel
        Left = 10
        Top = 62
        Width = 7
        Height = 11
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ErrorsCountLabel: TLabel
        Left = 10
        Top = 76
        Width = 7
        Height = 11
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object AboutButton: TButton
    Left = 391
    Top = 416
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&About'
    TabOrder = 2
    OnClick = AboutButtonClick
  end
  object LogGroupBox: TGroupBox
    Left = 8
    Top = 8
    Width = 540
    Height = 217
    Caption = ' Operation log '
    TabOrder = 4
    object LogRichEdit: TRichEdit
      Left = 16
      Top = 24
      Width = 510
      Height = 177
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      PopupMenu = TrayMenu
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
  end
  object CountTimer: TTimer
    Enabled = False
    OnTimer = CountTimerTimer
    Left = 80
    Top = 416
  end
  object FtpClient: TFtpClient
    Timeout = 45
    MultiThreaded = True
    Port = 'ftp'
    CodePage = 0
    DataPortRangeStart = 0
    DataPortRangeEnd = 0
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    DisplayFileFlag = False
    Binary = True
    ShareMode = ftpShareExclusive
    Options = [ftpAcceptLF]
    ConnectionType = ftpDirect
    ProxyPort = 'ftp'
    Language = 'EN'
    OnDisplay = FtpClientDisplay
    OnError = FtpClientError
    OnSessionConnected = FtpClientSessionConnected
    OnSessionClosed = FtpClientSessionClosed
    OnRequestDone = FtpClientRequestDone
    OnBgException = FtpClientBgException
    BandwidthLimit = 10000
    BandwidthSampling = 1000
    SocketFamily = sfIPv4
    Left = 112
    Top = 416
  end
  object TrayMenu: TPopupMenu
    Left = 144
    Top = 416
    object ClearMenuItem: TMenuItem
      Caption = 'Wy&czy'#347#263
      ShortCut = 16466
      OnClick = ClearMenuItemClick
    end
  end
  object CoolTrayIcon: TCoolTrayIcon
    CycleInterval = 0
    Icon.Data = {
      0000010001001010000001000800680500001600000028000000100000002000
      0000010008000000000000000000000000000000000000000000000000000000
      0000795E5E007B6060007E62620081656500886A6A008B6C6C008D6E6E009071
      710095767600987878009D7D7D0000FF00004832A0000C5B87000B5D8B000B5F
      8D000A6191000963940008659700066BA100046EA5000371AB000372AD000275
      B200007AB8007ACAEE00A3848400A4858500A98B8B00A98C8C00AD919100AF94
      9400B0969600E8C78100ECCD8F00FFDC8600FFDE8C00F9DB9500FFE09500FFE3
      9E00FFE3A000FFE4A200FFE5A700F9E0A800FFE7AC00FFEBBD00FFECBF008DE2
      FD0091E6FD0096EBFE009BF0FE009EF3FE00BDE5F700D1C3C300DBD0D000FFEE
      C800CBF6FE00CFF9FE00D2FCFF0091FFDC00B1FFE500D1FFF000FFFFFF000000
      0000002F0E00005018000070220000902C0000B0360000CF400000F04A0011FF
      5B0031FF710051FF870071FF9D0091FFB200B1FFC900D1FFDF00FFFFFF000000
      0000022F00000450000006700000089000000AB000000BCF00000EF0000020FF
      12003DFF31005BFF510079FF710098FF9100B5FFB100D4FFD100FFFFFF000000
      0000142F000022500000307000003D9000004CB0000059CF000067F0000078FF
      11008AFF31009CFF5100AEFF7100C0FF9100D2FFB100E4FFD100FFFFFF000000
      0000262F0000405000005A700000749000008EB00000A9CF0000C2F00000D1FF
      1100D8FF3100DEFF5100E3FF7100E9FF9100EFFFB100F6FFD100FFFFFF000000
      00002F26000050410000705B000090740000B08E0000CFA90000F0C30000FFD2
      1100FFD83100FFDD5100FFE47100FFEA9100FFF0B100FFF6D100FFFFFF000000
      00002F1400005022000070300000903E0000B04D0000CF5B0000F0690000FF79
      1100FF8A3100FF9D5100FFAF7100FFC19100FFD2B100FFE5D100FFFFFF000000
      00002F030000500400007006000090090000B00A0000CF0C0000F00E0000FF20
      1200FF3E3100FF5C5100FF7A7100FF979100FFB6B100FFD4D100FFFFFF000000
      00002F000E00500017007000210090002B00B0003600CF004000F0004900FF11
      5A00FF317000FF518600FF719C00FF91B200FFB1C800FFD1DF00FFFFFF000000
      00002F0020005000360070004C0090006200B0007800CF008E00F000A400FF11
      B300FF31BE00FF51C700FF71D100FF91DC00FFB1E500FFD1F000FFFFFF000000
      00002C002F004B0050006900700087009000A500B000C400CF00E100F000F011
      FF00F231FF00F451FF00F671FF00F791FF00F9B1FF00FBD1FF00FFFFFF000000
      00001B002F002D0050003F007000520090006300B0007600CF008800F0009911
      FF00A631FF00B451FF00C271FF00CF91FF00DCB1FF00EBD1FF00FFFFFF000000
      000008002F000E005000150070001B0090002100B0002600CF002C00F0003E11
      FF005831FF007151FF008C71FF00A691FF00BFB1FF00DAD1FF00FFFFFF000B09
      07050402030000001311100F0F001C363636363604000015351A1A1A1A0E1F37
      3737370C080D0D17393231301A0E1F211F1D1C0B0A0000183B3332311A100009
      08060301000000193B3B393935120B232A292522020000193434171514001C2B
      2E2F2924040000001919000000001E2D382F2A24060000000D0000000D00212C
      2D2D27260800000D0D0D0D0D0D0D2021201E1C0B0B0000000D0000000D000000
      000000000000000000000000000000000B000000000B00001B00000000000000
      0B000000000B00000B000000000000000B0B0000000B00000B0B0B0000000000
      0B000000000B00000B00000B000000000B0B0B000B0B0B000B0B0B00000001C1
      0000018000000000000001800000838000000181000001CF000001DD00000180
      000001DD0000FFFF0000DEDF0000DEDF0000CEC70000DEDB0000C4470000}
    IconVisible = True
    IconIndex = 0
    LeftPopup = True
    MinimizeToTray = True
    OnDblClick = CoolTrayIconDblClick
    OnMinimizeToTray = CoolTrayIconMinimizeToTray
    Left = 176
    Top = 416
  end
end
