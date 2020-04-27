inherited fcCadBandeira: TfcCadBandeira
  Left = 695
  Top = 301
  Width = 362
  Height = 450
  Caption = 'Bandeiras'
  Constraints.MaxWidth = 362
  Constraints.MinHeight = 250
  Constraints.MinWidth = 362
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 346
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
      Width = 87
      Height = 13
      Caption = 'Nome da bandeira'
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
  end
  inherited pnBtns: TPanel
    Top = 378
    Width = 346
    inherited btnSair: TBitBtn
      Left = 266
      Caption = '&Sair'
      TabOrder = 3
    end
    object btnGravar: TBitBtn
      Left = 40
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Gravar'
      TabOrder = 0
      OnClick = btnGravarClick
    end
    object btnExcluir: TBitBtn
      Left = 190
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnLimpar: TBitBtn
      Left = 115
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
    Width = 346
    Height = 334
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
        FieldName = 'ID'
        Title.Caption = 'C'#243'digo'
        Width = 63
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Descricao'
        Title.Caption = 'Nome da bandeira'
        Width = 255
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
