unit ucCadCliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, uFrame_Cliente,
  uFrame_Endereco, uFrame_Fone, rtCliente, uFrame_Cartao, uFrame_Moeda;

type
  TfcCadCliente = class(TfcPadrao)
    Frame_Cliente: TFrame_Cliente;
    Label3: TLabel;
    edNome: TEdit;
    Label4: TLabel;
    edApelido: TEdit;
    frame_End: Tframe_Endereco;
    frame_Fon: Tframe_Fone;
    Label2: TLabel;
    edCPFCNPJ: TEdit;
    btnGravar: TBitBtn;
    btnExcluir: TBitBtn;
    btnLimpar: TBitBtn;
    Frame_Moeda: TFrame_Moeda;
    Frame_Cartao: TFrame_Cartao;
    procedure Frame_ClienteedCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure btnGravarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Frame_MoedacbMoedaChange(Sender: TObject);
  private
    wCliente: TCliente;
    procedure pLimpaTela;
    procedure pCarregaCliente(Sender: TObject; Encontrou: Boolean);
  public
  end;

var
  fcCadCliente: TfcCadCliente;

implementation

uses uDataM, uUtils;

{$R *.dfm}

procedure TfcCadCliente.FormCreate(Sender: TObject);
begin
  inherited;
  wCliente := TCliente.Create;
  Frame_Cliente.OnDepoisBusca := pCarregaCliente;
end;

procedure TfcCadCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fcCadCliente := nil;
  wCliente.Free;
  frame_End.Free;
  frame_Fon.Free;
  inherited;
end;

procedure TfcCadCliente.Frame_ClienteedCodigoKeyPress(Sender: TObject; var Key: Char);
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

procedure TfcCadCliente.btnGravarClick(Sender: TObject);

  function fConsisteDados: Boolean;
  begin
    Result := False;

    if (Length(Trim(edCPFCNPJ.Text)) > 0) then
    begin
      if (not ValidaCPFCNPJ(edCPFCNPJ.Text)) then
      begin
        MessageDlg('CPF/CNPJ não informado!', mtWarning, [mbOK], 0);
        Exit;
      end;
    end;

    if (Length(Trim(edNome.Text)) = 0) then
    begin
      MessageDlg('O nome do cliente não foi informado!', mtWarning, [mbOK], 0);
      Exit;
    end;

    if (Length(Trim(edApelido.Text)) > 0) then
    begin
      if (Length(Trim(edApelido.Text)) = Length(fSomenteNumeros(edApelido.Text))) then
      begin
        MessageDlg('O apelido do cliente não pode ser somente números!', mtWarning, [mbOK], 0);
        Exit;
      end;
    end;

    Result := True;
  end;

var
  wID: Integer;
  wDados: TDadosCli;
begin
  inherited;
  if (not fConsisteDados) then Exit;

  wCliente.Clear;
  wDados.id          := 0;
  wDados.Empre       := fDataM.Empresa;
  wDados.Codigo      := Frame_Cliente.edCodigo.AsInteger;
  wDados.CPFNPJ      := edCPFCNPJ.Text;
  wDados.Nome        := edNome.Text;
  wDados.Apelido     := edApelido.Text;
  wDados.Status      := 1;
  wDados.MoedaTIP    := Frame_Moeda.ppMoeda;
  wDados.CartaoCOD   := Frame_Cartao.Codigo;
  wDados.Endereco    := frame_End.fGravar;
  wDados.Fone        := frame_Fon.fGravar;
  wCliente.ppDados   := wDados;
  wID := wCliente.fGravar;
  if (wID > 0) then
    Frame_Cliente.Cliente := wID;
  fSetaFoco([Frame_Cliente.edCodigo]);
end;

procedure TfcCadCliente.btnExcluirClick(Sender: TObject);
var
  wErro: String;
begin
  inherited;
  if (wCliente.fPodeExcluir(Frame_Cliente.ppDadosCli.Codigo, True, wErro)) then
  begin
    if Confirmar('Confirma a exclusão do cliente?', clRed, 'Confirme') then
    begin
      wCliente.ppDados := Frame_Cliente.ppDadosCli;
      if (not wCliente.fExcluir(wErro)) then
        MessageDlg(wErro, mtWarning, [mbOk], 0)
      else
        Frame_Cliente.Cliente := 0;
    end;
  end;
end;

procedure TfcCadCliente.pLimpaTela;
begin
  Frame_Cliente.edCodigo.Clear;
  edCPFCNPJ.Clear;
  edNome.Clear;
  edApelido.Clear;
  Frame_Moeda.ppMoeda := 0;
  Frame_Cartao.Clear;
  frame_End.Limpar;
  frame_Fon.Limpar;
end;

procedure TfcCadCliente.pCarregaCliente(Sender: TObject; Encontrou: Boolean);
begin
  pLimpaTela;
  if Encontrou then
  begin
    Frame_Cliente.edCodigo.Text := IntToStr(Frame_Cliente.ppDadosCli.Codigo);
//    wCliente.ppBuscar := Frame_Cliente.edCodigo.Text;

    edCPFCNPJ.Text         := Frame_Cliente.ppDadosCli.CPFNPJ;
    edNome.Text            := Frame_Cliente.ppDadosCli.Nome;
    edApelido.Text         := Frame_Cliente.ppDadosCli.Apelido;
    Frame_Moeda.ppMoeda    := Frame_Cliente.ppDadosCli.MoedaTIP;
    Frame_MoedacbMoedaChange(Sender);
    Frame_Cartao.ppCodigo  := Frame_Cliente.ppDadosCli.CartaoCOD;
    frame_End.Carregar(Frame_Cliente.ppDadosCli.Endereco);
    frame_Fon.Carregar(Frame_Cliente.ppDadosCli.Fone);
    fSetaFoco([edCPFCNPJ]);
  end;
end;

procedure TfcCadCliente.btnLimparClick(Sender: TObject);
begin
  inherited;
  pLimpaTela;
  fSetaFoco([Frame_Cliente.edCodigo]);
end;

procedure TfcCadCliente.FormShow(Sender: TObject);
begin
  inherited;
  btnLimparClick(Sender);
end;

procedure TfcCadCliente.Frame_MoedacbMoedaChange(Sender: TObject);
begin
  inherited;
  Frame_Cartao.Enabled := (Frame_Moeda.ppMoeda = 3) or (Frame_Moeda.ppMoeda = 4);
  if (Frame_Moeda.ppMoeda <> Frame_Cliente.ppDadosCli.MoedaTIP) then
    Frame_Cartao.Clear;
  Frame_Cartao.pRepaint;    
end;

end.
