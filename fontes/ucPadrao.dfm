object fcPadrao: TfcPadrao
  Left = 392
  Top = 236
  Width = 1024
  Height = 570
  BorderIcons = [biSystemMenu, biMinimize]
  Color = 16773345
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 1008
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
  end
  object pnBtns: TPanel
    Left = 0
    Top = 498
    Width = 1008
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    DesignSize = (
      1008
      33)
    object btnSair: TBitBtn
      Left = 928
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Sair'
      TabOrder = 0
      OnClick = btnSairClick
    end
  end
end
