unit ucLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, rtEmpresa;

type
  TfrmLogin = class(TForm)
    pnBtns: TPanel;
    pnCadastrado: TPanel;
    Label2: TLabel;
    edLogin: TEdit;
    Label1: TLabel;
    edSenha: TEdit;
    lbMsg: TLabel;
    spEntrar: TSpeedButton;
    spSair: TSpeedButton;
    lbNovo: TLabel;
    lbSenha: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OnKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure spEntrarClick(Sender: TObject);
    procedure spSairClick(Sender: TObject);
    procedure lbNovoClick(Sender: TObject);
  private
    wEmpre: TEmpresa;
    fEmpresa: Integer;
    fEmpresaNome, fEmpresaApel, fEmpresaCPFC: String;
  public
    property ppEmpresa: Integer read fEmpresa;
    property ppEmpresaNome: String read fEmpresaNome;
    property ppEmpresaApel: String read fEmpresaApel;
    property ppEmpresaCPFC: String read fEmpresaCPFC;
  end;

var
  frmLogin: TfrmLogin;

implementation

uses ucPrincipal, uUtils, ucEmpresa, ucEmpresaCadastro;

{$R *.dfm}

procedure TfrmLogin.OnKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 Then
  begin
    spEntrarClick(Sender);
    if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
      SelectNext(Sender as TWinControl, False, True)
    else
      SelectNext(Sender as TWinControl, True, True);
    Key := #0
  end;

  if Key = #27 Then
  begin
    if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
      SelectNext(Sender as TWinControl, True, True)
    else
      SelectNext(Sender as TWinControl, False, True);
    Key := #0
  end;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  fEmpresa     := 0;
  fEmpresaNome := '';
  fEmpresaApel := '';
  fEmpresaCPFC := '';
  wEmpre       := TEmpresa.Create;
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  wEmpre.Free;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  fSetaFoco([edLogin]);
end;

procedure TfrmLogin.spEntrarClick(Sender: TObject);
begin
  if Length(Trim(edLogin.Text)) > 0 then
  begin
    if ValidaCPFCNPJ(fSomenteNumeros(edLogin.Text), False) then
      fEmpresa     := wEmpre.CarregaCPFCNPJ(fSomenteNumeros(edLogin.Text), edSenha.Text)
    else
    begin
      if ValidaEmail(edLogin.Text) then
        fEmpresa := wEmpre.CarregaEMAIL(edLogin.Text, edSenha.Text)
      else
        fEmpresa := wEmpre.CarregaAPELIDO(edLogin.Text, edSenha.Text);
    end;

    if fEmpresa > 0 then
    begin
      fEmpresaNome := wEmpre.ppDados.Nome;
      fEmpresaApel := wEmpre.ppDados.Apelido;
      fEmpresaCPFC := wEmpre.ppDados.CPFNPJ;
      ModalResult := mrOk
    end
    else
    begin
      lbMsg.Visible := True;
      lbMsg.Caption := 'Identificação e/ou Senha inválida';
      fSetaFoco([edLogin]);
    end;
  end
  else
  begin
    lbMsg.Visible := True;
    lbMsg.Caption := 'Informe o CPF ou o CNPJ ou o E-Mail e a Senha para entrar';
    fSetaFoco([edLogin]);
  end;
end;

procedure TfrmLogin.spSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmLogin.lbNovoClick(Sender: TObject);
var
  wContinua: Boolean;
  wCPFCNPJ, wEMAIL, wSENHA: String;
  wID: Integer;
begin
  wContinua := False;
  wID       := 0;
  wCPFCNPJ  := '';
  wEMAIL    := '';
  wSENHA    := '';

  if fInicializaForm(TForm(fcEmpresaCadastro)) then
    fcEmpresaCadastro := TfcEmpresaCadastro.Create(Self);
  try
    if ValidaCPFCNPJ(edLogin.Text, False) then 
      fcEmpresaCadastro.edCPFCNPJ.Text := edLogin.Text;

    if ValidaEmail(edLogin.Text) then
      fcEmpresaCadastro.edEmail.Text   := edLogin.Text;

    fcEmpresaCadastro.edSenha.Text     := edSenha.Text;
    fcEmpresaCadastro.ShowModal;
    if fcEmpresaCadastro.ModalResult = mrOk then
    begin
      wContinua := True;
      wID       := fcEmpresaCadastro.ppGetID;
      wCPFCNPJ  := fcEmpresaCadastro.ppGetCPFCNPJ;
      wEMAIL    := fcEmpresaCadastro.ppGetEMAIL;
      wSENHA    := fcEmpresaCadastro.ppGetSenha;
    end;
  finally
    FreeAndNil(fcEmpresaCadastro);
  end;

  if (wContinua) then
  begin
    if (wID > 0) then
    begin
      edLogin.Text := wCPFCNPJ;
      edSenha.Text := wSENHA;
      fSetaFoco([edLogin]);
      spEntrarClick(Sender);
    end
    else
    begin
      if fInicializaForm(TForm(fcEmpresa)) then
        fcEmpresa := TfcEmpresa.Create(Self);
      try
        fcEmpresa.ppCadastrar    := True;
        fcEmpresa.edCPFCNPJ.Text := wCPFCNPJ;
        fcEmpresa.edEmail.Text   := wEMAIL;
        fcEmpresa.edSenha.Text   := wSENHA;
        fcEmpresa.ShowModal;
        if fcEmpresa.ModalResult = mrOk then
        begin
          edLogin.Text := fcEmpresa.ppGetCPFCNPJ;
          edSenha.Text := fcEmpresa.ppGetSenha;
          fSetaFoco([edLogin]);
        end;
      finally
        FreeAndNil(fcEmpresa);
      end;
    end;
  end;
end;

end.
