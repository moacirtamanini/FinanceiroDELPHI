inherited fcConFluxoDeCaixa: TfcConFluxoDeCaixa
  Left = 466
  Top = 228
  BorderIcons = [biSystemMenu, biMinimize, biMaximize]
  Caption = 'Fluxo de Caixa'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Height = 498
    Align = alClient
    object DBGridFluxo: TDBGrid
      Left = 0
      Top = 0
      Width = 1008
      Height = 498
      Align = alClient
      Ctl3D = False
      DataSource = dsFluxo
      FixedColor = 16773345
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      ParentColor = True
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnDrawColumnCell = DBGridFluxoDrawColumnCell
      Columns = <
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'ContaCOD'
          Title.Alignment = taRightJustify
          Title.Caption = 'Conta'
          Width = 42
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ContaDES'
          Title.Caption = 'Nome da conta'
          Width = 160
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'MoedaDES'
          Title.Caption = 'Moeda'
          Width = 100
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'FormaPAG'
          Title.Caption = 'Forma de pagamento'
          Width = 160
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA00M01'
          Title.Alignment = taCenter
          Title.Caption = 'At'#233' 01/2018'
          Width = 70
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M01'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'VlrA01M02'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'VlrA01M03'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M04'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M05'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M06'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M07'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M08'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M09'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M10'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M11'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA01M12'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M01'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M02'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M03'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M04'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M05'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M06'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M07'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M08'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M09'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M10'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M11'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA02M12'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M01'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M02'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M03'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M04'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M05'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M06'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M07'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M08'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M09'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M10'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M11'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA03M12'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M01'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M02'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M03'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M04'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M05'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M06'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M07'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M08'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M09'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M10'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M11'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA04M12'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M01'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M02'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M03'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M04'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M05'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M06'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M07'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M08'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M09'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M10'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M11'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA05M12'
          Title.Alignment = taCenter
          Width = 62
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M01'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M02'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M03'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M04'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M05'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M06'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M07'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M08'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M09'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M10'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M11'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA06M12'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M01'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M02'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M03'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M04'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M05'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M06'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M07'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M08'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M09'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M10'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M11'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA07M12'
          Title.Alignment = taCenter
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'VlrA99M12'
          Title.Alignment = taCenter
          Width = 70
          Visible = True
        end>
    end
  end
  inherited pnBtns: TPanel
    object btnFluxo: TBitBtn
      Left = 851
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Gerar'
      TabOrder = 1
      OnClick = btnFluxoClick
    end
    object ckDisponibilidades: TCheckBox
      Left = 7
      Top = 8
      Width = 138
      Height = 17
      Caption = 'Mostrar Disponibilidades'
      TabOrder = 2
    end
    object ckReceitas: TCheckBox
      Left = 168
      Top = 8
      Width = 105
      Height = 17
      Caption = 'Mostrar Receitas'
      TabOrder = 3
    end
  end
  object pFIBTrFluxo: TpFIBTransaction
    DefaultDatabase = fDataM.FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 19
    Top = 25
  end
  object qrFluxo: TpFIBDataSet
    Transaction = pFIBTrFluxo
    Database = fDataM.FIB_Db
    Left = 75
    Top = 25
  end
  object pFIBDSProvFluxo: TpFIBDataSetProvider
    DataSet = qrFluxo
    Left = 131
    Top = 25
  end
  object pFIBCdsFluxo: TpFIBClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'pFIBDSProvFluxo'
    Left = 187
    Top = 25
  end
  object dsFluxo: TDataSource
    DataSet = pFIBCdsFluxo
    Left = 243
    Top = 25
  end
end
