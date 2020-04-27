unit ucCadCategoria;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, Mask, rtTypes,
  DB, DBClient, pFIBClientDataSet, Provider, FIBDataSet,
  pFIBDataSet, FIBDatabase, pFIBDatabase, Grids, DBGrids, rtCategoria,
  rxToolEdit, rxCurrEdit;

type
  TfcCadCategoria = class(TfcPadrao)
    btnGravar: TBitBtn;
    BitDesativar: TBitBtn;
    btnExcluir: TBitBtn;
    DBGridGrade: TDBGrid;
    pFIBTrGrade: TpFIBTransaction;
    qrGrade: TpFIBDataSet;
    pFIBDSProvGrade: TpFIBDataSetProvider;
    pFIBCdsGrade: TpFIBClientDataSet;
    dsGrade: TDataSource;
    Label2: TLabel;
    edCodigo: TCurrencyEdit;
    Label9: TLabel;
    edDescricao: TEdit;
    edClassificacao: TMaskEdit;
    Label1: TLabel;
    Label3: TLabel;
    edApelido: TEdit;
    btnLimpar: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edCodigoExit(Sender: TObject);
    procedure edCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure btnGravarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGridGradeDblClick(Sender: TObject);
    procedure pFIBCdsGradeAfterOpen(DataSet: TDataSet);
    procedure pFIBCdsGradeAfterScroll(DataSet: TDataSet);
    procedure edClassificacaoExit(Sender: TObject);
    procedure BitDesativarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure DBGridGradeDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnLimparClick(Sender: TObject);
  private
   wCategoria: TCategoria;
   procedure pAtualizaGrade;
   procedure pLimpaTela;
   procedure pAtualizaTela(iCodigo: Integer);
  public
  end;

var
  fcCadCategoria: TfcCadCategoria;

implementation

uses uDataM, uUtils;

{$R *.dfm}

procedure TfcCadCategoria.FormCreate(Sender: TObject);
begin
  inherited;
  wCategoria := TCategoria.Create;
end;

procedure TfcCadCategoria.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fcCadCategoria := nil;
  wCategoria.Free;
  inherited;
end;

procedure TfcCadCategoria.edCodigoExit(Sender: TObject);
begin
  inherited;
  wCategoria.ppCodigo := edCodigo.AsInteger;
  if wCategoria.ppCodigo > 0 then
  begin
    edClassificacao.Text := wCategoria.ppDados.Classificacao;
    edDescricao.Text     := wCategoria.ppDados.Descricao;
    edApelido.Text       := wCategoria.ppDados.Apelido;
  end
  else
  begin
    edClassificacao.Clear;
    edDescricao.Clear;
    edApelido.Clear;
  end;
end;

procedure TfcCadCategoria.edClassificacaoExit(Sender: TObject);
begin
  inherited;
  wCategoria.ppClassi := edClassificacao.Text;
  if wCategoria.ppCodigo > 0 then
  begin
    edCodigo.AsInteger   := wCategoria.ppDados.Codigo;
    edClassificacao.Text := wCategoria.ppDados.Classificacao;
    edDescricao.Text     := wCategoria.ppDados.Descricao;
    edApelido.Text       := wCategoria.ppDados.Apelido;
  end;
end;

procedure TfcCadCategoria.edCodigoKeyPress(Sender: TObject; var Key: Char);
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

