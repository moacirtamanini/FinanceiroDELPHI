unit ucBrwCategoria;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, DB, DBClient, pFIBClientDataSet, Provider, FIBDataSet,
  pFIBDataSet, FIBDatabase, pFIBDatabase, Grids, DBGrids, StdCtrls,
  Buttons, ExtCtrls, Mask, rxToolEdit;

type
  TfcBrwCategoria = class(TfcPadrao)
    DBGridGrade: TDBGrid;
    pFIBTrGrade: TpFIBTransaction;
    qrGrade: TpFIBDataSet;
    pFIBDSProvGrade: TpFIBDataSetProvider;
    pFIBCdsGrade: TpFIBClientDataSet;
    dsGrade: TDataSource;
    btnCarregar: TBitBtn;
    procedure btnSairClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGridGradeDblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    fCodigo: Integer;
    F_FiltroClassi: String;
    procedure  pAtualizaGrade;
  public
    constructor Create(AOwner: TComponent; prFiltroClassi: String); overload;
    property Codigo: Integer read fCodigo write fCodigo;
  end;

var
  fcBrwCategoria: TfcBrwCategoria;

implementation

uses uDataM;

{$R *.dfm}

constructor TfcBrwCategoria.Create(AOwner: TComponent; prFiltroClassi: String);
begin
  Inherited Create(AOwner);
  F_FiltroClassi := '';
  if (prFiltroClassi <> '') then
    F_FiltroClassi := ' '+prFiltroClassi+' ';
end;

procedure TfcBrwCategoria.btnSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  inherited;
end;

procedure TfcBrwCategoria.pAtualizaGrade;
begin
  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'SELECT CODIGO, CLASSIFICACAO, DESCRICAO, APELIDO, CONTATIP, STATUS, lpad('''',char_length(Classificacao) -1, '' '') || DESCRICAO AS DESCRICAO_, '+
                               'CASE STATUS WHEN 1 THEN ''Sim'' else ''Não'' end as Sta '+
                               'FROM CATEGORIA '+
                               'WHERE Empre = :Empre '+
                               F_FiltroClassi +
                               'order by Classificacao, Codigo, Id ');
  qrGrade.ParamByName('Empre').AsInteger := fDataM.Empresa;
  pFIBCdsGrade.Open;
end;

procedure TfcBrwCategoria.btnCarregarClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
  begin
    fCodigo := pFIBCdsGrade.FieldByName('CODIGO').AsInteger;
    ModalResult := mrOk;
  end;
end;

procedure TfcBrwCategoria.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcBrwCategoria.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  btnCarregarClick(Sender);
end;

procedure TfcBrwCategoria.FormKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if (Key = #27) then Self.Close;
end;

end.
 