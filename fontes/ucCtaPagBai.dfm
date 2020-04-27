inherited fcCtaPagBai: TfcCtaPagBai
  Left = 463
  Top = 540
  VertScrollBar.Range = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Baixa de Pagamento'
  ClientHeight = 131
  ClientWidth = 565
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 565
    Height = 98
    Align = alClient
    object Label1: TLabel
      Left = 6
      Top = 6
      Width = 67
      Height = 13
      Caption = 'Data da Baixa'
    end
    object Label10: TLabel
      Left = 508
      Top = 6
      Width = 51
      Height = 13
      Caption = 'Valor Total'
    end
    object Label2: TLabel
      Left = 117
      Top = 6
      Width = 66
      Height = 13
      Caption = 'Valor Principal'
    end
    object Label3: TLabel
      Left = 223
      Top = 6
      Width = 53
      Height = 13
      Caption = 'Valor Juros'
    end
    object Label4: TLabel
      Left = 317
      Top = 6
      Width = 53
      Height = 13
      Caption = 'Valor Multa'
    end
    object Label5: TLabel
      Left = 392
      Top = 6
      Width = 72
      Height = 13
      Caption = 'Valor Desconto'
    end
    object Label12: TLabel
      Left = 92
      Top = 43
      Width = 41
      Height = 13
      Caption = 'Hist'#243'rico'
    end
    object edDataBaixa: TDateEdit
      Left = 6
      Top = 20
      Width = 84
      Height = 19
      Ctl3D = False
      NumGlyphs = 2
      ParentCtl3D = False
      TabOrder = 0
      OnKeyPress = edHistoDESKeyPress
    end
    object edVlrTot: TCurrencyEdit
      Left = 469
      Top = 20
      Width = 90
      Height = 19
      TabStop = False
      AutoSize = False
      Color = 16777088
      Ctl3D = False
      DisplayFormat = ',0.00;-,0.00'
      ParentCtl3D = False
      ReadOnly = True
      TabOrder = 5
      OnKeyPress = edHistoDESKeyPress
    end
    object edVlrPri: TCurrencyEdit
      Left = 93
      Top = 20
      Width = 90
      Height = 19
      AutoSize = False
      Ctl3D = False
      DisplayFormat = ',0.00;-,0.00'
      ParentCtl3D = False
      TabOrder = 1
      OnChange = edVlrPriChange
      OnKeyPress = edHistoDESKeyPress
    end
    object edVlrJur: TCurrencyEdit
      Left = 186
      Top = 20
      Width = 90
      Height = 19
      AutoSize = False
      Ctl3D = False
      DisplayFormat = ',0.00;-,0.00'
      ParentCtl3D = False
      TabOrder = 2
      OnChange = edVlrPriChange
      OnKeyPress = edHistoDESKeyPress
    end
    object edVlrMul: TCurrencyEdit
      Left = 280
      Top = 20
      Width = 90
      Height = 19
      AutoSize = False
      Ctl3D = False
      DisplayFormat = ',0.00;-,0.00'
      ParentCtl3D = False
      TabOrder = 3
      OnChange = edVlrPriChange
      OnKeyPress = edHistoDESKeyPress
    end
    object edVlrDes: TCurrencyEdit
      Left = 374
      Top = 20
      Width = 90
      Height = 19
      AutoSize = False
      Ctl3D = False
      DisplayFormat = ',0.00;-,0.00'
      ParentCtl3D = False
      TabOrder = 4
      OnChange = edVlrPriChange
      OnKeyPress = edHistoDESKeyPress
    end
    inline Frame_Histo: TFrame_Historico
      Left = 3
      Top = 42
      Width = 87
      Height = 38
      TabOrder = 6
      inherited edHisto: TCurrencyEdit
        OnKeyPress = edHistoDESKeyPress
      end
    end
    object edHistoDES: TEdit
      Left = 92
      Top = 58
      Width = 467
      Height = 19
      Ctl3D = False
      MaxLength = 255
      ParentCtl3D = False
      TabOrder = 7
      OnEnter = edHistoDESEnter
      OnKeyPress = edHistoDESKeyPress
    end
  end
  inherited pnBtns: TPanel
    Top = 98
    Width = 565
    inherited btnSair: TBitBtn
      Left = 485
      TabOrder = 1
    end
    object btnOK: TBitBtn
      Left = 409
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
end
