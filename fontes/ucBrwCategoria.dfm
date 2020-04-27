inherited fcBrwCategoria: TfcBrwCategoria
  Left = 418
  Top = 235
  Width = 838
  Caption = 'Sele'#231#227'o da Categoria'
  KeyPreview = True
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 822
    Height = 498
    Align = alClient
    object DBGridGrade: TDBGrid
      Left = 0
      Top = 0
      Width = 822
      Height = 498
      Align = alClient
      Ctl3D = False
      DataSource = dsGrade
      FixedColor = 16773345
      Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      ParentColor = True
      ParentCtl3D = False
      TabOrder = 0
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
  end
  inherited pnBtns: TPanel
    Width = 822
    inherited btnSair: TBitBtn
      Left = 742
    end
    object btnCarregar: TBitBtn
      Left = 665
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Carregar'
      TabOrder = 1
      OnClick = btnCarregarClick
    end
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
    Left = 79
    Top = 264
  end
  object dsGrade: TDataSource
    DataSet = pFIBCdsGrade
    Left = 79
    Top = 313
  end
end
