object Frame_ForCli: TFrame_ForCli
  Left = 0
  Top = 0
  Width = 1920
  Height = 1017
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
  object spBusca: TPanel
    Left = 334
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
  object pnCombo: TPanel
    Left = 313
    Top = 16
    Width = 21
    Height = 19
    BevelOuter = bvNone
    Caption = '6'
    Color = 12615680
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Marlett'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    OnClick = pnComboClick
  end
  object edNome: TEdit
    Left = 3
    Top = 16
    Width = 310
    Height = 19
    CharCase = ecUpperCase
    Ctl3D = False
    MaxLength = 100
    ParentCtl3D = False
    TabOrder = 2
    OnExit = edNomeExit
  end
  object pmForCli: TPopupMenu
    Left = 8
    Top = 28
    object mmIndefi: TMenuItem
      AutoCheck = True
      Caption = 'Indefinido'
      GroupIndex = 1
      RadioItem = True
      OnClick = mmIndefiClick
    end
    object mmForne: TMenuItem
      AutoCheck = True
      Caption = 'Fornecdor'
      Checked = True
      Default = True
      GroupIndex = 1
      RadioItem = True
      OnClick = mmIndefiClick
    end
    object mmClien: TMenuItem
      AutoCheck = True
      Caption = 'Cliente'
      GroupIndex = 1
      RadioItem = True
      OnClick = mmIndefiClick
    end
  end
end
