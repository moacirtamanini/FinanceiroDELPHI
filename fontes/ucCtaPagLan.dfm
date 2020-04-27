inherited fcCtaPagLan: TfcCtaPagLan
  Left = 582
  Top = 226
  Width = 724
  Height = 640
  Caption = 'Contas A PAGAR'
  Constraints.MaxHeight = 800
  Constraints.MaxWidth = 724
  Constraints.MinHeight = 600
  Constraints.MinWidth = 724
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 708
    Height = 265
    object lbStatus: TLabel
      Left = 2
      Top = 43
      Width = 100
      Height = 37
      Alignment = taCenter
      AutoSize = False
      Caption = 'Pendente'
      Color = clGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
    inline frame_CtaPAG: Tframe_CtaPAG
      Left = 0
      Top = 4
      Width = 101
      Height = 38
      TabOrder = 0
      inherited spBusca: TPanel
        Left = 75
      end
      inherited edFatura: TCurrencyEdit
        Width = 72
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
    end
    object pnEdicao: TPanel
      Left = 102
      Top = 0
      Width = 606
      Height = 265
      Align = alRight
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      object Label1: TLabel
        Left = 360
        Top = 6
        Width = 64
        Height = 13
        Caption = 'Data Emiss'#227'o'
      end
      object Label2: TLabel
        Left = 449
        Top = 6
        Width = 69
        Height = 13
        Caption = 'N'#186' Documento'
      end
      object Label3: TLabel
        Left = 3
        Top = 46
        Width = 40
        Height = 13
        Caption = 'Parcelas'
      end
      object Label4: TLabel
        Left = 98
        Top = 46
        Width = 62
        Height = 13
        Caption = 'Valor Parcela'
      end
      object Label6: TLabel
        Left = 180
        Top = 46
        Width = 76
        Height = 13
        Caption = 'Valor 1'#170' Parcela'
      end
      object Label10: TLabel
        Left = 299
        Top = 46
        Width = 51
        Height = 13
        Caption = 'Valor Total'
      end
      object Label7: TLabel
        Left = 380
        Top = 46
        Width = 74
        Height = 13
        Caption = 'Dia Fixo Vencto'
      end
      object Label5: TLabel
        Left = 488
        Top = 46
        Width = 75
        Height = 13
        Caption = 'Data 1'#170' Parcela'
      end
      object spGerarParcelas: TSpeedButton
        Left = 489
        Top = 84
        Width = 108
        Height = 107
        Caption = 'Calcular Parcelas'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = spGerarParcelasClick
      end
      object Label12: TLabel
        Left = 92
        Top = 196
        Width = 41
        Height = 13
        Caption = 'Hist'#243'rico'
      end
      object Label8: TLabel
        Left = 5
        Top = 232
        Width = 97
        Height = 13
        Caption = 'Descri'#231#227'o detalhada'
      end
      inline Frame_ForCli: TFrame_ForCli
        Left = 0
        Top = 4
        Width = 358
        Height = 38
        TabOrder = 0
        inherited edNome: TEdit
          OnKeyPress = frame_CtaPAGedFaturaKeyPress
        end
      end
      object edDataEmissao: TDateEdit
        Left = 360
        Top = 20
        Width = 84
        Height = 19
        Ctl3D = False
        NumGlyphs = 2
        ParentCtl3D = False
        TabOrder = 1
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
      object edDoctoNRO: TEdit
        Left = 445
        Top = 20
        Width = 150
        Height = 19
        Ctl3D = False
        MaxLength = 30
        ParentCtl3D = False
        TabOrder = 2
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
      object pnCombo: TPanel
        Left = 3
        Top = 60
        Width = 21
        Height = 19
        BevelOuter = bvNone
        Caption = '6'
        Color = 12615680
        Ctl3D = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Marlett'
        Font.Style = []
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 3
        OnClick = pnComboClick
      end
      object edParcelaQTDE: TCurrencyEdit
        Left = 24
        Top = 60
        Width = 44
        Height = 19
        AutoSize = False
        Ctl3D = False
        DecimalPlaces = 0
        DisplayFormat = ',0;,0'
        MaxLength = 3
        ParentCtl3D = False
        TabOrder = 4
        OnChange = edParcelaQTDEChange
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
      object edPacelaVLR: TCurrencyEdit
        Left = 72
        Top = 60
        Width = 90
        Height = 19
        AutoSize = False
        Ctl3D = False
        DisplayFormat = ',0.00;-,0.00'
        ParentCtl3D = False
        TabOrder = 5
        OnExit = edPacelaVLRExit
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
      object edVlr1aParce: TCurrencyEdit
        Left = 166
        Top = 60
        Width = 90
        Height = 19
        AutoSize = False
        Ctl3D = False
        DisplayFormat = ',0.00;-,0.00'
        ParentCtl3D = False
        TabOrder = 6
        OnExit = edData1aParceExit
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
      object edVlrPrincipal: TCurrencyEdit
        Left = 260
        Top = 60
        Width = 90
        Height = 19
        AutoSize = False
        Ctl3D = False
        DisplayFormat = ',0.00;-,0.00'
        ParentCtl3D = False
        TabOrder = 7
        OnExit = edVlrPrincipalExit
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
      object edDiaFixo: TCurrencyEdit
        Left = 405
        Top = 60
        Width = 25
        Height = 19
        Hint = 'Dia fixo de vencimento'
        AutoSize = False
        Ctl3D = False
        DecimalPlaces = 0
        DisplayFormat = ',0;,0'
        MaxLength = 2
        MaxValue = 28.000000000000000000
        ParentCtl3D = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 8
        OnExit = edDiaFixoExit
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
      object edData1aParce: TDateEdit
        Left = 488
        Top = 60
        Width = 84
        Height = 19
        Ctl3D = False
        NumGlyphs = 2
        ParentCtl3D = False
        TabOrder = 9
        OnExit = edData1aParceExit
        OnKeyPress = frame_CtaPAGedFaturaKeyPress
      end
      inline Frame_Moeda: TFrame_Moeda
        Left = 2
        Top = 80
        Width = 120
        Height = 38
        TabOrder = 10
        inherited lbMoeda: TLabel
          Width = 69
          Caption = 'Moeda Padr'#227'o'
        end
        inherited cbMoeda: TComboBox
          OnChange = Frame_MoedacbMoedaChange
          OnKeyPress = frame_CtaPAGedFaturaKeyPress
        end
      end
      inline Frame_Cartao: TFrame_Cartao
        Left = 125
        Top = 82
        Width = 359
        Height = 38
        TabOrder = 11
        inherited edCartao: TEdit
          Width = 332
          OnKeyPress = frame_CtaPAGedFaturaKeyPress
        end
        inherited spBusca: TPanel
          Left = 335
        end
      end
      inline frame_CategoriaSai: Tframe_Categoria
        Left = 3
        Top = 156
        Width = 485
        Height = 38
        TabOrder = 13
        inherited lbCodigo: TLabel
          Width = 96
          Caption = 'Categoria Pagadora'
        end
        inherited edCodigo: TEdit
          Width = 455
          OnKeyPress = frame_CtaPAGedFaturaKeyPress
        end
        inherited spBusca: TPanel
          Left = 458
        end
      end
      object edHistoDES: TEdit
        Left = 89
        Top = 210
        Width = 508
        Height = 19
        Ctl3D = False
        MaxLength = 255
        ParentCtl3D = False
        TabOrder = 15
        OnEnter = edHistoDESEnter
        OnKeyPress = edHistoDESKeyPress
      end
      object edDescricao: TEdit
        Left = 5
        Top = 246
        Width = 592
        Height = 19
        Ctl3D = False
        MaxLength = 255
        ParentCtl3D = False
        TabOrder = 16
        OnKeyPress = edHistoDESKeyPress
      end
      inline Frame_Histo: TFrame_Historico
        Left = 2
        Top = 194
        Width = 86
        Height = 38
        TabOrder = 14
        inherited edHisto: TCurrencyEdit
          OnKeyPress = frame_CtaPAGedFaturaKeyPress
        end
      end
      inline frame_CategoriaDes: Tframe_Categoria
        Left = 2
        Top = 119
        Width = 485
        Height = 38
        TabOrder = 12
        inherited lbCodigo: TLabel
          Width = 106
          Caption = 'Categoria de Despesa'
        end
        inherited edCodigo: TEdit
          Width = 455
          OnKeyPress = frame_CtaPAGedFaturaKeyPress
        end
        inherited spBusca: TPanel
          Left = 458
        end
      end
    end
  end
  inherited pnBtns: TPanel
    Top = 568
    Width = 708
    TabOrder = 2
    inherited btnSair: TBitBtn
      Left = 628
      TabOrder = 3
    end
    object btnGravar: TBitBtn
      Left = 476
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Gravar'
      TabOrder = 0
      OnClick = btnGravarClick
    end
    object btnLimpar: TBitBtn
      Left = 552
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Limpar'
      TabOrder = 1
      OnClick = btnLimparClick
    end
    object btnCancelar: TBitBtn
      Left = 3
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Cancelar'
      TabOrder = 2
      OnClick = btnCancelarClick
    end
  end
  object pnParce: TPanel
    Left = 0
    Top = 265
    Width = 708
    Height = 303
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object gbParce: TGroupBox
      Left = 0
      Top = 0
      Width = 708
      Height = 192
      Align = alClient
      Caption = 'Parcelas'
      Constraints.MinHeight = 140
      TabOrder = 0
      object DBGridParce: TDBGrid
        Left = 2
        Top = 15
        Width = 704
        Height = 175
        Align = alClient
        BorderStyle = bsNone
        DataSource = dsParce
        FixedColor = 16773345
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
        ParentColor = True
        PopupMenu = pmParcela
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnDrawColumnCell = DBGridParceDrawColumnCell
        OnDblClick = DBGridParceDblClick
        Columns = <
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ParceParce'
            Title.Alignment = taRightJustify
            Title.Caption = 'Parcela'
            Width = 44
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ParceVencto'
            Title.Caption = 'Vencimento'
            Width = 62
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ParceVlrPri'
            Title.Alignment = taRightJustify
            Title.Caption = 'Valor Parcela'
            Width = 74
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ParceVlrPag'
            Title.Alignment = taRightJustify
            Title.Caption = 'Valor Pago'
            Width = 74
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ParceVlrSal'
            Title.Alignment = taRightJustify
            Title.Caption = 'Saldo A Pagar'
            Width = 74
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ParceMoedaDES'
            Title.Caption = 'Moeda Padr'#227'o'
            Width = 102
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ParceCartaoDES'
            Title.Caption = 'Cart'#227'o'
            Width = 140
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ParceStatusDES'
            Title.Caption = 'Status'
            Width = 102
            Visible = True
          end>
      end
    end
    object gbBaixas: TGroupBox
      Left = 0
      Top = 192
      Width = 708
      Height = 111
      Align = alBottom
      Caption = 'Baixas da parcela selecionada'
      Constraints.MinHeight = 100
      TabOrder = 1
      object DBGridBaixa: TDBGrid
        Left = 2
        Top = 15
        Width = 704
        Height = 94
        Align = alClient
        Ctl3D = False
        DataSource = dsBaixa
        FixedColor = 16773345
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'Tahoma'
        Font.Style = []
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ParentColor = True
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -9
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'Sequencia'
            Title.Alignment = taRightJustify
            Title.Caption = 'Seq'
            Width = 24
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
            FieldName = 'DataBaixa'
            Title.Caption = 'Data da baixa'
            Width = 82
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ValorPrincipal'
            Title.Alignment = taRightJustify
            Title.Caption = 'Valor Principal'
            Width = 70
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ValorJuros'
            Title.Alignment = taRightJustify
            Title.Caption = 'Valor Juros'
            Width = 70
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ValorMulta'
            Title.Alignment = taRightJustify
            Title.Caption = 'Valor Multa'
            Width = 70
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ValorDesconto'
            Title.Alignment = taRightJustify
            Title.Caption = 'Vlr. Desconto'
            Width = 70
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ValorTotal'
            Title.Alignment = taRightJustify
            Title.Caption = 'Valor Total'
            Width = 70
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'StatusDES'
            Title.Caption = 'Status'
            Width = 76
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'HistoDES'
            Title.Caption = 'Hist'#243'rico'
            Width = 300
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'DataLancto'
            Title.Caption = 'Data Lan'#231'amento'
            Width = 82
            Visible = True
          end>
      end
    end
  end
  object pmParceTIP: TPopupMenu
    Left = 30
    Top = 105
    object mmParceTipFixo: TMenuItem
      Caption = 'Fixo'
      Checked = True
      Default = True
      GroupIndex = 1
      RadioItem = True
      OnClick = mmParceTipContClick
    end
    object mmParceTipCont: TMenuItem
      Caption = 'Cont'#237'nuo'
      GroupIndex = 1
      RadioItem = True
      OnClick = mmParceTipContClick
    end
  end
  object dsParce: TDataSource
    Left = 16
    Top = 340
  end
  object pFIBTrBaixa: TpFIBTransaction
    DefaultDatabase = fDataM.FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 51
    Top = 505
  end
  object qrBaixa: TpFIBDataSet
    Transaction = pFIBTrBaixa
    Database = fDataM.FIB_Db
    Left = 107
    Top = 505
  end
  object pFIBDSProvBaixa: TpFIBDataSetProvider
    DataSet = qrBaixa
    Left = 163
    Top = 505
  end
  object pFIBCdsBaixa: TpFIBClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'pFIBDSProvBaixa'
    Left = 219
    Top = 505
  end
  object dsBaixa: TDataSource
    DataSet = pFIBCdsBaixa
    Left = 275
    Top = 505
  end
  object pmParcela: TPopupMenu
    OnPopup = pmParcelaPopup
    Left = 72
    Top = 340
    object mmParceAlterar: TMenuItem
      Caption = 'Alterar'
      OnClick = mmParceAlterarClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mmGerarParcela: TMenuItem
      Caption = 'Gerar parcela'
      OnClick = mmGerarParcelaClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mmParceBaixar: TMenuItem
      Caption = 'Baixar'
      OnClick = mmParceBaixarClick
    end
  end
end
