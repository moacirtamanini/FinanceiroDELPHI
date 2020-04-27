unit ucBrwHistorico;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, Grids, DBGrids,
  pFIBDatabase, pFIBQuery, DB, DBClient, pFIBClientDataSet,
  Provider, FIBDataSet, pFIBDataSet, FIBDatabase;

type
  TfcBrwHistorico = class(TfcPadrao)
    DBGridGrade: TDBGrid;
    btnCarregar: TBitBtn;
    pFIBTrGrade: TpFIBTransaction;
    qrGrade: TpFIBDataSet;
    pFIBDSProvGrade: TpFIBDataSetProvider;
    pFIBCdsGrade: TpFIBClientDataSet;
    dsGrade: TDataSource;
    procedure btnSairClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGridGradeDblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    fCodigo: Integer;
    procedure  pAtualizaGrade;
  public
    property Codigo: Integer read fCodigo write fCodigo;
  end;

var
  fcBrwHistorico: TfcBrwHistorico;

implementation

uses uDataM;

{$R *.dfm}

procedure TfcBrwHistorico.btnSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  inherited;
end;

procedure TfcBrwHistorico.pAtualizaGrade;
begin
  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'SELECT * FROM HISTORICO '+
                               'WHERE EMPRE = :EMPRE AND STATUS = 1 '+
                               'order by CODIGO ');
  qrGrade.ParamByName('Empre').AsInteger := fDataM.Empresa;
  pFIBCdsGrade.Open;
end;

procedure TfcBrwHistorico.btnCarregarClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
  begin
    fCodigo             := pFIBCdsGrade.FieldByName('CODIGO').AsInteger;
    ModalResult := mrOk;
  end;
end;

procedure TfcBrwHistorico.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcBrwHistorico.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  btnCarregarClick(Sender);
end;

procedure TfcBrwHistorico.FormKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if (Key = #27) then Self.Close;
end;

end.
 