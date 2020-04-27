object frPrincipal: TfrPrincipal
  Left = 546
  Top = 369
  Width = 674
  Height = 383
  Caption = 'Financeiro'
  Color = 16773345
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MenuPri
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnBottom: TPanel
    Left = 0
    Top = 283
    Width = 658
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = True
    ParentColor = True
    TabOrder = 0
    object staEmpresa: TStatusBar
      Left = 0
      Top = 20
      Width = 658
      Height = 21
      Panels = <
        item
          Alignment = taCenter
          Width = 130
        end
        item
          Alignment = taCenter
          Width = 130
        end
        item
          Alignment = taCenter
          Width = 130
        end
        item
          Width = 50
        end>
      ParentColor = True
    end
  end
  object wbFundo: TWebBrowser
    Left = 0
    Top = 0
    Width = 658
    Height = 283
    Align = alClient
    TabOrder = 1
    ControlData = {
      4C00000002440000401D00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object MenuPri: TMainMenu
    Left = 20
    Top = 32
    object mmCadastros: TMenuItem
      Caption = 'Cadastros'
      object miCadCategoria: TMenuItem
        Caption = 'Categorias de contas'
        OnClick = miCadCategoriaClick
      end
      object miCadHistorico: TMenuItem
        Caption = 'Hist'#243'ricos'
        OnClick = miCadHistoricoClick
      end
      object miCadCartao: TMenuItem
        Caption = 'Cart'#245'es'
        object miCadBandeira: TMenuItem
          Caption = 'Bandeiras'
          OnClick = miCadBandeiraClick
        end
        object miCadCartoes: TMenuItem
          Caption = 'Cart'#245'es'
          OnClick = miCadCartoesClick
        end
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object miCadClientes: TMenuItem
        Caption = 'Clientes'
        OnClick = miCadClientesClick
      end
      object miCadFornecedores: TMenuItem
        Caption = 'Fornecedores'
        OnClick = miCadFornecedoresClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miCadUsuario: TMenuItem
        Caption = 'Usu'#225'rios'
      end
      object miCadEmpresaAlterar: TMenuItem
        Caption = 'Pessoa / Empresa'
        OnClick = miCadEmpresaAlterarClick
      end
    end
    object mmConsultas: TMenuItem
      Caption = 'Consultas'
      object mmConFluxoCaixa: TMenuItem
        Caption = 'Fluxo de Caixa'
        OnClick = mmConFluxoCaixaClick
      end
      object miConBalancete: TMenuItem
        Caption = 'Balancete'
      end
    end
    object mmCtaPag: TMenuItem
      Caption = 'Contas a Pagar'
      object miCatPagLancar: TMenuItem
        Caption = 'Lan'#231'ar ou Alterar'
        OnClick = miCatPagLancarClick
      end
      object miCatPagBaixar: TMenuItem
        Caption = 'Baixar Pagamentos'
        OnClick = miCatPagBaixarClick
      end
    end
    object mmCtaRec: TMenuItem
      Caption = 'Contas a Receber'
      object miCtaRecLancar: TMenuItem
        Caption = 'Lan'#231'ar ou Alterar'
        OnClick = miCtaRecLancarClick
      end
      object miCtaRecReceber: TMenuItem
        Caption = 'Baixar Recebimentos'
        OnClick = miCtaRecReceberClick
      end
    end
    object mmLancamento: TMenuItem
      Caption = 'Lan'#231'amentos'
      object miLancamentosLancar: TMenuItem
        Caption = 'Lan'#231'ar ou Alterar'
      end
    end
  end
end
