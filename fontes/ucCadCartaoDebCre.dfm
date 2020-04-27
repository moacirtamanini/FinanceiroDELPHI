inherited fcCadCartaoDebCre: TfcCadCartaoDebCre
  Left = 650
  Top = 242
  Width = 460
  Height = 590
  Caption = 'Cart'#227'o de D'#233'bito / Cr'#233'dito'
  Constraints.MaxWidth = 460
  Constraints.MinHeight = 545
  Constraints.MinWidth = 460
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 444
    Height = 307
    object Label2: TLabel
      Left = 5
      Top = 4
      Width = 33
      Height = 13
      Caption = 'C'#243'digo'
    end
    object Label9: TLabel
      Left = 65
      Top = 4
      Width = 95
      Height = 13
      Caption = 'Descri'#231#227'o do cart'#227'o'
    end
    object Label1: TLabel
      Left = 65
      Top = 79
      Width = 121
      Height = 13
      Caption = 'Nome impresso no cart'#227'o'
    end
    object Label3: TLabel
      Left = 325
      Top = 4
      Width = 42
      Height = 13
      Caption = 'N'#186' Inicial'
    end
    object Label4: TLabel
      Left = 373
      Top = 4
      Width = 37
      Height = 13
      Caption = 'N'#186' Final'
    end
    object Label5: TLabel
      Left = 325
      Top = 79
      Width = 67
      Height = 13
      Caption = 'Senha do chip'
    end
    object Label6: TLabel
      Left = 65
      Top = 117
      Width = 108
      Height = 13
      Caption = 'Site do banco / acesso'
    end
    object Label7: TLabel
      Left = 325
      Top = 117
      Width = 65
      Height = 13
      Caption = 'Senha no site'
    end
    object Label8: TLabel
      Left = 65
      Top = 154
      Width = 81
      Height = 13
      Caption = 'Data de validade'
    end
    object Label10: TLabel
      Left = 166
      Top = 171
      Width = 90
      Height = 13
      Caption = 'Dia de fechamento'
    end
    object Label11: TLabel
      Left = 303
      Top = 171
      Width = 88
      Height = 13
      Caption = 'Dia de vencimento'
    end
    object edCodigo: TCurrencyEdit
      Left = 5
      Top = 18
      Width = 56
      Height = 19
      AutoSize = False
      Ctl3D = False
      DecimalPlaces = 0
      DisplayFormat = ',0;,0'
      ParentCtl3D = False
      TabOrder = 0
      OnExit = edCodigoExit
      OnKeyPress = edCodigoKeyPress
    end
    object edDescricao: TEdit
      Left = 65
      Top = 18
      Width = 256
      Height = 19
      Ctl3D = False
      MaxLength = 30
      ParentCtl3D = False
      TabOrder = 1
      OnKeyPress = edCodigoKeyPress
    end
    object edNome: TEdit
      Left = 65
      Top = 93
      Width = 256
      Height = 19
      CharCase = ecUpperCase
      Ctl3D = False
      MaxLength = 100
      ParentCtl3D = False
      TabOrder = 5
      OnKeyPress = edCodigoKeyPress
    end
    object edNroIni: TEdit
      Left = 325
      Top = 18
      Width = 44
      Height = 19
      Ctl3D = False
      MaxLength = 4
      ParentCtl3D = False
      TabOrder = 2
      OnKeyPress = edCodigoKeyPress
    end
    object edNroFim: TEdit
      Left = 373
      Top = 18
      Width = 44
      Height = 19
      Ctl3D = False
      MaxLength = 6
      ParentCtl3D = False
      TabOrder = 3
      OnKeyPress = edCodigoKeyPress
    end
    object edSenhaCompra: TEdit
      Left = 325
      Top = 93
      Width = 92
      Height = 19
      Ctl3D = False
      MaxLength = 30
      ParentCtl3D = False
      PasswordChar = '#'
      TabOrder = 6
      OnKeyPress = edCodigoKeyPress
    end
    object edSiteBanco: TEdit
      Left = 65
      Top = 131
      Width = 256
      Height = 19
      Ctl3D = False
      MaxLength = 255
      ParentCtl3D = False
      TabOrder = 7
      OnKeyPress = edCodigoKeyPress
    end
    object edSenhaSite: TEdit
      Left = 325
      Top = 131
      Width = 92
      Height = 19
      Ctl3D = False
      MaxLength = 30
      ParentCtl3D = False
      PasswordChar = '#'
      TabOrder = 8
      OnKeyPress = edCodigoKeyPress
    end
    object edDataValidade: TDateEdit
      Left = 65
      Top = 168
      Width = 86
      Height = 19
      Ctl3D = False
      NumGlyphs = 2
      ParentCtl3D = False
      TabOrder = 9
      OnKeyPress = edCodigoKeyPress
    end
    object edDiaFechto: TCurrencyEdit
      Left = 259
      Top = 168
      Width = 24
      Height = 19
      AutoSize = False
      Ctl3D = False
      DecimalPlaces = 0
      DisplayFormat = ',0;,0'
      ParentCtl3D = False
      TabOrder = 10
      OnKeyPress = edCodigoKeyPress
    end
    object edDiaVencto: TCurrencyEdit
      Left = 393
      Top = 168
      Width = 24
      Height = 19
      AutoSize = False
      Ctl3D = False
      DecimalPlaces = 0
      DisplayFormat = ',0;,0'
      ParentCtl3D = False
      TabOrder = 11
      OnKeyPress = edCodigoKeyPress
    end
    inline frame_Bandeira: Tframe_Bandeira
      Left = 64
      Top = 190
      Width = 358
      Height = 39
      TabOrder = 12
      inherited cbBandeira: TComboBox
        Width = 354
        OnKeyPress = edCodigoKeyPress
      end
    end
    inline frame_CategoriaDeb: Tframe_Categoria
      Left = 63
      Top = 231
      Width = 363
      Height = 38
      TabOrder = 13
      inherited lbCodigo: TLabel
        Width = 232
        Caption = 'Categoria D'#233'bito - Conta de Despesas Vinculada'
      end
      inherited edCodigo: TEdit
        Width = 331
        OnKeyPress = edCodigoKeyPress
      end
      inherited spBusca: TPanel
        Left = 334
      end
    end
    inline frame_CategoriaCre: Tframe_Categoria
      Left = 63
      Top = 269
      Width = 363
      Height = 38
      TabOrder = 14
      inherited lbCodigo: TLabel
        Width = 236
        Caption = 'Categoria Cr'#233'dito - Conta de Despesas Vinculada'
      end
      inherited edCodigo: TEdit
        Width = 331
      end
      inherited spBusca: TPanel
        Left = 334
      end
    end
    object rgTpDebCre: TRadioGroup
      Left = 66
      Top = 38
      Width = 352
      Height = 35
      Caption = 'Tipo do cart'#227'o'
      Columns = 3
      ItemIndex = 2
      Items.Strings = (
        'Somente D'#233'bito'
        'Somente Cr'#233'dito'
        'D'#233'bito e Cr'#233'dito')
      TabOrder = 4
      OnClick = rgTpDebCreClick
    end
  end
  inherited pnBtns: TPanel
    Top = 518
    Width = 444
    inherited btnSair: TBitBtn
      Left = 364
      TabOrder = 3
    end
    object btnGravar: TBitBtn
      Left = 136
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Gravar'
      TabOrder = 0
      OnClick = btnGravarClick
    end
    object btnExcluir: TBitBtn
      Left = 288
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnLimpar: TBitBtn
      Left = 212
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Limpar'
      TabOrder = 1
      OnClick = btnLimparClick
    end
  end
  object DBGridGrade: TDBGrid
    Left = 0
    Top = 307
    Width = 444
    Height = 211
    Align = alClient
    Ctl3D = False
    DataSource = dsGrade
    FixedColor = 16773345
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDblClick = DBGridGradeDblClick
    Columns = <
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'CODIGO'
        Title.Caption = 'C'#243'digo'
        Width = 63
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Descricao'
        Title.Caption = 'Descri'#231#227'o do cart'#227'o'
        Width = 257
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NroIni'
        Title.Caption = 'N'#186' Inicial'
        Width = 48
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NroFim'
        Title.Caption = 'N'#186' Final'
        Width = 45
        Visible = True
      end>
  end
  object pFIBTrGrade: TpFIBTransaction
    DefaultDatabase = fDataM.FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 47
    Top = 321
  end
  object qrGrade: TpFIBDataSet
    Transaction = pFIBTrGrade
    Database = fDataM.FIB_Db
    Left = 47
    Top = 369
  end
  object pFIBDSProvGrade: TpFIBDataSetProvider
    DataSet = qrGrade
    Left = 47
    Top = 415
  end
  object pFIBCdsGrade: TpFIBClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'pFIBDSProvGrade'
    Left = 47
    Top = 461
  end
  object dsGrade: TDataSource
    DataSet = pFIBCdsGrade
    Left = 119
    Top = 461
  end
end
