object Frame_Fornecedor: TFrame_Fornecedor
  Left = 0
  Top = 0
  Width = 120
  Height = 38
  TabOrder = 0
  object lbCodigo: TLabel
    Left = 3
    Top = 1
    Width = 55
    Height = 13
    Caption = 'Fornecedor'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object edCodigo: TCurrencyEdit
    Left = 3
    Top = 16
    Width = 94
    Height = 19
    AutoSize = False
    Ctl3D = False
    DecimalPlaces = 0
    DisplayFormat = ',0;0'
    MaxLength = 9
    ParentCtl3D = False
    TabOrder = 0
    OnExit = edCodigoExit
  end
  object spBusca: TPanel
    Left = 97
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
