inherited fcBrwHistorico: TfcBrwHistorico
  Left = 584
  Top = 261
  VertScrollBar.Range = 0
  BorderStyle = bsSingle
  Caption = 'Sele'#231#227'o de Hist'#243'rico'
  ClientHeight = 461
  ClientWidth = 584
  KeyPreview = True
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 584
    Height = 428
    Align = alClient
    BorderWidth = 4
    object DBGridGrade: TDBGrid
      Left = 4
      Top = 4
      Width = 576
      Height = 420
      Align = alClient
      BorderStyle = bsNone
      Ctl3D = False
      DataSource = dsGrade
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [dgTitles, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      ParentColor = True
      ParentCtl3D = False
      ParentFont = False
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
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 50
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Descricao'
          Title.Caption = 'Descri'#231#227'o'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 500
          Visible = True
        end>
    end
  end
  inherited pnBtns: TPanel
    Top = 428
    Width = 584
    inherited btnSair: TBitBtn
      Left = 504
    end
    object btnCarregar: TBitBtn
      Left = 428
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
    Left = 31
    Top = 36
  end
  object qrGrade: TpFIBDataSet
    Transaction = pFIBTrGrade
    Database = fDataM.FIB_Db
    Left = 31
    Top = 84
  end
  object pFIBDSProvGrade: TpFIBDataSetProvider
    DataSet = qrGrade
    Left = 31
    Top = 130
  end
  object pFIBCdsGrade: TpFIBClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'pFIBDSProvGrade'
    Left = 31
    Top = 176
  end
  object dsGrade: TDataSource
    DataSet = pFIBCdsGrade
    Left = 31
    Top = 225
  end
end
