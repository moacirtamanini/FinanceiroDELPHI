inherited fcCadHistorico: TfcCadHistorico
  Left = 513
  Top = 232
  Width = 592
  Height = 508
  Caption = 'Hist'#243'rico Padr'#227'o'
  Constraints.MaxWidth = 592
  Constraints.MinHeight = 200
  Constraints.MinWidth = 592
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 576
    Height = 44
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
      Width = 86
      Height = 13
      Caption = 'Texto do hist'#243'rico'
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
      Width = 486
      Height = 19
      CharCase = ecUpperCase
      Ctl3D = False
      MaxLength = 100
      ParentCtl3D = False
      TabOrder = 1
      OnKeyPress = edCodigoKeyPress
    end
  end
  inherited pnBtns: TPanel
    Top = 436
    Width = 576
    inherited btnSair: TBitBtn
      Left = 496
      TabOrder = 3
    end
    object btnGravar: TBitBtn
      Left = 195
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Gravar'
      TabOrder = 0
      OnClick = btnGravarClick
    end
    object btnExcluir: TBitBtn
      Left = 421
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object BitDesativar: TBitBtn
      Left = 345
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Desativar'
      TabOrder = 4
      OnClick = BitDesativarClick
    end
    object btnLimpar: TBitBtn
      Left = 270
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
    Top = 44
    Width = 576
    Height = 392
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
        FieldName = 'Codigo'
        Title.Caption = 'C'#243'digo'
        Width = 63
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Descricao'
        Title.Caption = 'Hist'#243'rico'
        Width = 455
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Sta'
        Title.Caption = 'Ativo'
        Width = 29
        Visible = True
      end>
  end
  object pFIBTrGrade: TpFIBTransaction
    DefaultDatabase = fDataM.FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 47
    Top = 92
  end
  object qrGrade: TpFIBDataSet
    Transaction = pFIBTrGrade
    Database = fDataM.FIB_Db
    Left = 47
    Top = 140
  end
  object pFIBDSProvGrade: TpFIBDataSetProvider
    DataSet = qrGrade
    Left = 47
    Top = 186
  end
  object pFIBCdsGrade: TpFIBClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'pFIBDSProvGrade'
    AfterOpen = pFIBCdsGradeAfterOpen
    AfterScroll = pFIBCdsGradeAfterScroll
    Left = 47
    Top = 232
  end
  object dsGrade: TDataSource
    DataSet = pFIBCdsGrade
    Left = 47
    Top = 281
  end
end
