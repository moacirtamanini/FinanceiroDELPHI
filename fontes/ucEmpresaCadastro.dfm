object fcEmpresaCadastro: TfcEmpresaCadastro
  Left = 600
  Top = 426
  Width = 523
  Height = 149
  Caption = 'Pessoa / Empresa'
  Color = 16773345
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnRegistro: TPanel
    Left = 0
    Top = 0
    Width = 507
    Height = 76
    Align = alTop
    ParentColor = True
    TabOrder = 0
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
      TabOrder = 0
      OnKeyPress = OnKeyPress
    end
    object edEmail: TEdit
      Left = 127
      Top = 18
      Width = 376
      Height = 19
      Ctl3D = False
      MaxLength = 255
      ParentCtl3D = False
      TabOrder = 1
      OnKeyPress = OnKeyPress
    end
    object edSenha: TEdit
      Left = 127
      Top = 53
      Width = 376
      Height = 19
      Ctl3D = False
      MaxLength = 255
      ParentCtl3D = False
      PasswordChar = '#'
      TabOrder = 2
      OnKeyPress = OnKeyPress
    end
  end
  object pnBtns: TPanel
    Left = 0
    Top = 77
    Width = 507
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    DesignSize = (
      507
      33)
    object btnSair: TBitBtn
      Left = 427
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Sair'
      TabOrder = 1
      OnClick = btnSairClick
    end
    object btnVerificar: TBitBtn
      Left = 351
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Verificar'
      TabOrder = 0
      OnClick = btnVerificarClick
    end
  end
end