procedure TfcCadCategoria.pAtualizaGrade;
begin
  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'SELECT ID, CODIGO, CLASSIFICACAO, DESCRICAO, APELIDO, CONTATIP, STATUS, lpad('''',char_length(Classificacao) -1, '' '') || DESCRICAO AS DESCRICAO_, '+
                               'CASE STATUS WHEN 1 THEN ''Sim'' else ''Não'' end as Sta FROM CATEGORIA WHERE Empre = :Empre '+
                               'order by Classificacao, Codigo, Id ');
  qrGrade.ParamByName('Empre').AsInteger := fDataM.Empresa;
  pFIBCdsGrade.Open;
end;

procedure TfcCadCategoria.pLimpaTela;
begin
  edCodigo.Clear;
  edClassificacao.Clear;
  edDescricao.Clear;
  edApelido.Clear;
end;

procedure TfcCadCategoria.pAtualizaTela(iCodigo: Integer);
begin
  pLimpaTela;
  edCodigo.AsInteger := iCodigo;
  edCodigoExit(nil);
end;

procedure TfcCadCategoria.btnGravarClick(Sender: TObject);
var
  wDados: TDadosCat;
  wID: Integer;
  wCla: String;
begin
  wDados.id            := wCategoria.ppDados.id;
  wDados.Empre         := fDataM.Empresa;
  wDados.Codigo        := edCodigo.AsInteger;
  wDados.Classificacao := edClassificacao.Text;
  wDados.Descricao     := edDescricao.Text;
  wDados.Apelido       := edApelido.Text;
  wDados.ContaTIP      := 0;
  wDados.Status        := 1; // Ativo
  wCla                 := edClassificacao.Text;

  wCategoria.ppDados := wDados;
  wID := wCategoria.fGravar;
  if (wID > 0) then
  begin
    pAtualizaGrade;
    pLimpaTela;
    pFIBCdsGrade.IndexFieldNames := 'CLASSIFICACAO';
    pFIBCdsGrade.FindNearest([wCla]);
    fSetaFoco([edCodigo]);
  end
  else
  begin
    fSetaFoco([edDescricao]);
  end;
end;

procedure TfcCadCategoria.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcCadCategoria.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
    pAtualizaTela(pFIBCdsGrade.FieldByName('Codigo').AsInteger);
  fSetaFoco([edCodigo]);
end;

procedure TfcCadCategoria.pFIBCdsGradeAfterOpen(DataSet: TDataSet);
begin
  inherited;
  pLimpaTela;
end;

procedure TfcCadCategoria.pFIBCdsGradeAfterScroll(DataSet: TDataSet);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
    pAtualizaTela(pFIBCdsGrade.FieldByName('Codigo').AsInteger)
  else
    pLimpaTela;
end;

procedure TfcCadCategoria.BitDesativarClick(Sender: TObject);
var
  wDados: TDadosCat;
  wErro: String;
begin
  if Confirmar('Confirma a desativação da categoria?') then
  begin
    wDados.id          := wCategoria.ppDados.id;
    wDados.Empre       := fDataM.Empresa;
    wDados.Codigo      := edCodigo.AsInteger;
    wCategoria.ppDados := wDados;
    if (not wCategoria.fSetStatus(0, wErro)) then
      MessageDlg(wErro, mtWarning, [mbOk], 0);
    pAtualizaGrade;
    fSetaFoco([edCodigo]);
  end;
end;

procedure TfcCadCategoria.btnExcluirClick(Sender: TObject);
begin
  if wCategoria.fPodeExcluir then
  begin
    if Confirmar('Confirma a exclusão da categoria?') then
    begin
      wCategoria.fExcluir;
      pAtualizaGrade;
      fSetaFoco([edCodigo]);
    end;
  end;
end;

procedure TfcCadCategoria.DBGridGradeDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  inherited;
  if (gdSelected in State) then
  begin
    if DBGridGrade.DataSource.DataSet.FieldByName('ContaTIP').AsInteger = 1 then
    begin
      DBGridGrade.Canvas.Font.Color  := CorGradeFonteRealceSele;
      DBGridGrade.Canvas.Brush.Color := CorGradeFundoRealceSele;
    end
    else
    begin
      DBGridGrade.Canvas.Font.Color  := CorGradeFonteNormalSele;
      DBGridGrade.Canvas.Brush.Color := CorGradeFundoNormalSele;
    end;
  end
  else
  begin
    if DBGridGrade.DataSource.DataSet.FieldByName('ContaTIP').AsInteger = 1 then
    begin
      DBGridGrade.Canvas.Font.Color  := CorGradeFonteRealce;
      DBGridGrade.Canvas.Brush.Color := CorGradeFundoRealce;
    end
    else
    begin
      DBGridGrade.Canvas.Font.Color  := CorGradeFonteNormal;
      DBGridGrade.Canvas.Brush.Color := CorGradeFundoNormal;
    end;
  end;
  //
  DBGridGrade.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfcCadCategoria.btnLimparClick(Sender: TObject);
begin
  inherited;
  pLimpaTela;
  fSetaFoco([edCodigo]);
end;

end.
