unit ucCadCartaoDebCre;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, Mask,
  Grids, DBGrids, DB, DBClient, pFIBClientDataSet, Provider,
  FIBDataSet, pFIBDataSet, FIBDatabase, pFIBDatabase,
  rtCartao, uFrame_Bandeira, uFrame_Categoria, rxToolEdit, rxCurrEdit;

type
   TfcCadCartaoDebCre = class(TfcPadrao)
    Label2: TLabel;
    edCodigo: TCurrencyEdit;
    Label9: TLabel;
    edDescricao: TEdit;
    btnGravar: TBitBtn;
    btnExcluir: TBitBtn;
    Label1: TLabel;
    edNome: TEdit;
    Label3: TLabel;
    edNroIni: TEdit;
    edNroFim: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    edSenhaCompra: TEdit;
    Label6: TLabel;
    edSiteBanco: TEdit;
    Label7: TLabel;
    edSenhaSite: TEdit;
    edDataValidade: TDateEdit;
    Label8: TLabel;
    edDiaFechto: TCurrencyEdit;
    Label10: TLabel;
    Label11: TLabel;
    edDiaVencto: TCurrencyEdit;
    pFIBTrGrade: TpFIBTransaction;
    qrGrade: TpFIBDataSet;
    pFIBDSProvGrade: TpFIBDataSetProvider;
    pFIBCdsGrade: TpFIBClientDataSet;
    dsGrade: TDataSource;
    DBGridGrade: TDBGrid;
    frame_Bandeira: Tframe_Bandeira;
    frame_CategoriaDeb: Tframe_Categoria;
    btnLimpar: TBitBtn;
    frame_CategoriaCre: Tframe_Categoria;
    rgTpDebCre: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure edCodigoExit(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGridGradeDblClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure rgTpDebCreClick(Sender: TObject);
  private
    wCartao: TCartao;
    procedure pLimpaTela(LimparCodigo: Boolean);
    procedure pAtualizaGrade;
    procedure pAtualizaTela(Codigo: Integer);
  public
  end;

var
  fcCadCartaoDebCre: TfcCadCartaoDebCre;

implementation

{$R *.dfm}

uses
  uUtils, uDataM, rtTypes;

procedure TfcCadCartaoDebCre.pLimpaTela(LimparCodigo: Boolean);
begin
  if (LimparCodigo) then edCodigo.Clear;
  edDescricao.Clear;
  rgTpDebCre.ItemIndex := 2;
  edNroIni.Clear;
  edNroFim.Clear;
  edNome.Clear;
  edSenhaCompra.Clear;
  edSiteBanco.Clear;
  edSenhaSite.Clear;
  edDataValidade.Clear;
  edDiaFechto.Clear;
  edDiaVencto.Clear;
  frame_Bandeira.Clear;
  frame_CategoriaDeb.Clear;
  frame_CategoriaCre.Clear;
end;

procedure TfcCadCartaoDebCre.pAtualizaTela(Codigo: Integer);
begin
  pLimpaTela(True);
  edCodigo.AsInteger := Codigo;
  edCodigoExit(nil);
end;

procedure TfcCadCartaoDebCre.pAtualizaGrade;
begin
  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'SELECT * FROM CARTAODEBCRE '+
                               'WHERE Empre = :Empre '+
                               'order by CODIGO ');
  qrGrade.ParamByName('Empre').AsInteger := fDataM.Empresa;
  pFIBCdsGrade.Open;
end;

procedure TfcCadCartaoDebCre.FormCreate(Sender: TObject);
begin
  inherited;
  wCartao := TCartao.Create;
  frame_CategoriaDeb.FiltroClassi := 'AND (Classificacao Like ''2.1.1.02%'')';
end;

procedure TfcCadCartaoDebCre.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fcCadCartaoDebCre := nil;
  wCartao.Free;
  inherited;
end;

