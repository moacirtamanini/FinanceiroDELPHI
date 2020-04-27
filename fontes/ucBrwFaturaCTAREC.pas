unit ucBrwFaturaCTAREC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, Grids, DBGrids, DB,
  DBClient, pFIBClientDataSet, Provider, FIBDataSet, pFIBDataSet,
  FIBDatabase, pFIBDatabase, rtTypes;

type
  TfcBrwFaturaCTAREC = class(TfcPadrao)
    DBGridGrade: TDBGrid;
    pFIBTrGrade: TpFIBTransaction;
    qrGrade: TpFIBDataSet;
    pFIBDSProvGrade: TpFIBDataSetProvider;
    pFIBCdsGrade: TpFIBClientDataSet;
    dsGrade: TDataSource;
    ckQuitadas: TCheckBox;
    ckCanceladas: TCheckBox;
    btnCarregar: TBitBtn;
    procedure btnSairClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGridGradeDblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ckQuitadasClick(Sender: TObject);
    procedure DBGridGradeDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    fCodigo: Integer;
    procedure pAtualizaGrade;
  public
    property Codigo: Integer read fCodigo write fCodigo;
  end;

var
  fcBrwFaturaCTAREC: TfcBrwFaturaCTAREC;

implementation

uses uDataM;

{$R *.dfm}

procedure TfcBrwFaturaCTAREC.btnSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  inherited;
end;

procedure TfcBrwFaturaCTAREC.pAtualizaGrade;
var
  wFiltros: String;
begin
  wFiltros := ' AND (D.STATUS < 3) ';
  if (ckQuitadas.Checked) or (ckCanceladas.Checked) then
  begin
    if (ckQuitadas.Checked) and (ckCanceladas.Checked) then
      wFiltros := ' '
    else
    begin
      if (ckQuitadas.Checked) then
        wFiltros := ' AND (D.STATUS < 7) '
      else
        if (ckCanceladas.Checked) then
          wFiltros := ' AND (D.STATUS <> 3) ';
    end;
  end;

  pFIBCdsGrade.Close;
  FIBQueryAtribuirSQL(qrGrade, 'select D.id, D.Empre, D.Codigo, D.EmitenteTIP, D.EmitenteCOD, D.Status, '+
                               'case D.emitentetip '+
                               '  when 0 then (select Nome from Fornecedor where D.empre = Empre and D.emitentecod = Codigo) '+
                               '  when 1 then (select Nome from Cliente    where D.empre = Empre and D.emitentecod = Codigo) '+
                               '  end as Emitente, '+
                               'D.DoctoNRO, D.Descricao, '+
                               'D.DataEmissao, D.ParcelaQTDE, D.ParcelaTIPO, D.ValorParcela, D.ValorPrincipal, '+
                               'D.ValorPago, D.ValorPrincipal - D.ValorPago as ValorSaldo, '+
                               'D.HistoDES, D.MoedaTIP, D.CartaoTIP, D.CartaoCOD, D.CategoriaENT, '+
                               'case D.parcelatipo when 0 then ''Normal'' when 1 then ''Continuo'' end as ParcelaTIPODES, '+
                               'case D.moedatip when 0 then '''' when 1 then ''Dinheiro'' when 2 then ''Cheque'' when 3 then ''Cartão de Crédito'' when 4 then ''Cartão de Débito'' when 5 then ''Depósito Bancário'' when 6 then ''Permuta'' when 7 then ''Outros'' end as MoedaDES, '+
                               '(select Descricao as CartaoDES from CartaoDebCre  where D.empre = empre and D.cartaocod = Codigo and D.cartaotip = TPDEBCRE), '+
                               'C.descricao as categoriaEntDES, '+
                               'case D.STATUS when 0 then ''Pendente'' when 1 then ''Desdobrada'' when 2 then ''Pagto Parcial'' when 3 then ''Quitada'' when 7 then ''Cancelada'' end as StatusDES '+
                               'FROM CtaRecDocto D '+
                               'Left outer join categoria C on (D.empre = C.empre and D.categoriaEnt = C.codigo) '+
                               'WHERE (D.EMPRE = :EMPRE) '+wFiltros+
                               ' order by D.Codigo desc ');
  qrGrade.ParamByName('Empre').AsInteger := fDataM.Empresa;
  pFIBCdsGrade.Open;
  TCurrencyField(pFIBCdsGrade.FieldByName('ValorParcela')).DisplayFormat    := cMascaraValor;
  TCurrencyField(pFIBCdsGrade.FieldByName('ValorPrincipal')).DisplayFormat  := cMascaraValor;
  TCurrencyField(pFIBCdsGrade.FieldByName('ValorPago')).DisplayFormat       := cMascaraValor;
  TCurrencyField(pFIBCdsGrade.FieldByName('ValorSaldo')).DisplayFormat      := cMascaraValor;
end;

procedure TfcBrwFaturaCTAREC.btnCarregarClick(Sender: TObject);
begin
  inherited;
  if (pFIBCdsGrade.Active) and (not pFIBCdsGrade.IsEmpty) then
  begin
    fCodigo := pFIBCdsGrade.FieldByName('CODIGO').AsInteger;
    ModalResult := mrOk;
  end;
end;

procedure TfcBrwFaturaCTAREC.FormShow(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcBrwFaturaCTAREC.DBGridGradeDblClick(Sender: TObject);
begin
  inherited;
  btnCarregarClick(Sender);
end;

procedure TfcBrwFaturaCTAREC.FormKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if (Key = #27) then Self.Close;
end;

procedure TfcBrwFaturaCTAREC.ckQuitadasClick(Sender: TObject);
begin
  inherited;
  pAtualizaGrade;
end;

procedure TfcBrwFaturaCTAREC.DBGridGradeDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  inherited;
  case DBGridGrade.DataSource.DataSet.FieldByName('Status').AsInteger of
    0,2: begin // Em aberto / Pagto parcial
           DBGridGrade.Canvas.Font.Color  := CorGradeFonteAberto;
           DBGridGrade.Canvas.Brush.Color := CorGradeFundoNormal;
         end;
      3: begin // Quitado
           DBGridGrade.Canvas.Font.Color  := CorGradeFonteQuitado;
           DBGridGrade.Canvas.Brush.Color := CorGradeFundoQuitado;
          end;
      7: begin // Cancelada
           DBGridGrade.Canvas.Font.Color  := clRed;
           DBGridGrade.Canvas.Brush.Color := CorGradeFundoRealce;
          end;
  end;
  //
  if (gdSelected in State) then
  begin
    case DBGridGrade.DataSource.DataSet.FieldByName('Status').AsInteger of
    0,2: begin // Em aberto / Pagto parcial
           DBGridGrade.Canvas.Font.Color  := CorGradeFundoNormal;
           DBGridGrade.Canvas.Brush.Color := CorGradeFonteAtraso;
         end;
    3: begin
         DBGridGrade.Canvas.Font.Color    := CorGradeFonteQuitado;
         DBGridGrade.Canvas.Brush.Color   := CorGradeFundoQuitadoSele;
       end;
    7: begin // Cancelada
         DBGridGrade.Canvas.Font.Color    := clRed;
         DBGridGrade.Canvas.Brush.Color   := CorGradeFundoRealceSele;
       end;
    else
      begin
         DBGridGrade.Canvas.Font.Color    := CorGradeFonteRealceSele;
         DBGridGrade.Canvas.Brush.Color   := CorGradeFundoRealceSele;
      end;
    end;
  end;
  //
  DBGridGrade.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

end.
 