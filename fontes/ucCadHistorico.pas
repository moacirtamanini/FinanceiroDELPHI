unit ucCadHistorico;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, Grids, DBGrids, StdCtrls, Mask, Buttons, ExtCtrls, rtHistorico, DB, DBClient,
  pFIBClientDataSet, Provider, FIBDataSet, pFIBDataSet, FIBDatabase,
  pFIBDatabase, rxToolEdit, rxCurrEdit;

type
  TfcCadHistorico = class(TfcPadrao)
    Label2: TLabel;
    edCodigo: TCurrencyEdit;
    Label9: TLabel;
    edDescricao: TEdit;
    DBGridGrade: TDBGrid;
    btnGravar: TBitBtn;
    btnExcluir: TBitBtn;
    pFIBTrGrade: TpFIBTransaction;
    qrGrade: TpFIBDataSet;
    pFIBDSProvGrade: TpFIBDataSetProvider;
    pFIBCdsGrade: TpFIBClientDataSet;
    dsGrade: TDataSource;
    BitDesativar: TBitBtn;
    btnLimpar: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure edCodigoExit(Sender: TObject);
    procedure edCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure btnGravarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGridGradeDblClick(Sender: TObject);
    procedure pFIBCdsGradeAfterOpen(DataSet: TDataSet);
    procedure pFIBCdsGradeAfterScroll(DataSet: TDataSet);
    procedure BitDesativarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
  private
    wHistorico: THistorico;
    procedure pLimpaTela;
    procedure pAtualizaGrade;
    procedure pAtualizaTela(iCodigo: Integer);
  public
  end;

var
  fcCadHistorico: TfcCadHistorico;

implementation

uses
  uUtils, uDataM;

{$R *.dfm}

procedure TfcCadHistorico.FormCreate(Sender: TObject);
begin
  inherited;
  wHistorico := THistorico.Create;
end;

procedure TfcCadHistorico.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fcCadHistorico := nil;
  wHistorico.Free;
  inherited;
end;

procedure TfcCadHistorico.edCodigoExit(Sender: TObject);
begin
  inherited;
  wHistorico.ppCodigo := edCodigo.AsInteger;
  if wHistorico.ppCodigo > 0 then
  begin
    edDescricao.Text := wHistorico.ppDados.Descricao;
  end
  else
  begin
    edDescricao.Text := '';
  end;
end;

procedure TfcCadHistorico.edCodigoKeyPress(Sender: TObject; var Key: Char);
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

procedure TfcCadHistorico.btnGravarClick(Sender: TObject);
var
  wDados: TDadosHis;
begin
  wDados.id          := wHistorico.ppDados.id;
  wDados.Empre       := wHistorico.ppDados.Empre;
  wDados.Codigo      := edCodigo.AsInteger;
  wDados.Descricao   := edDescricao.Text;
  wDados.Status      := 1; // Ativo
  wHistorico.ppDados := wDados;
  wHistorico.fGravar;
  pAtualizaGrade;
  pLimpaTela;
  fSetaFoco([edCodigo]);
end;

procedure TfcCadHistorico.BitDesativarClick(Sender: TObject);
var
  wDados: TDadosHis;
  wErro: String;
begin
  if wHistorico.ppDados.id > 0 then
  begin
    if Confirmar('Confirma a desativação do histórico?') then
    begin
      wDados.id          := wHistorico.ppDados.id;
      wDados.Empre       := wHistorico.ppDados.Empre;
      wDados.Codigo      := edCodigo.AsInteger;
      wHistorico.ppDados := wDados;
      if (not wHistorico.fDesativar(wErro)) then
        MessageDlg(wErro, mtWarning, [mbOk], 0);
      pAtualizaGrade;
      fSetaFoco([edCodigo]);
    end;
  end;
end;

procedure TfcCadHistorico.btnExcluirClick(Sender: TObject);
var
  wDados: TDadosHis;
  wErro: String;
begin
  if wHistorico.ppDados.id > 0 then
  begin
    if Confirmar('Confirma a exclusão do histórico?') then
    begin
      wDados.id          := wHistorico.ppDados.id;
      wDados.Empre       := wHistorico.ppDados.Empre;
      wDados.Codigo      := edCodigo.AsInteger;
      wHistorico.ppDados := wDados;
      if (not wHistorico.fExcluir(wErro)) then
        MessageDlg(wErro, mtWarning, [mbOk], 0);
      pAtualizaGrade;
      fSetaFoco([edCodigo]);
    end;
  end;
end;

procedure TfcCadHistorico.pAtualizaGrade;
begin
  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'SELECT CODIGO, DESCRICAO, STATUS, CASE STATUS WHEN 1 THEN ''Sim'' else ''Não'' end as Sta FROM HISTORICO WHERE Empre = :Empre '+
                               'order by Codigo ');
  qrGrade.ParamByName('Empre').AsInteger := fDataM.Empresa;
  pFIBCdsGrade.Open;
end;

procedure TfcCadHistorico.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcCadHistorico.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
    pAtualizaTela(pFIBCdsGrade.FieldByName('Codigo').AsInteger);
  fSetaFoco([edCodigo]);
end;

procedure TfcCadHistorico.pAtualizaTela(iCodigo: Integer);
begin
  pLimpaTela;
  edCodigo.AsInteger := iCodigo;
  edCodigoExit(nil);
end;

procedure TfcCadHistorico.pLimpaTela;
begin
  edCodigo.Clear;
  edDescricao.Clear;
end;

procedure TfcCadHistorico.pFIBCdsGradeAfterOpen(DataSet: TDataSet);
begin
  inherited;
  pLimpaTela;
end;

procedure TfcCadHistorico.pFIBCdsGradeAfterScroll(DataSet: TDataSet);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
    pAtualizaTela(pFIBCdsGrade.FieldByName('Codigo').AsInteger)
  else
    pLimpaTela;
end;

procedure TfcCadHistorico.btnLimparClick(Sender: TObject);
begin
  inherited;
  pLimpaTela;
  fSetaFoco([edCodigo]);
end;

end.
