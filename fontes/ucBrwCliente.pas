unit ucBrwCliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, Grids, DBGrids,
  pFIBDatabase, pFIBQuery, DB, DBClient, pFIBClientDataSet,
  Provider, FIBDataSet, pFIBDataSet, FIBDatabase;

type
  TfcBrwCliente = class(TfcPadrao)
    pFIBTrGrade: TpFIBTransaction;
    qrGrade: TpFIBDataSet;
    pFIBDSProvGrade: TpFIBDataSetProvider;
    pFIBCdsGrade: TpFIBClientDataSet;
    dsGrade: TDataSource;
    DBGridGrade: TDBGrid;
    btnCarregar: TBitBtn;
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
  fcBrwCliente: TfcBrwCliente;

implementation

uses uDataM;

{$R *.dfm}

procedure TfcBrwCliente.btnSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  inherited;
end;

procedure TfcBrwCliente.pAtualizaGrade;
begin
  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'select C.id, C.empre, C.codigo, C.cpfcnpj, C.nome, C.apelido, '+
                               'E.logradouro||'', ''||E.numero Logra, E.bairro, E.cidade||''-''||E.uf Cidade, '+
                               'F.fonecenddd||'' ''||F.fonecennro foneCEN, '+
                               'F.fonecomddd||'' ''||F.fonecomnro foneCOM, '+
                               'F.fonecelddd||'' ''||F.fonecelnro foneCEL, '+
                               'F.fonefaxddd||'' ''||F.fonefaxnro foneFAX '+
                               'FROM CLIENTE C '+
                               'LEFT OUTER JOIN ENDERECO E ON (C.endereco = E.id) '+
                               'LEFT OUTER JOIN FONE F ON (C.fone = F.id) '+
                               'WHERE EMPRE = :EMPRE AND STATUS = 1 '+
                               'order by C.NOME ');
  qrGrade.ParamByName('Empre').AsInteger := fDataM.Empresa;
  pFIBCdsGrade.Open;
end;

procedure TfcBrwCliente.btnCarregarClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
  begin
    fCodigo := pFIBCdsGrade.FieldByName('CODIGO').AsInteger;
    ModalResult := mrOk;
  end;
end;

procedure TfcBrwCliente.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcBrwCliente.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  btnCarregarClick(Sender);
end;

procedure TfcBrwCliente.FormKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if (Key = #27) then Self.Close;
end;

end.
 