inherited fcCtaRecLanParceAlt: TfcCtaRecLanParceAlt
  Left = 604
  Top = 375
  VertScrollBar.Range = 0
  BorderStyle = bsDialog
  Caption = 'Altera'#231#227'o da Parcela'
  ClientHeight = 91
  ClientWidth = 582
  KeyPreview = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 582
    Height = 58
    Align = alClient
    object Label5: TLabel
      Left = 6
      Top = 9
      Width = 81
      Height = 13
      Caption = 'Data Vencimento'
    end
    object edDataVencto: TDateEdit
      Left = 6
      Top = 23
      Width = 84
      Height = 19
      Ctl3D = False
      NumGlyphs = 2
      ParentCtl3D = False
      TabOrder = 0
      OnKeyPress = edDataVenctoKeyPress
    end
    inline Frame_Moeda: TFrame_Moeda
      Left = 94
      Top = 5
      Width = 120
      Height = 38
      TabOrder = 1
      inherited lbMoeda: TLabel
        Width = 69
        Caption = 'Moeda Padr'#227'o'
      end
      inherited cbMoeda: TComboBox
        OnChange = Frame_MoedacbMoedaChange
        OnKeyPress = edDataVenctoKeyPress
      end
    end
    inline Frame_Cartao: TFrame_Cartao
      Left = 219
      Top = 6
      Width = 359
      Height = 38
      TabOrder = 2
      inherited edCartao: TEdit
        Width = 332
        OnKeyPress = edDataVenctoKeyPress
      end
      inherited spBusca: TPanel
        Left = 335
      end
    end
  end
  inherited pnBtns: TPanel
    Top = 58
    Width = 582
    inherited btnSair: TBitBtn
      Left = 502
    end
    object btnOK: TBitBtn
      Left = 425
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      TabOrder = 1
      OnClick = btnOKClick
    end
  end
end
