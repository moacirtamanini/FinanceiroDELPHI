inherited fcEmpresa: TfcEmpresa
  Left = 717
  Top = 308
  VertScrollBar.Range = 0
  BorderStyle = bsDialog
  Caption = 'Pessoa / Empresa'
  ClientHeight = 400
  ClientWidth = 510
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnTop: TPanel
    Width = 510
    Height = 367
    Align = alClient
    object Label3: TLabel
      Left = 8
      Top = 79
      Width = 97
      Height = 13
      Caption = 'Nome / Raz'#227'o Social'
    end
    object Label4: TLabel
      Left = 383
      Top = 79
      Width = 86
      Height = 13
      Caption = 'Apelido / Fantasia'
    end
    object lbAlteracao: TLabel
      Left = 0
      Top = 0
      Width = 507
      Height = 76
      Alignment = taCenter
      AutoSize = False
      Caption = 'Altera'#231#227'o dos dados cadastrais'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
    end
    object pnRegistro: TPanel
      Left = 0
      Top = 0
      Width = 510
      Height = 76
      Align = alTop
      ParentColor = True
      TabOrder = 0
      Visible = False
      object Label2: TLabel
        Left = 8
        Top = 4
        Width = 54
        Height = 13
        Caption = 'CPF / CNPJ'
      end
      object Label9: TLabel
        Left = 127
        Top = 4
        Width = 28
        Height = 13
        Caption = 'E-mail'
      end
      object Label1: TLabel
        Left = 127
        Top = 39
        Width = 30
        Height = 13
        Caption = 'Senha'
      end
      object edCPFCNPJ: TEdit
        Left = 8
        Top = 18
        Width = 116
        Height = 19
        Ctl3D = False
        MaxLength = 18
        ParentCtl3D = False
        ReadOnly = True
        TabOrder = 0
        OnKeyPress = OnKeyPress
      end
      object edEmail: TEdit
        Left = 127
        Top = 18
        Width = 374
        Height = 19
        Ctl3D = False
        MaxLength = 255
        ParentCtl3D = False
        ReadOnly = True
        TabOrder = 1
        OnKeyPress = OnKeyPress
      end
      object edCodigo: TCurrencyEdit
        Left = 432
        Top = 18
        Width = 68
        Height = 19
        AutoSize = False
        Ctl3D = False
        DecimalPlaces = 0
        DisplayFormat = ',0;,0'
        ParentCtl3D = False
        TabOrder = 2
        Visible = False
        OnExit = edCodigoExit
      end
      object edSenha: TEdit
        Left = 127
        Top = 53
        Width = 374
        Height = 19
        Ctl3D = False
        MaxLength = 255
        ParentCtl3D = False
        PasswordChar = '#'
        ReadOnly = True
        TabOrder = 3
        OnKeyPress = OnKeyPress
      end
    end
    object edNome: TEdit
      Left = 8
      Top = 93
      Width = 373
      Height = 19
      CharCase = ecUpperCase
      Ctl3D = False
      MaxLength = 100
      ParentCtl3D = False
      TabOrder = 1
      OnKeyPress = OnKeyPress
    end
    object edApelido: TEdit
      Left = 383
      Top = 93
      Width = 118
      Height = 19
      CharCase = ecUpperCase
      Ctl3D = False
      MaxLength = 20
      ParentCtl3D = False
      TabOrder = 2
      OnKeyPress = OnKeyPress
    end
    inline frame_End: Tframe_Endereco
      Left = 6
      Top = 118
      Width = 498
      Height = 193
      TabOrder = 3
      inherited edCEP: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edLogradouro: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edNumero: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edUF: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edCidade: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edBairro: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edComplemento: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edEmail: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edSite: TEdit
        OnKeyPress = OnKeyPress
      end
    end
    inline frame_Fon: Tframe_Fone
      Left = 6
      Top = 314
      Width = 498
      Height = 51
      TabOrder = 4
      inherited edFonCenDDD: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edFonCenNRO: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edFonComDDD: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edFonComNRO: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edFonCelDDD: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edFonCelNRO: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edFonFaxDDD: TEdit
        OnKeyPress = OnKeyPress
      end
      inherited edFonFaxNRO: TEdit
        OnKeyPress = OnKeyPress
      end
    end
  end
  inherited pnBtns: TPanel
    Top = 367
    Width = 510
    DesignSize = (
      510
      33)
    inherited btnSair: TBitBtn
      Left = 430
      TabOrder = 1
    end
    object btnGravar: TBitBtn
      Left = 354
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Gravar'
      TabOrder = 0
      OnClick = btnGravarClick
    end
  end
end
