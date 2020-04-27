inherited fcCadCategoria: TfcCadCategoria
  Left = 470
  Top = 264
  Width = 840
  Height = 590
  Caption = 'Plano de categorias'
  Constraints.MaxWidth = 840
  Constraints.MinHeight = 250
  Constraints.MinWidth = 840
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 824
    Height = 40
    object Label2: TLabel
      Left = 5
      Top = 4
      Width = 33
      Height = 13
      Caption = 'C'#243'digo'
    end
    object Label9: TLabel
      Left = 151
      Top = 4
      Width = 90
      Height = 13
      Caption = 'Nome da categoria'
    end
    object Label1: TLabel
      Left = 65
      Top = 4
      Width = 61
      Height = 13
      Caption = 'Classifica'#231#227'o'
    end
    object Label3: TLabel
      Left = 618
      Top = 4
      Width = 35
      Height = 13
      Caption = 'Apelido'
    end
    object edCodigo: TCurrencyEdit
      Left = 5
      Top = 18
      Width = 60
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
      Left = 151
      Top = 18
      Width = 467
      Height = 19
      Ctl3D = False
      MaxLength = 100
      ParentCtl3D = False
      TabOrder = 2
      OnKeyPress = edCodigoKeyPress
    end
    object edClassificacao: TMaskEdit
      Left = 65
      Top = 18
      Width = 85
      Height = 19
      AutoSize = False
      Ctl3D = False
      EditMask = '9.9.9.99.9999;1; '
      MaxLength = 13
      ParentCtl3D = False
      TabOrder = 1
      Text = ' . . .  .    '
      OnExit = edClassificacaoExit
      OnKeyPress = edCodigoKeyPress
    end
    object edApelido: TEdit
      Left = 618
      Top = 18
      Width = 146
      Height = 19
      CharCase = ecUpperCase
      Ctl3D = False
      MaxLength = 30
      ParentCtl3D = False
      TabOrder = 3
      OnKeyPress = edCodigoKeyPress
    end
  end
  inherited pnBtns: TPanel
    Top = 518
    Width = 824
    inherited btnSair: TBitBtn
      Left = 744
      TabOrder = 4
    end
    object btnGravar: TBitBtn
      Left = 440
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Gravar'
      TabOrder = 0
      OnClick = btnGravarClick
    end
    object BitDesativar: TBitBtn
      Left = 592
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Desativar'
      TabOrder = 2
      OnClick = BitDesativarClick
    end
    object btnExcluir: TBitBtn
      Left = 668
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Excluir'
      TabOrder = 3
      OnClick = btnExcluirClick
    end
    object btnLimpar: TBitBtn
      Left = 516
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
    Top = 40
    Width = 824
    Height = 478
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
    OnDrawColumnCell = DBGridGradeDrawColumnCell
    OnDblClick = DBGridGradeDblClick
    Columns = <
      item
        Alignment = taRightJustify
        Expanded = False
        FieldName = 'Codigo'
        Title.Caption = 'C'#243'digo'
        Width = 63
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Classificacao'
        Title.Caption = 'Classifica'#231#227'o'
        Width = 86
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DESCRICAO_'
        Title.Caption = 'Nome da categoria'
        Width = 466
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Apelido'
        Width = 145
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Sta'
        Title.Caption = 'Ativa'
        Width = 29
        Visible = True
      end>
  end
  object pFIBTrGrade: TpFIBTransaction
    DefaultDatabase = fDataM.FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 79
    Top = 124
  end
  object qrGrade: TpFIBDataSet
    Transaction = pFIBTrGrade
    Database = fDataM.FIB_Db
    Left = 79
    Top = 172
  end
  object pFIBDSProvGrade: TpFIBDataSetProvider
    DataSet = qrGrade
    Left = 79
    Top = 218
  end
  object pFIBCdsGrade: TpFIBClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'pFIBDSProvGrade'
    AfterOpen = pFIBCdsGradeAfterOpen
    AfterScroll = pFIBCdsGradeAfterScroll
    Left = 79
    Top = 264
  end
  object dsGrade: TDataSource
    DataSet = pFIBCdsGrade
    Left = 79
    Top = 313
  end
end
