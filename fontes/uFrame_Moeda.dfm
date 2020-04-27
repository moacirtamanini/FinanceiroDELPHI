object Frame_Moeda: TFrame_Moeda
  Left = 0
  Top = 0
  Width = 120
  Height = 38
  TabOrder = 0
  object lbMoeda: TLabel
    Left = 3
    Top = 2
    Width = 32
    Height = 13
    Caption = 'Moeda'
  end
  object cbMoeda: TComboBox
    Left = 3
    Top = 17
    Width = 116
    Height = 21
    BevelInner = bvNone
    BevelKind = bkFlat
    Ctl3D = False
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 0
    Items.Strings = (
      ''
      'Dinheiro'
      'Cheque'
      'Cart'#227'o de Cr'#233'dito'
      'Cart'#227'o de D'#233'bito'
      'Dep'#243'sito Banc'#225'rio'
      'Permuta'
      'Outros')
  end
end
