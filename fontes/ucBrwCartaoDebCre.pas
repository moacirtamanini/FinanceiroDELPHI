unit ucBrwCartaoDebCre;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, DB, DBClient,
  pFIBClientDataSet, Provider, FIBDataSet, pFIBDataSet, FIBDatabase,
  pFIBDatabase, Grids, DBGrids;

type
  TfcBrwCartaoDebCre = class(TfcPadrao)
    btnCarregar: TBitBtn;
    DBGridGrade: TDBGrid;
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
    procedure pAtualizaGrade;
  public
    property Codigo: Integer read fCodigo write fCodigo;
  end;

var
  fcBrwCartaoDebCre: TfcBrwCartaoDebCre;

implementation

uses uDataM;

{$R *.dfm}

procedure TfcBrwCartaoDebCre.btnSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  inherited;
end;

procedure TfcBrwCartaoDebCre.pAtualizaGrade;
begin
  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'SELECT id, Codigo, Descricao, Nome, NroIni, NroFim FROM CARTAODEBCRE '+
                               'WHERE EMPRE = :EMPRE AND STATUS = 1 '+
                               'order by CODIGO ');
  qrGrade.ParamByName('Empre').AsInteger := fDataM.Empresa;
  pFIBCdsGrade.Open;
end;

procedure TfcBrwCartaoDebCre.btnCarregarClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
  begin
    fCodigo     := pFIBCdsGrade.FieldByName('CODIGO').AsInteger;
    ModalResult := mrOk;
  end;
end;

procedure TfcBrwCartaoDebCre.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcBrwCartaoDebCre.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  btnCarregarClick(Sender);
end;

procedure TfcBrwCartaoDebCre.FormKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if (Key = #27) then Self.Close;
end;

end.
 