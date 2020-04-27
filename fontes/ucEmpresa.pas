unit ucEmpresa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, Mask, rtEmpresa, uFrame_Endereco, uFrame_Fone,
  rxToolEdit, rxCurrEdit;

type
  TfcEmpresa = class(TfcPadrao)
    edNome: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edApelido: TEdit;
    btnGravar: TBitBtn;
    frame_End: Tframe_Endereco;
    frame_Fon: Tframe_Fone;
    pnRegistro: TPanel;
    Label2: TLabel;
    edCPFCNPJ: TEdit;
    Label9: TLabel;
    edEmail: TEdit;
    edCodigo: TCurrencyEdit;
    Label1: TLabel;
    edSenha: TEdit;
    lbAlteracao: TLabel;
    procedure btnGravarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure edCodigoExit(Sender: TObject);
    procedure OnKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    fCadastrar: Boolean;
    wEmpre: TEmpresa;

    function fGetCNPFCNPJ: String;
    function fGetEMAIL   : String;
    function fGetSenha   : String;
  public
    property ppCadastrar : Boolean read fCadastrar write fCadastrar;
    property ppGetCPFCNPJ: String  read fGetCNPFCNPJ;
    property ppGetEMAIL  : String  read fGetEMAIL;
    property ppGetSenha  : String  read fGetSenha;
  end;

var
  fcEmpresa: TfcEmpresa;

implementation

uses uDataM, uUtils;

{$R *.dfm}

procedure TfcEmpresa.OnKeyPress(Sender: TObject; var Key: Char);
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

procedure TfcEmpresa.FormCreate(Sender: TObject);
begin
  inherited;
  fCadastrar := False;
  wEmpre := TEmpresa.Create;
end;

function TfcEmpresa.fGetCNPFCNPJ: String;
begin
  Result := edCPFCNPJ.Text;
end;

function TfcEmpresa.fGetEMAIL   : String;
begin
  Result := edEmail.Text;
end;

function TfcEmpresa.fGetSenha   : String;
begin
  Result := edSenha.Text;
end;

procedure TfcEmpresa.btnGravarClick(Sender: TObject);

  function fConsisteDados: Boolean;
  begin
    Result := False;

    if (not ValidaCPFCNPJ(edCPFCNPJ.Text)) then
    begin
      MessageDlg('CPF/CNPJ não informado!', mtWarning, [mbOK], 0);
      Exit;
    end;

    if (not ValidaEmail(edEmail.Text)) then
    begin
      MessageDlg('E-mail não informado!', mtWarning, [mbOK], 0);
      Exit;
    end;

    if (not ValidaSenha(edSenha.Text)) then
    begin
      MessageDlg('Senha não informada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    if Length(Trim(edNome.Text)) = 0 then
    begin
      MessageDlg('Informe o nome ou razão social', mtWarning, [mbOK], 0);
      fSetaFoco([edNome]);
      Exit;
    end;

    if Length(Trim(edApelido.Text)) = 0 then
    begin
      MessageDlg('Informe o apelido', mtWarning, [mbOK], 0);
      fSetaFoco([edApelido]);
      Exit;
    end;

    if (Length(Trim(edApelido.Text)) > 0) then
    begin
      if (Length(Trim(edApelido.Text)) = Length(fSomenteNumeros(edApelido.Text))) then
      begin
        MessageDlg('O apelido não pode ser somente números!', mtWarning, [mbOK], 0);
        Exit;
      end;
    end;  

    Result := True;
  end;

var
  wID: Integer;
  wDados: TDadosEmp;
begin
  inherited;
  if (not fConsisteDados) then Exit;

  if (ppCadastrar) or (Confirmar('Confirma a alteração dos dados cadastrais?')) then
  begin
    wEmpre.Clear;
    wDados.id          := edCodigo.AsInteger;
    wDados.CPFNPJ      := edCPFCNPJ.Text;
    wDados.EMAIL       := edEmail.Text;
    wDados.SENHA       := edSenha.Text;
    wEmpre.ppDados := wDados;
    if (not wEmpre.fPodeGravar(True, wID)) then Exit;

    wEmpre.Clear;
    wDados.id          := edCodigo.AsInteger;
    wDados.CPFNPJ      := edCPFCNPJ.Text;
    wDados.EMAIL       := edEmail.Text;
    wDados.SENHA       := edSenha.Text;
    wDados.Nome        := edNome.Text;
    wDados.Apelido     := edApelido.Text;
    wDados.Status      := 1;
    wDados.Endereco    := frame_End.fGravar;
    wDados.Fone        := frame_Fon.fGravar;
    wEmpre.ppDados := wDados;
    wID := wEmpre.fGravaEmpresa;
    if (wID > 0) then
    begin
      if ppCadastrar then
      begin
        fDataM.pGerarCategorias(wID);
        fDataM.pGerarHistoricos(wID);
        fDataM.pGerarBandeiras;
        Self.ModalResult := mrOk;
      end
      else
      begin
        fDataM.EmpresaNome := wDados.Nome;
        fDataM.EmpresaApel := wDados.Apelido;
        fDataM.EmpresaCPFC := wDados.CPFNPJ;
        Self.ModalResult := mrOk;
        Self.Close;
      end;
    end;
  end;
end;

procedure TfcEmpresa.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if (not ppCadastrar) then
    fcEmpresa := nil;
    
  wEmpre.Free;
  frame_End.Free;
  frame_Fon.Free;
end;

procedure TfcEmpresa.edCodigoExit(Sender: TObject);
begin
  inherited;
  wEmpre.ppID := edCodigo.AsInteger;
  if (wEmpre.ppID > 0) then
  begin
    edCPFCNPJ.Text := wEmpre.ppDados.CPFNPJ;
    edEmail.Text   := wEmpre.ppDados.EMAIL;
    edSenha.Text   := wEmpre.ppDados.SENHA;
    edNome.Text    := wEmpre.ppDados.Nome;
    edApelido.Text := wEmpre.ppDados.Apelido;
    frame_End.Carregar(wEmpre.ppDados.Endereco);
    frame_Fon.Carregar(wEmpre.ppDados.Fone);
  end
  else
  begin
    edCodigo.Clear;
    edCPFCNPJ.Clear;
    edEmail.Clear;
    edSenha.Clear;
    edNome.Clear;
    edApelido.Clear;
    frame_End.Carregar(0);
    frame_Fon.Carregar(0);
  end;
end;

procedure TfcEmpresa.FormShow(Sender: TObject);
begin
  inherited;
  frame_End.pMostrarEmail(False);  
  edCodigo.AsInteger  := fDataM.Empresa;
  pnRegistro.Visible  := fCadastrar;
  lbAlteracao.Visible := (not fCadastrar);
  pnRegistro.Align    := alTop;
  lbAlteracao.Align   := alTop;
  if (not fCadastrar) then
    edCodigoExit(Sender)
  else
    fSetaFoco([edNome]);
end;

end.
 