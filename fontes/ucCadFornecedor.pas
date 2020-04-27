unit ucCadFornecedor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, uFrame_Fornecedor,
  uFrame_Fone, uFrame_Endereco, rtFornecedor, rtCartao, uFrame_Cartao, uFrame_Moeda;

type
  TfcCadFornecedor = class(TfcPadrao)
    Frame_Fornecedor: TFrame_Fornecedor;
    Label2: TLabel;
    edCPFCNPJ: TEdit;
    Label3: TLabel;
    edNome: TEdit;
    Label4: TLabel;
    edApelido: TEdit;
    frame_End: Tframe_Endereco;
    frame_Fon: Tframe_Fone;
    btnGravar: TBitBtn;
    btnLimpar: TBitBtn;
    btnExcluir: TBitBtn;
    Frame_Moeda: TFrame_Moeda;
    Frame_Cartao: TFrame_Cartao;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Frame_FornecedoredCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure btnGravarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Frame_MoedacbMoedaChange(Sender: TObject);
  private
    wFornecedor: TFornecedor;
    procedure pLimpaTela;
    procedure pCarregaFornecedor(Sender: TObject; Encontrou: Boolean);
  public
  end;

var
  fcCadFornecedor: TfcCadFornecedor;

implementation

uses uDataM, uUtils;

{$R *.dfm}

procedure TfcCadFornecedor.FormCreate(Sender: TObject);
begin
  inherited;
  wFornecedor := TFornecedor.Create;
  Frame_Fornecedor.OnDepoisBusca := pCarregaFornecedor;
end;

procedure TfcCadFornecedor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fcCadFornecedor := nil;
  wFornecedor.Free;
  frame_End.Free;
  frame_Fon.Free;
  inherited;
end;

procedure TfcCadFornecedor.Frame_FornecedoredCodigoKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
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

procedure TfcCadFornecedor.btnGravarClick(Sender: TObject);

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
      MessageDlg('O nome do fornecedor não foi informado!', mtWarning, [mbOK], 0);
      Exit;
    end;

    if (Length(Trim(edApelido.Text)) > 0) then
    begin
      if (Length(Trim(edApelido.Text)) = Length(fSomenteNumeros(edApelido.Text))) then
      begin
        MessageDlg('O apelido do fornecedor não pode ser somente números!', mtWarning, [mbOK], 0);
        Exit;
      end;
    end;

    Result := True;
  end;

var
  wID: Integer;
  wDados: TDadosFor;
begin
  inherited;
  if (not fConsisteDados) then Exit;

  wFornecedor.Clear;
  wDados.id          := 0;
  wDados.Empre       := fDataM.Empresa;
  wDados.Codigo      := Frame_Fornecedor.edCodigo.AsInteger;
  wDados.CPFNPJ      := edCPFCNPJ.Text;
  wDados.Nome        := edNome.Text;
  wDados.Apelido     := edApelido.Text;
  wDados.Status      := 1;
  wDados.MoedaTIP    := Frame_Moeda.ppMoeda;
  wDados.CartaoCOD   := Frame_Cartao.Codigo;
  wDados.Endereco    := frame_End.fGravar;
  wDados.Fone        := frame_Fon.fGravar;
  wFornecedor.ppDados := wDados;
  wID := wFornecedor.fGravar;
  if (wID > 0) then
    Frame_Fornecedor.Fornecedor := wID;
//  pLimpaTela;
  fSetaFoco([Frame_Fornecedor.edCodigo]);
end;

procedure TfcCadFornecedor.btnExcluirClick(Sender: TObject);
var
  wErro: String;
begin
  inherited;
  if (wFornecedor.fPodeExcluir(Frame_Fornecedor.ppDadosFor.Codigo, True, wErro)) then
  begin
    if Confirmar('Confirma a exclusão do fornecedor?', clRed, 'Confirme') then
    begin
      wFornecedor.ppDados := Frame_Fornecedor.ppDadosFor;
      if (not wFornecedor.fExcluir(wErro)) then
        MessageDlg(wErro, mtWarning, [mbOk], 0)
      else
        Frame_Fornecedor.Fornecedor := 0;
    end;
  end;
end;

procedure TfcCadFornecedor.pLimpaTela;
begin
  Frame_Fornecedor.edCodigo.Clear;
  edCPFCNPJ.Clear;
  edNome.Clear;
  edApelido.Clear;
  Frame_Moeda.ppMoeda := 0;
  Frame_Cartao.Clear;
  frame_End.Limpar;
  frame_Fon.Limpar;
end;

procedure TfcCadFornecedor.btnLimparClick(Sender: TObject);
begin
  inherited;
  pLimpaTela;
  fSetaFoco([Frame_Fornecedor.edCodigo]);
end;

procedure TfcCadFornecedor.pCarregaFornecedor(Sender: TObject; Encontrou: Boolean);
begin
  pLimpaTela;
  if Encontrou then
  begin
    Frame_Fornecedor.edCodigo.Text := IntToStr(Frame_Fornecedor.ppDadosFor.Codigo);
    edCPFCNPJ.Text         := Frame_Fornecedor.ppDadosFor.CPFNPJ;
    edNome.Text            := Frame_Fornecedor.ppDadosFor.Nome;
    edApelido.Text         := Frame_Fornecedor.ppDadosFor.Apelido;
    Frame_Moeda.ppMoeda    := Frame_Fornecedor.ppDadosFor.MoedaTIP;
    Frame_MoedacbMoedaChange(Sender);
    Frame_Cartao.ppCodigo  := Frame_Fornecedor.ppDadosFor.CartaoCOD;
    frame_End.Carregar(Frame_Fornecedor.ppDadosFor.Endereco);
    frame_Fon.Carregar(Frame_Fornecedor.ppDadosFor.Fone);
  end;
end;

procedure TfcCadFornecedor.FormShow(Sender: TObject);
begin
  inherited;
  btnLimparClick(Sender);
end;

procedure TfcCadFornecedor.Frame_MoedacbMoedaChange(Sender: TObject);
begin
  inherited;
  Frame_Cartao.Enabled := (Frame_Moeda.ppMoeda = 3) or (Frame_Moeda.ppMoeda = 4);

  Frame_Cartao.Clear;
  Frame_Cartao.Invalidate;
end;

end.
