unit ucEmpresaCadastro;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Mask, ExtCtrls, rtEmpresa;

type
  TfcEmpresaCadastro = class(TForm)
    pnRegistro: TPanel;
    Label2: TLabel;
    Label9: TLabel;
    Label1: TLabel;
    edCPFCNPJ: TEdit;
    edEmail: TEdit;
    edSenha: TEdit;
    pnBtns: TPanel;
    btnSair: TBitBtn;
    btnVerificar: TBitBtn;
    procedure btnSairClick(Sender: TObject);
    procedure btnVerificarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnKeyPress(Sender: TObject; var Key: Char);
  private
    wEmpre: TEmpresa;
    function fGetID: Integer;
    function fGetCNPFCNPJ: String;
    function fGetEMAIL   : String;
    function fGetSenha   : String;
  public
    property ppGetID     : Integer read fGetID;
    property ppGetCPFCNPJ: String  read fGetCNPFCNPJ;
    property ppGetEMAIL  : String  read fGetEMAIL;
    property ppGetSenha  : String  read fGetSenha;
  end;

var
  fcEmpresaCadastro: TfcEmpresaCadastro;

implementation

uses
  uUtils, rtTypes;

{$R *.dfm}

procedure TfcEmpresaCadastro.FormCreate(Sender: TObject);
begin
  wEmpre := TEmpresa.Create;
end;

procedure TfcEmpresaCadastro.OnKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 Then
  begin
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

procedure TfcEmpresaCadastro.btnSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfcEmpresaCadastro.fGetID: Integer;
begin
  Result := wEmpre.ppID;
end;

function TfcEmpresaCadastro.fGetCNPFCNPJ: String;
begin
  Result := fSomenteNumeros(edCPFCNPJ.Text);
end;

function TfcEmpresaCadastro.fGetEMAIL: String;
begin
  Result := edEmail.Text;
end;

function TfcEmpresaCadastro.fGetSenha: String;
begin
  Result := edSenha.Text;
end;

procedure TfcEmpresaCadastro.btnVerificarClick(Sender: TObject);

  function fConsisteDados: Boolean;
  begin
    Result := False;

    if (edCPFCNPJ.Text <> '') and (not ValidaCPFCNPJ(edCPFCNPJ.Text)) then
    begin
      MessageDlg('Informe o CPF/CNPJ', mtWarning, [mbOK], 0);
      fSetaFoco([edCPFCNPJ]);
      Exit;
    end;

    if (edEmail.Text <> '') and (not ValidaEmail(edEmail.Text)) then
    begin
      MessageDlg('Informe o e-mail', mtWarning, [mbOK], 0);
      fSetaFoco([edEmail]);
      Exit;
    end;

    if (edSenha.Text <> '') and (not ValidaSenha(edSenha.Text)) then
    begin
      MessageDlg('Informe uma senha', mtWarning, [mbOK], 0);
      fSetaFoco([edSenha]);
      Exit;
    end;

    if (Trim(edCPFCNPJ.Text) = '') and (Trim(edEmail.Text) = '') then
    begin
      MessageDlg('Informe o CPF/CNPJ ou o e-mail', mtWarning, [mbOK], 0);
      fSetaFoco([edCPFCNPJ]);
      Exit;
    end;

    Result := True;
  end;

var
  wID: Integer;
  wDados: TDadosEmp;
begin
  inherited;
  if (not fConsisteDados) then Exit;

  wEmpre.Clear;
  wDados.id          := 0;
  wDados.CPFNPJ      := edCPFCNPJ.Text;
  wDados.EMAIL       := edEmail.Text;
  wDados.SENHA       := edSenha.Text;
  wEmpre.ppDados := wDados;
  fSetaFoco([edCPFCNPJ]);
  if wEmpre.fValidarNova(wID) then
  begin
    wEmpre.ppID := wID;
    if (wID > 0) then
      Self.ModalResult := mrOk
    else
      Self.ModalResult := mrOk;
  end;
end;

procedure TfcEmpresaCadastro.FormDestroy(Sender: TObject);
begin
  wEmpre.Free;
end;

end.
