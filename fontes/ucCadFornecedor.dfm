inherited fcCadFornecedor: TfcCadFornecedor
  Left = 680
  Top = 416
  VertScrollBar.Range = 0
  BorderStyle = bsSingle
  Caption = 'Fornecedores'
  ClientHeight = 367
  ClientWidth = 614
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 614
    Height = 334
    Align = alClient
    object Label2: TLabel
      Left = 103
      Top = 8
      Width = 54
      Height = 13
      Caption = 'CPF / CNPJ'
    end
    object Label3: TLabel
      Left = 221
      Top = 8
      Width = 97
      Height = 13
      Caption = 'Nome / Raz'#227'o Social'
    end
    object Label4: TLabel
      Left = 511
      Top = 8
      Width = 86
      Height = 13
      Caption = 'Apelido / Fantasia'
    end
    inline Frame_Fornecedor: TFrame_Fornecedor
      Left = 6
      Top = 5
      Width = 94
      Height = 38
      TabOrder = 0
      inherited edCodigo: TCurrencyEdit
        Width = 70
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited spBusca: TPanel
        Left = 73
      end
    end
    object edCPFCNPJ: TEdit
      Left = 103
      Top = 22
      Width = 116
      Height = 19
      Ctl3D = False
      MaxLength = 18
      ParentCtl3D = False
      TabOrder = 1
      OnKeyPress = Frame_FornecedoredCodigoKeyPress
    end
    object edNome: TEdit
      Left = 221
      Top = 22
      Width = 288
      Height = 19
      CharCase = ecUpperCase
      Ctl3D = False
      MaxLength = 100
      ParentCtl3D = False
      TabOrder = 2
      OnKeyPress = Frame_FornecedoredCodigoKeyPress
    end
    object edApelido: TEdit
      Left = 511
      Top = 22
      Width = 88
      Height = 19
      CharCase = ecUpperCase
      Ctl3D = False
      MaxLength = 20
      ParentCtl3D = False
      TabOrder = 3
      OnKeyPress = Frame_FornecedoredCodigoKeyPress
    end
    inline frame_End: Tframe_Endereco
      Left = 104
      Top = 84
      Width = 498
      Height = 193
      TabOrder = 6
      inherited edCEP: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edLogradouro: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edNumero: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edUF: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edCidade: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edBairro: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edComplemento: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edEmail: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edSite: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
    end
    inline frame_Fon: Tframe_Fone
      Left = 104
      Top = 278
      Width = 498
      Height = 51
      TabOrder = 7
      inherited edFonCenDDD: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edFonCenNRO: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edFonComDDD: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edFonComNRO: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edFonCelDDD: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edFonCelNRO: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edFonFaxDDD: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited edFonFaxNRO: TEdit
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
    end
    inline Frame_Moeda: TFrame_Moeda
      Left = 102
      Top = 43
      Width = 120
      Height = 38
      TabOrder = 4
      inherited lbMoeda: TLabel
        Width = 69
        Caption = 'Moeda Padr'#227'o'
      end
      inherited cbMoeda: TComboBox
        OnChange = Frame_MoedacbMoedaChange
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
    end
    inline Frame_Cartao: TFrame_Cartao
      Left = 227
      Top = 44
      Width = 375
      Height = 38
      TabOrder = 5
      inherited edCartao: TEdit
        Width = 348
        OnKeyPress = Frame_FornecedoredCodigoKeyPress
      end
      inherited spBusca: TPanel
        Left = 351
      end
    end
  end
  inherited pnBtns: TPanel
    Top = 334
    Width = 614
    inherited btnSair: TBitBtn
      Left = 534
      TabOrder = 3
    end
    object btnGravar: TBitBtn
      Left = 308
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Gravar'
      TabOrder = 0
      OnClick = btnGravarClick
    end
    object btnLimpar: TBitBtn
      Left = 384
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Limpar'
      TabOrder = 1
      OnClick = btnLimparClick
    end
    object btnExcluir: TBitBtn
      Left = 459
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Excluir'
      TabOrder = 2
      TabStop = False
      OnClick = btnExcluirClick
    end
  end
end
