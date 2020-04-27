inherited fcBrwFaturaCTAPAG: TfcBrwFaturaCTAPAG
  Left = 387
  Top = 245
  Caption = 'Consulta de Faturas A PAGAR'
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
      Options = [dgTitles, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      ParentColor = True
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
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
          Title.Alignment = taRightJustify
          Title.Caption = 'Fatura'
          Width = 70
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DataEmissao'
          Title.Caption = 'Data Emiss'#227'o'
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Emitente'
          Title.Caption = 'Nome do emitente'
          Width = 200
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'DoctoNro'
          Title.Caption = 'N'#186' Documento'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Descricao'
          Title.Caption = 'Descri'#231#227'o detalhada'
          Width = 200
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'ParcelaQTDE'
          Title.Alignment = taRightJustify
          Title.Caption = 'Parcelas'
          Width = 48
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ParcelaTIPODES'
          Title.Caption = 'Tipo Parcelamento'
          Width = 100
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'ValorParcela'
          Title.Alignment = taRightJustify
          Title.Caption = 'Valor Parcela'
          Width = 80
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'ValorPrincipal'
          Title.Alignment = taRightJustify
          Title.Caption = 'Valor Principal'
          Width = 80
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'ValorPago'
          Title.Alignment = taRightJustify
          Title.Caption = 'Valor Pago'
          Width = 80
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'ValorSaldo'
          Title.Alignment = taRightJustify
          Title.Caption = 'Saldo A Pagar'
          Width = 80
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'MoedaDES'
          Title.Caption = 'Tipo de moeda'
          Width = 120
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CartaoDES'
          Title.Caption = 'Cart'#227'o'
          Width = 130
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'categoriaSaiDES'
          Title.Caption = 'Categoria sa'#237'da'
          Width = 200
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'StatusDES'
          Title.Caption = 'Status'
          Width = 100
          Visible = True
        end>
    end
  end
  inherited pnBtns: TPanel
    inherited btnSair: TBitBtn
      TabOrder = 1
    end
    object btnCarregar: TBitBtn
      Left = 852
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Carregar'
      TabOrder = 0
      OnClick = btnCarregarClick
    end
    object ckQuitadas: TCheckBox
      Left = 15
      Top = 8
      Width = 66
      Height = 17
      Caption = 'Quitadas'
      TabOrder = 2
      OnClick = ckQuitadasClick
    end
    object ckCanceladas: TCheckBox
      Left = 123
      Top = 8
      Width = 78
      Height = 17
      Caption = 'Canceladas'
      TabOrder = 3
      OnClick = ckQuitadasClick
    end
  end
  object pFIBTrGrade: TpFIBTransaction
    DefaultDatabase = fDataM.FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 71
    Top = 52
  end
  object qrGrade: TpFIBDataSet
    Transaction = pFIBTrGrade
    Database = fDataM.FIB_Db
    Left = 71
    Top = 100
  end
  object pFIBDSProvGrade: TpFIBDataSetProvider
    DataSet = qrGrade
    Left = 71
    Top = 146
  end
  object pFIBCdsGrade: TpFIBClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'pFIBDSProvGrade'
    Left = 71
    Top = 192
  end
  object dsGrade: TDataSource
    DataSet = pFIBCdsGrade
    Left = 71
    Top = 241
  end
end
