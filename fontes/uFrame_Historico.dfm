object Frame_Historico: TFrame_Historico
  Left = 0
  Top = 0
  Width = 243
  Height = 38
  TabOrder = 0
  object lbCodigo: TLabel
    Left = 3
    Top = 1
    Width = 41
    Height = 13
    Caption = 'Hist'#243'rico'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object edHisto: TCurrencyEdit
    Left = 3
    Top = 16
    Width = 60
    Height = 19
    AutoSize = False
    Ctl3D = False
    DecimalPlaces = 0
    DisplayFormat = ',0;0'
    MaxLength = 9
    ParentCtl3D = False
    TabOrder = 0
    OnExit = edHistoExit
  end
  object spBusca: TPanel
    Left = 63
    Top = 16
    Width = 21
    Height = 19
    BevelOuter = bvNone
    Caption = '2'
    Color = 12615680
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Marlett'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    OnClick = spBuscaClick
  end
end
