inherited fcBrwCliente: TfcBrwCliente
  Left = 346
  Top = 232
  Caption = 'Sele'#231#227'o de Cliente'
  Constraints.MaxWidth = 1314
  Constraints.MinHeight = 200
  Constraints.MinWidth = 300
  KeyPreview = True
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Height = 498
    Align = alClient
    object DBGridGrade: TDBGrid
      Left = 0
      Top = 0
      Width = 1008
      Height = 498
      Align = alClient
      BorderStyle = bsNone
      Ctl3D = False
      DataSource = dsGrade
      FixedColor = 16773345
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
          FieldName = 'CPFCNPJ'
          Title.Caption = 'CPF / CNPJ'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'NOME'
          Title.Caption = 'Nome'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 200
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'APELIDO'
          Title.Caption = 'Apelido'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 70
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'LOGRA'
          Title.Caption = 'Logradouro'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 200
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'BAIRRO'
          Title.Caption = 'Bairro'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CIDADE'
          Title.Caption = 'Cidade'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'FONECEN'
          Title.Caption = 'Fone Central'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'FONCOM'
          Title.Caption = 'Fone Comercial'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'FONCEL'
          Title.Caption = 'Fone Celular'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'FONEFAX'
          Title.Caption = 'Fone FAX'
          Title.Color = 12615680
          Title.Font.Charset = DEFAULT_CHARSET
          Title.Font.Color = clWhite
          Title.Font.Height = -11
          Title.Font.Name = 'Tahoma'
          Title.Font.Style = [fsBold]
          Width = 100
          Visible = True
        end>
    end
  end
  inherited pnBtns: TPanel
    object btnCarregar: TBitBtn
      Left = 852
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
    Left = 39
    Top = 68
  end
  object qrGrade: TpFIBDataSet
    Transaction = pFIBTrGrade
    Database = fDataM.FIB_Db
    Left = 39
    Top = 116
  end
  object pFIBDSProvGrade: TpFIBDataSetProvider
    DataSet = qrGrade
    Left = 39
    Top = 162
  end
  object pFIBCdsGrade: TpFIBClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'pFIBDSProvGrade'
    Left = 39
    Top = 208
  end
  object dsGrade: TDataSource
    DataSet = pFIBCdsGrade
    Left = 39
    Top = 257
  end
end