procedure TfcCadCartaoDebCre.edCodigoKeyPress(Sender: TObject; var Key: Char);
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

  if (Sender is TEdit) and ((Sender = edNroIni) or (Sender = edNroFim)) then
    if not (Key in ['0'..'9', #8]) then
      Key := #0;
end;

procedure TfcCadCartaoDebCre.edCodigoExit(Sender: TObject);
begin
  inherited;
  wCartao.ppCodigo := edCodigo.AsInteger;
  if wCartao.ppCodigo > 0 then
  begin
    edCodigo.AsInteger         := wCartao.ppCodigo;
    edDescricao.Text           := wCartao.ppDados.Descricao;
    rgTpDebCre.ItemIndex       := wCartao.ppDados.tpDebCre;
    frame_Bandeira.ppCodigo    := wCartao.ppDados.Bandeira;
    edNome.Text                := wCartao.ppDados.Nome;
    edNroIni.Text              := wCartao.ppDados.NroIni;
    edNroFim.Text              := wCartao.ppDados.NroFim;
    edSenhaCompra.Text         := wCartao.ppDados.SenhaComp;
    edSiteBanco.Text           := wCartao.ppDados.SiteBanco;
    edSenhaSite.Text           := wCartao.ppDados.SenhaSite;
    edDataValidade.Date        := wCartao.ppDados.Validade;
    edDiaFechto.AsInteger      := wCartao.ppDados.DiaFatFec;
    edDiaVencto.AsInteger      := wCartao.ppDados.DiaFatVen;
    frame_CategoriaDeb.Codigo  := wCartao.ppDados.CategoriaDeb;
    frame_CategoriaCre.Codigo  := wCartao.ppDados.CategoriaCre;
  end
  else
  begin
    pLimpaTela(False);
  end;
end;

procedure TfcCadCartaoDebCre.btnGravarClick(Sender: TObject);
var
  wDados: TDadosCartao;
  wID: Integer;
begin
  if fDataM.Empresa < 1 then
  begin
    MessageDlg('A empresa deve ser maior que zero!', mtWarning, [mbOk], 0);
    fSetaFoco([edCodigo]);
    Exit;
  end;

  if Length(Trim(edDescricao.Text)) = 0 then
  begin
    MessageDlg('A descrição do cartão não foi informada!', mtWarning, [mbOk], 0);
    fSetaFoco([edDescricao]);
    Exit;
  end;

  if Length(Trim(edNome.Text)) = 0 then
  begin
    MessageDlg('O nome impresso no cartão não foi informado!', mtWarning, [mbOk], 0);
    fSetaFoco([edNome]);
    Exit;
  end;

  if StrToIntDef(Trim(edNroIni.Text),0) = 0 then
  begin
    MessageDlg('Os números iniciais do cartão não foram informados!', mtWarning, [mbOk], 0);
    fSetaFoco([edNroIni]);
    Exit;
  end;

  if StrToIntDef(Trim(edNroFim.Text),0) = 0 then
  begin
    MessageDlg('Os números finais do cartão não foram informados!', mtWarning, [mbOk], 0);
    fSetaFoco([edNroFim]);
    Exit;
  end;

  if rgTpDebCre.ItemIndex < 0 then
  begin
    MessageDlg('O Tipo do cartão não foi informado!', mtWarning, [mbOk], 0);
    fSetaFoco([rgTpDebCre]);
    Exit;
  end;

  if (edDataValidade.Date < cDataMinima) then
  begin
    MessageDlg('A data de validade do cartão não foi informada!', mtWarning, [mbOk], 0);
    fSetaFoco([edDataValidade]);
    Exit;
  end;

  if (edDataValidade.Date > cDataMaxima) then
  begin
    MessageDlg('A data de validade do cartão é muito distante!', mtWarning, [mbOk], 0);
    fSetaFoco([edDataValidade]);
    Exit;
  end;

  if (rgTpDebCre.ItemIndex > 0) then
  begin
    if (edDiaFechto.AsInteger < 1) or (edDiaFechto.AsInteger > 28) then
    begin
      MessageDlg('O dia de fechamento da fatura deve estar entre 01 a 28', mtWarning, [mbOk], 0);
      fSetaFoco([edDiaFechto]);
      Exit;
    end;

    if (edDiaVencto.AsInteger < 1) or (edDiaVencto.AsInteger > 28) then
    begin
      MessageDlg('O dia de vencimento da fatura deve estar entre 01 a 28', mtWarning, [mbOk], 0);
      fSetaFoco([edDiaVencto]);
      Exit;
    end;
  end
  else
  begin
    edDiaFechto.Clear;
    edDiaVencto.Clear;
  end;

  if (frame_Bandeira.ppCodigo < 1) then
  begin
    MessageDlg('A bandeira do cartão não foi informada', mtWarning, [mbOk], 0);
    fSetaFoco([frame_Bandeira.cbBandeira]);
    Exit;
  end;

  if (frame_CategoriaDeb.Codigo < 1) then
  begin
    MessageDlg('A categoria padrão para Débito do cartão não foi informada', mtWarning, [mbOk], 0);
    fSetaFoco([frame_CategoriaDeb.edCodigo]);
    Exit;
  end;

  if (frame_CategoriaCre.Codigo < 1) then
  begin
    MessageDlg('A categoria padrão para Crédito do cartão não foi informada', mtWarning, [mbOk], 0);
    fSetaFoco([frame_CategoriaCre.edCodigo]);
    Exit;
  end;

  wDados.id           := 0;
  wDados.Codigo       := edCodigo.AsInteger;
  wDados.tpDebCre     := rgTpDebCre.ItemIndex;
  wDados.Bandeira     := frame_Bandeira.ppCodigo;
  wDados.Descricao    := edDescricao.Text;
  wDados.Nome         := edNome.Text;
  wDados.NroIni       := edNroIni.Text;
  wDados.NroFim       := edNroFim.Text;
  wDados.SenhaComp    := edSenhaCompra.Text;
  wDados.SiteBanco    := edSiteBanco.Text;
  wDados.SenhaSite    := edSenhaSite.Text;
  wDados.Validade     := edDataValidade.Date;
  wDados.DiaFatFec    := edDiaFechto.AsInteger;
  wDados.DiaFatVen    := edDiaVencto.AsInteger;
  wDados.CategoriaDeb := frame_CategoriaDeb.Codigo;
  wDados.CategoriaCre := frame_CategoriaCre.Codigo;
  wDados.Status       := 1;
  wCartao.ppDados     := wDados;
  wID := wCartao.fGravar;
  fSetaFoco([edDescricao]);
  if (wID > 0) then
  begin
    pAtualizaGrade;
    pLimpaTela(True);
    fSetaFoco([edCodigo]);
  end;
end;

procedure TfcCadCartaoDebCre.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcCadCartaoDebCre.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
    pAtualizaTela(pFIBCdsGrade.FieldByName('Codigo').AsInteger);
  fSetaFoco([edCodigo]);
end;

procedure TfcCadCartaoDebCre.btnExcluirClick(Sender: TObject);
var
  wDados: TDadosCartao;
  wErro: String;
begin
  if Confirmar('Confirma a exclusão do cartão de débito?') then
  begin
    wDados.id          := wCartao.ppDados.id;
    wDados.Empre       := fDataM.Empresa;
    wDados.Codigo      := edCodigo.AsInteger;
    wCartao.ppDados := wDados;
    if (not wCartao.fExcluir(wErro)) then
      MessageDlg(wErro, mtWarning, [mbOk], 0);
    pAtualizaGrade;
    fSetaFoco([edCodigo]);
  end;
end;

procedure TfcCadCartaoDebCre.btnLimparClick(Sender: TObject);
begin
  inherited;
  pLimpaTela(True);
  fSetaFoco([edCodigo]);
end;

procedure TfcCadCartaoDebCre.rgTpDebCreClick(Sender: TObject);
begin
  inherited;
  edDiaFechto.Enabled := rgTpDebCre.ItemIndex > 0;
  edDiaVencto.Enabled := rgTpDebCre.ItemIndex > 0;
end;

end.
 