unit ucCadBandeira;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, Mask,
  Grids, DBGrids, DB, DBClient, pFIBClientDataSet, Provider,
  FIBDataSet, pFIBDataSet, FIBDatabase, pFIBDatabase, rtBandeira, rxToolEdit,
  rxCurrEdit;

type
  TfcCadBandeira = class(TfcPadrao)
    Label2: TLabel;
    edCodigo: TCurrencyEdit;
    Label9: TLabel;
    edDescricao: TEdit;
    pFIBTrGrade: TpFIBTransaction;
    qrGrade: TpFIBDataSet;
    pFIBDSProvGrade: TpFIBDataSetProvider;
    pFIBCdsGrade: TpFIBClientDataSet;
    dsGrade: TDataSource;
    DBGridGrade: TDBGrid;
    btnGravar: TBitBtn;
    btnExcluir: TBitBtn;
    btnLimpar: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure edCodigoExit(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pFIBCdsGradeAfterOpen(DataSet: TDataSet);
    procedure pFIBCdsGradeAfterScroll(DataSet: TDataSet);
    procedure DBGridGradeDblClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
  private
    wBandeira: TBandeira;
    procedure pLimpaTela;
    procedure pAtualizaGrade;
    procedure pAtualizaTela(ID: Integer);
  public
  end;

var
  fcCadBandeira: TfcCadBandeira;

implementation

{$R *.dfm}

uses
  uUtils, uDataM;

procedure TfcCadBandeira.pLimpaTela;
begin
  edCodigo.Clear;
  edDescricao.Clear;
end;

procedure TfcCadBandeira.pAtualizaTela(ID: Integer);
begin
  pLimpaTela;
  edCodigo.AsInteger := ID;
  edCodigoExit(nil);
end;

procedure TfcCadBandeira.pAtualizaGrade;
begin
  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'SELECT ID, DESCRICAO FROM BANDEIRA '+
                               'order by ID ');
  pFIBCdsGrade.Open;
end;

procedure TfcCadBandeira.FormCreate(Sender: TObject);
begin
  inherited;
  wBandeira := TBandeira.Create;
end;

procedure TfcCadBandeira.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fcCadBandeira := nil;
  wBandeira.Free;
  inherited;
end;

procedure TfcCadBandeira.edCodigoKeyPress(Sender: TObject; var Key: Char);
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

procedure TfcCadBandeira.edCodigoExit(Sender: TObject);
begin
  inherited;
  wBandeira.ppID := edCodigo.AsInteger;
  if wBandeira.ppID > 0 then
  begin
    edDescricao.Text := wBandeira.ppDados.Descricao;
  end
  else
  begin
    edDescricao.Text := '';
  end;
end;

procedure TfcCadBandeira.btnGravarClick(Sender: TObject);
var
  wDados: TDadosBan;
begin
  wDados.id          := edCodigo.AsInteger;
  wDados.Descricao   := edDescricao.Text;
  wBandeira.ppDados := wDados;
  wBandeira.fGravar;
  pAtualizaGrade;
  pLimpaTela;
  fSetaFoco([edCodigo]);
end;

procedure TfcCadBandeira.btnExcluirClick(Sender: TObject);
var
  wDados: TDadosBan;
  wErro: String;
begin
  if wBandeira.fPodeExcluir(wBandeira.ppDados.id, True, wErro) then
  begin
    if Confirmar('Confirma a exclusão da bandeira?') then
    begin
      wDados.id         := wBandeira.ppDados.id;
      wBandeira.ppDados := wDados;
      if (not wBandeira.fExcluir(wErro)) then
        MessageDlg(wErro, mtWarning, [mbOk], 0);
      pAtualizaGrade;
      fSetaFoco([edCodigo]);
    end;
  end;
end;

procedure TfcCadBandeira.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcCadBandeira.pFIBCdsGradeAfterOpen(DataSet: TDataSet);
begin
  inherited;
  pLimpaTela;
end;

procedure TfcCadBandeira.pFIBCdsGradeAfterScroll(DataSet: TDataSet);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
    pAtualizaTela(pFIBCdsGrade.FieldByName('Id').AsInteger)
  else
    pLimpaTela;
end;

procedure TfcCadBandeira.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
    pAtualizaTela(pFIBCdsGrade.FieldByName('Id').AsInteger);
  fSetaFoco([edCodigo]);
end;

procedure TfcCadBandeira.btnLimparClick(Sender: TObject);
begin
  inherited;
  pLimpaTela;
  fSetaFoco([edCodigo]);
end;

end.
 