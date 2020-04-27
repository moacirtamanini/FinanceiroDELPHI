unit ucConFluxoDeCaixa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, DB, DBClient,
  pFIBClientDataSet, Provider,
  FIBDataSet, pFIBDataSet, FIBDatabase, pFIBDatabase, FIBQuery, pFIBQuery,
  Grids, DBGrids, Dateutils;

type
  TfcConFluxoDeCaixa = class(TfcPadrao)
    btnFluxo: TBitBtn;
    pFIBTrFluxo: TpFIBTransaction;
    qrFluxo: TpFIBDataSet;
    pFIBDSProvFluxo: TpFIBDataSetProvider;
    pFIBCdsFluxo: TpFIBClientDataSet;
    dsFluxo: TDataSource;
    DBGridFluxo: TDBGrid;
    ckDisponibilidades: TCheckBox;
    ckReceitas: TCheckBox;
    procedure btnFluxoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DBGridFluxoDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    wQueryGER: TpFIBQuery;
    wTransGER: TpFIBTransaction;
    wArrDatas: Array [0..85] of TDate;

    function  fGeraFluxoCaixa: Boolean;
    procedure pAtualizaGradeFluxo;
  public
  end;

var
  fcConFluxoDeCaixa: TfcConFluxoDeCaixa;

implementation

uses uDataM, rtTypes, rtCategoria;

{$R *.dfm}

procedure TfcConFluxoDeCaixa.btnFluxoClick(Sender: TObject);
begin
  inherited;
  if fGeraFluxoCaixa then
    pAtualizaGradeFluxo;
end;

procedure TfcConFluxoDeCaixa.pAtualizaGradeFluxo;
var
  wInd, wAno, wMes: Integer;
begin
  pFIBCdsFluxo.Close;
  FIBQueryAtribuirSQL(qrFluxo, 'select * from TMPFLUXO '+
                               'where (Empre = :Empre) and (Usuario = :Usuario) '+
                               'order by Empre, Usuario, TpLancto, MoedaCod, ContaCOD ');
  qrFluxo.ParamByName('Empre').AsInteger   := fDataM.Empresa;
  qrFluxo.ParamByName('Usuario').AsInteger := fDataM.Usuario;
  pFIBCdsFluxo.Open;

  TCurrencyField(pFIBCdsFluxo.FieldByName('vlrA00M01')).DisplayFormat  := cMascaraValor;
  TCurrencyField(pFIBCdsFluxo.FieldByName('vlrA99M12')).DisplayFormat  := cMascaraValor;
  for wAno := 01 to 07 do
    for wMes := 01 to 12 do
      TCurrencyField(pFIBCdsFluxo.FieldByName('vlrA'+Format('%2.2u',[wAno])+'M'+Format('%2.2u',[wMes]))).DisplayFormat  := cMascaraValor;

  for wInd := Low(wArrDatas) to High(wArrDatas) do
  begin
    DBGridFluxo.Columns[wInd + 4].Title.Caption := FormatDateTime('mm/yyyy', wArrDatas[wInd]);
    DBGridFluxo.Columns[wInd + 4].Width         := 62;
  end;

  DBGridFluxo.Columns[04].Title.Caption   := 'Até '+FormatDateTime('mm/yyyy', wArrDatas[00]);
  DBGridFluxo.Columns[04].Width           := 76;

  DBGridFluxo.Columns[89].Title.Caption   := 'Após '+FormatDateTime('mm/yyyy', wArrDatas[85]);
  DBGridFluxo.Columns[89].Width           := 76;
end;

function  TfcConFluxoDeCaixa.fGeraFluxoCaixa: Boolean;
var
  wQueryLer, wQueryAux, wQueryGra: TpFIBQuery;
  wTransLer, wTransAux, wTransGra: TpFIBTransaction;

  wDataIni: TDate;
  wArrValor: Array [0..85] of Currency;
  wArrTot10: Array [0..85] of Currency; // Receitas
  wArrTot20: Array [0..85] of Currency; // Despesas
  wArrTot99: Array [0..85] of Currency; // Geral

  procedure pSetValor(prTipo: Integer; prData: TDateTime; prValor: Currency);

    procedure pSomaVlr(prInd: Integer);
    begin
      if (prTipo = 01) then
      begin
        wArrValor[prInd] := prValor;
        wArrTot99[prInd] := wArrTot99[prInd] + prValor;
      end;

      if (prTipo = 10) then
      begin
        wArrValor[prInd] := prValor;
        wArrTot10[prInd] := wArrTot10[prInd] + prValor;
        wArrTot99[prInd] := wArrTot99[prInd] + prValor;
      end;

      if prTipo = 20 then
      begin
        wArrValor[prInd] := (prValor * -1);
        wArrTot20[prInd] := wArrTot20[prInd] + (prValor * -1);
        wArrTot99[prInd] := wArrTot99[prInd] + (prValor * -1)
      end;
    end;

  var
    wInd: Integer;
    wDia, wMes, wAno: Word;
    wOk: Boolean;
  begin
    wOk := False;
    DecodeDate(prData, wAno, wMes, wDia);
    for wInd := Low(wArrDatas) to High(wArrDatas) do
    begin
      if (MonthOf(wArrDatas[wInd]) = wMes) and (YearOf(wArrDatas[wInd]) = wAno) then
      begin
        wOk := True;
        pSomaVlr(wInd);
        Break;
      end;
    end;

    if (not wOk) then
    begin
      if (prData < wArrDatas[0]) then
        pSomaVlr(00)
      else
        pSomaVlr(85);
    end;
  end;

  function fBuscaFormaPagto(prMoeda, prTIP, prCOD, prCatSai: Integer): String;

    function fBuscaCartaoCre: String;
    begin
      Result := '';
      FIBQueryAtribuirSQL(wQueryGER, 'SELECT C.Descricao, C.NroIni, C.NroFim, C.Nome, B.Descricao as Bande '+
                                     'from cartaocredito C, bandeira B '+
                                     'where (Empre = :Empre) and (C.bandeira = B.id) and (C.codigo = :Codigo) ');
      wQueryGER.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      wQueryGER.ParamByName('Codigo').AsInteger := prCOD;
      wQueryGER.ExecQuery;
      if (not wQueryGER.Eof) then
        Result := wQueryGER.FieldByName('Descricao').AsString + ' ('+wQueryGER.FieldByName('NroIni').AsString + '...'+wQueryGER.FieldByName('NroFim').AsString + ') '+
                  wQueryGER.FieldByName('Nome').AsString + ' '+wQueryGER.FieldByName('Bande').AsString;
    end;

    function fBuscaCartaoDeb: String;
    begin
      Result := '';
      Result := '';
      FIBQueryAtribuirSQL(wQueryGER, 'SELECT C.Descricao, C.NroIni, C.NroFim, C.Nome, B.Descricao as Bande '+
                                     'from cartaodebito C, bandeira B '+
                                     'where (Empre = :Empre) and (C.bandeira = B.id) and (C.codigo = :Codigo) ');
      wQueryGER.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      wQueryGER.ParamByName('Codigo').AsInteger := prCOD;
      wQueryGER.ExecQuery;
      if (not wQueryGER.Eof) then
        Result := wQueryGER.FieldByName('Descricao').AsString + ' ('+wQueryGER.FieldByName('NroIni').AsString + '...'+wQueryGER.FieldByName('NroFim').AsString + ') '+
                  wQueryGER.FieldByName('Nome').AsString + ' '+wQueryGER.FieldByName('Bande').AsString;
    end;

    function fBuscaContaBanco: String;
    begin
      Result := '';
      FIBQueryAtribuirSQL(wQueryGER, 'select Descricao from categoria '+
                                     'where (Empre = :Empre) and (Codigo = :Codigo) ');
      wQueryGER.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      wQueryGER.ParamByName('Codigo').AsInteger := prCatSai;
      wQueryGER.ExecQuery;
      if (not wQueryGER.Eof) then
        Result := wQueryGER.FieldByName('Descricao').AsString;
    end;

  begin
    Result := '';
    case prMoeda of
      1: Result := 'Dinheiro';
      2: Result := 'Cheque';
      3: Result := fBuscaCartaoCre;
      4: Result := fBuscaCartaoDeb;
      5: Result := fBuscaContaBanco;
      6: Result := 'Permuta';
      7: Result := 'Outros';
    end;
  end;

  procedure pGravaTMP(prTpLancto: Integer);
  begin
    FIBQueryAtribuirSQL(wQueryGra, 'INSERT INTO TMPFLUXO ( USUARIO,  EMPRE,  TPLANCTO,  CONTACOD,  CONTADES,  MOEDACOD,  MOEDADES,  FORMAPAG, DESPRECE, '+
                                   ' VLRA00M01, '+
                                   ' VLRA01M01,  VLRA01M02,  VLRA01M03,  VLRA01M04,  VLRA01M05,  VLRA01M06,  VLRA01M07,  VLRA01M08,  VLRA01M09,  VLRA01M10,  VLRA01M11,  VLRA01M12, '+
                                   ' VLRA02M01,  VLRA02M02,  VLRA02M03,  VLRA02M04,  VLRA02M05,  VLRA02M06,  VLRA02M07,  VLRA02M08,  VLRA02M09,  VLRA02M10,  VLRA02M11,  VLRA02M12, '+
                                   ' VLRA03M01,  VLRA03M02,  VLRA03M03,  VLRA03M04,  VLRA03M05,  VLRA03M06,  VLRA03M07,  VLRA03M08,  VLRA03M09,  VLRA03M10,  VLRA03M11,  VLRA03M12, '+
                                   ' VLRA04M01,  VLRA04M02,  VLRA04M03,  VLRA04M04,  VLRA04M05,  VLRA04M06,  VLRA04M07,  VLRA04M08,  VLRA04M09,  VLRA04M10,  VLRA04M11,  VLRA04M12, '+
                                   ' VLRA05M01,  VLRA05M02,  VLRA05M03,  VLRA05M04,  VLRA05M05,  VLRA05M06,  VLRA05M07,  VLRA05M08,  VLRA05M09,  VLRA05M10,  VLRA05M11,  VLRA05M12, '+
                                   ' VLRA06M01,  VLRA06M02,  VLRA06M03,  VLRA06M04,  VLRA06M05,  VLRA06M06,  VLRA06M07,  VLRA06M08,  VLRA06M09,  VLRA06M10,  VLRA06M11,  VLRA06M12, '+
                                   ' VLRA07M01,  VLRA07M02,  VLRA07M03,  VLRA07M04,  VLRA07M05,  VLRA07M06,  VLRA07M07,  VLRA07M08,  VLRA07M09,  VLRA07M10,  VLRA07M11,  VLRA07M12, '+
                                   ' VLRA99M12) '+
                                   '              VALUES (:USUARIO, :EMPRE, :TPLANCTO, :CONTACOD, :CONTADES, :MOEDACOD, :MOEDADES, :FORMAPAG, :DESPRECE, '+
                                   ':VLRA00M01, '+
                                   ':VLRA01M01, :VLRA01M02, :VLRA01M03, :VLRA01M04, :VLRA01M05, :VLRA01M06, :VLRA01M07, :VLRA01M08, :VLRA01M09, :VLRA01M10, :VLRA01M11, :VLRA01M12, '+
                                   ':VLRA02M01, :VLRA02M02, :VLRA02M03, :VLRA02M04, :VLRA02M05, :VLRA02M06, :VLRA02M07, :VLRA02M08, :VLRA02M09, :VLRA02M10, :VLRA02M11, :VLRA02M12, '+
                                   ':VLRA03M01, :VLRA03M02, :VLRA03M03, :VLRA03M04, :VLRA03M05, :VLRA03M06, :VLRA03M07, :VLRA03M08, :VLRA03M09, :VLRA03M10, :VLRA03M11, :VLRA03M12, '+
                                   ':VLRA04M01, :VLRA04M02, :VLRA04M03, :VLRA04M04, :VLRA04M05, :VLRA04M06, :VLRA04M07, :VLRA04M08, :VLRA04M09, :VLRA04M10, :VLRA04M11, :VLRA04M12, '+
                                   ':VLRA05M01, :VLRA05M02, :VLRA05M03, :VLRA05M04, :VLRA05M05, :VLRA05M06, :VLRA05M07, :VLRA05M08, :VLRA05M09, :VLRA05M10, :VLRA05M11, :VLRA05M12, '+
                                   ':VLRA06M01, :VLRA06M02, :VLRA06M03, :VLRA06M04, :VLRA06M05, :VLRA06M06, :VLRA06M07, :VLRA06M08, :VLRA06M09, :VLRA06M10, :VLRA06M11, :VLRA06M12, '+
                                   ':VLRA07M01, :VLRA07M02, :VLRA07M03, :VLRA07M04, :VLRA07M05, :VLRA07M06, :VLRA07M07, :VLRA07M08, :VLRA07M09, :VLRA07M10, :VLRA07M11, :VLRA07M12, '+
                                   ':VLRA99M12) ');
    wQueryGra.ParamByName('USUARIO').AsInteger    := fDataM.Usuario;
    wQueryGra.ParamByName('EMPRE').AsInteger      := fDataM.Empresa;
    if prTpLancto = 0 then
    begin
      wQueryGra.ParamByName('TPLANCTO').AsInteger   := prTpLancto; // 0-Disponibilidades || 1-Receitas || 2-Despesas || 9-SubTotal || 9999-Total Geral
      wQueryGra.ParamByName('CONTACOD').Clear;
      wQueryGra.ParamByName('CONTADES').AsString    := 'Disponibilidades';
      wQueryGra.ParamByName('MOEDACOD').AsInteger   := 1;
      wQueryGra.ParamByName('MOEDADES').AsString    := '';
      wQueryGra.ParamByName('FORMAPAG').AsString    := '';
      wQueryGra.ParamByName('DESPRECE').AsString    := '';
    end
    else
    begin
      wQueryGra.ParamByName('TPLANCTO').AsInteger   := prTpLancto; // 0-Disponibilidades || 1-Receitas || 2-Despesas || 9-SubTotal || 9999-Total Geral
      wQueryGra.ParamByName('CONTACOD').AsInteger   := wQueryLer.FieldByName('CategoriaA').AsInteger;
      wQueryGra.ParamByName('CONTADES').AsString    := wQueryLer.FieldByName('CatNome').AsString;
      wQueryGra.ParamByName('MOEDACOD').AsInteger   := wQueryAux.FieldByName('MoedaTIP').AsInteger;
      wQueryGra.ParamByName('MOEDADES').AsString    := wQueryAux.FieldByName('MoedaDES').AsString;
      wQueryGra.ParamByName('FORMAPAG').AsString    := fBuscaFormaPagto(wQueryAux.FieldByName('MoedaTIP').AsInteger, wQueryAux.FieldByName('CartaoTIP').AsInteger, wQueryAux.FieldByName('CartaoCOD').AsInteger, wQueryLer.FieldByName('CategoriaB').AsInteger);
      wQueryGra.ParamByName('DESPRECE').AsString    := 'AP: Fatura:'+wQueryLer.FieldByName('codigo').AsString+' - Nº Docto:'+ wQueryLer.FieldByName('doctonro').AsString+' - '+wQueryLer.FieldByName('Descricao').AsString;
    end;

    wQueryGra.ParamByName('VLRA00M01').AsCurrency := wArrValor[000]; // Até

    wQueryGra.ParamByName('VLRA01M01').AsCurrency := wArrValor[001];
    wQueryGra.ParamByName('VLRA01M02').AsCurrency := wArrValor[002];
    wQueryGra.ParamByName('VLRA01M03').AsCurrency := wArrValor[003];
    wQueryGra.ParamByName('VLRA01M04').AsCurrency := wArrValor[004];
    wQueryGra.ParamByName('VLRA01M05').AsCurrency := wArrValor[005];
    wQueryGra.ParamByName('VLRA01M06').AsCurrency := wArrValor[006];
    wQueryGra.ParamByName('VLRA01M07').AsCurrency := wArrValor[007];
    wQueryGra.ParamByName('VLRA01M08').AsCurrency := wArrValor[008];
    wQueryGra.ParamByName('VLRA01M09').AsCurrency := wArrValor[009];
    wQueryGra.ParamByName('VLRA01M10').AsCurrency := wArrValor[010];
    wQueryGra.ParamByName('VLRA01M11').AsCurrency := wArrValor[011];
    wQueryGra.ParamByName('VLRA01M12').AsCurrency := wArrValor[012];

    wQueryGra.ParamByName('VLRA02M01').AsCurrency := wArrValor[013];
    wQueryGra.ParamByName('VLRA02M02').AsCurrency := wArrValor[014];
    wQueryGra.ParamByName('VLRA02M03').AsCurrency := wArrValor[015];
    wQueryGra.ParamByName('VLRA02M04').AsCurrency := wArrValor[016];
    wQueryGra.ParamByName('VLRA02M05').AsCurrency := wArrValor[017];
    wQueryGra.ParamByName('VLRA02M06').AsCurrency := wArrValor[018];
    wQueryGra.ParamByName('VLRA02M07').AsCurrency := wArrValor[019];
    wQueryGra.ParamByName('VLRA02M08').AsCurrency := wArrValor[020];
    wQueryGra.ParamByName('VLRA02M09').AsCurrency := wArrValor[021];
    wQueryGra.ParamByName('VLRA02M10').AsCurrency := wArrValor[022];
    wQueryGra.ParamByName('VLRA02M11').AsCurrency := wArrValor[023];
    wQueryGra.ParamByName('VLRA02M12').AsCurrency := wArrValor[024];

    wQueryGra.ParamByName('VLRA03M01').AsCurrency := wArrValor[025];
    wQueryGra.ParamByName('VLRA03M02').AsCurrency := wArrValor[026];
    wQueryGra.ParamByName('VLRA03M03').AsCurrency := wArrValor[027];
    wQueryGra.ParamByName('VLRA03M04').AsCurrency := wArrValor[028];
    wQueryGra.ParamByName('VLRA03M05').AsCurrency := wArrValor[029];
    wQueryGra.ParamByName('VLRA03M06').AsCurrency := wArrValor[030];
    wQueryGra.ParamByName('VLRA03M07').AsCurrency := wArrValor[031];
    wQueryGra.ParamByName('VLRA03M08').AsCurrency := wArrValor[032];
    wQueryGra.ParamByName('VLRA03M09').AsCurrency := wArrValor[033];
    wQueryGra.ParamByName('VLRA03M10').AsCurrency := wArrValor[034];
    wQueryGra.ParamByName('VLRA03M11').AsCurrency := wArrValor[035];
    wQueryGra.ParamByName('VLRA03M12').AsCurrency := wArrValor[036];

    wQueryGra.ParamByName('VLRA04M01').AsCurrency := wArrValor[037];
    wQueryGra.ParamByName('VLRA04M02').AsCurrency := wArrValor[038];
    wQueryGra.ParamByName('VLRA04M03').AsCurrency := wArrValor[039];
    wQueryGra.ParamByName('VLRA04M04').AsCurrency := wArrValor[040];
    wQueryGra.ParamByName('VLRA04M05').AsCurrency := wArrValor[041];
    wQueryGra.ParamByName('VLRA04M06').AsCurrency := wArrValor[042];
    wQueryGra.ParamByName('VLRA04M07').AsCurrency := wArrValor[043];
    wQueryGra.ParamByName('VLRA04M08').AsCurrency := wArrValor[044];
    wQueryGra.ParamByName('VLRA04M09').AsCurrency := wArrValor[045];
    wQueryGra.ParamByName('VLRA04M10').AsCurrency := wArrValor[046];
    wQueryGra.ParamByName('VLRA04M11').AsCurrency := wArrValor[047];
    wQueryGra.ParamByName('VLRA04M12').AsCurrency := wArrValor[048];

    wQueryGra.ParamByName('VLRA05M01').AsCurrency := wArrValor[049];
    wQueryGra.ParamByName('VLRA05M02').AsCurrency := wArrValor[050];
    wQueryGra.ParamByName('VLRA05M03').AsCurrency := wArrValor[051];
    wQueryGra.ParamByName('VLRA05M04').AsCurrency := wArrValor[052];
    wQueryGra.ParamByName('VLRA05M05').AsCurrency := wArrValor[053];
    wQueryGra.ParamByName('VLRA05M06').AsCurrency := wArrValor[054];
    wQueryGra.ParamByName('VLRA05M07').AsCurrency := wArrValor[055];
    wQueryGra.ParamByName('VLRA05M08').AsCurrency := wArrValor[056];
    wQueryGra.ParamByName('VLRA05M09').AsCurrency := wArrValor[057];
    wQueryGra.ParamByName('VLRA05M10').AsCurrency := wArrValor[058];
    wQueryGra.ParamByName('VLRA05M11').AsCurrency := wArrValor[059];
    wQueryGra.ParamByName('VLRA05M12').AsCurrency := wArrValor[060];

    wQueryGra.ParamByName('VLRA06M01').AsCurrency := wArrValor[061];
    wQueryGra.ParamByName('VLRA06M02').AsCurrency := wArrValor[062];
    wQueryGra.ParamByName('VLRA06M03').AsCurrency := wArrValor[063];
    wQueryGra.ParamByName('VLRA06M04').AsCurrency := wArrValor[064];
    wQueryGra.ParamByName('VLRA06M05').AsCurrency := wArrValor[065];
    wQueryGra.ParamByName('VLRA06M06').AsCurrency := wArrValor[066];
    wQueryGra.ParamByName('VLRA06M07').AsCurrency := wArrValor[067];
    wQueryGra.ParamByName('VLRA06M08').AsCurrency := wArrValor[068];
    wQueryGra.ParamByName('VLRA06M09').AsCurrency := wArrValor[069];
    wQueryGra.ParamByName('VLRA06M10').AsCurrency := wArrValor[070];
    wQueryGra.ParamByName('VLRA06M11').AsCurrency := wArrValor[071];
    wQueryGra.ParamByName('VLRA06M12').AsCurrency := wArrValor[072];

    wQueryGra.ParamByName('VLRA07M01').AsCurrency := wArrValor[073];
    wQueryGra.ParamByName('VLRA07M02').AsCurrency := wArrValor[074];
    wQueryGra.ParamByName('VLRA07M03').AsCurrency := wArrValor[075];
    wQueryGra.ParamByName('VLRA07M04').AsCurrency := wArrValor[076];
    wQueryGra.ParamByName('VLRA07M05').AsCurrency := wArrValor[077];
    wQueryGra.ParamByName('VLRA07M06').AsCurrency := wArrValor[078];
    wQueryGra.ParamByName('VLRA07M07').AsCurrency := wArrValor[079];
    wQueryGra.ParamByName('VLRA07M08').AsCurrency := wArrValor[080];
    wQueryGra.ParamByName('VLRA07M09').AsCurrency := wArrValor[081];
    wQueryGra.ParamByName('VLRA07M10').AsCurrency := wArrValor[082];
    wQueryGra.ParamByName('VLRA07M11').AsCurrency := wArrValor[083];
    wQueryGra.ParamByName('VLRA07M12').AsCurrency := wArrValor[084];

    wQueryGra.ParamByName('VLRA99M12').AsCurrency := wArrValor[085]; // Após

    wQueryGra.ExecQuery;
    FIBQueryCommit(wQueryGra);
  end;

  // TPLANCTO: 00-Disponibilidades || 10-Receitas || 19-SubTotal Receitas || 20-Despesas || 29-SubTotal Despesas || 9999-Total Geral
  procedure pSomaTMP;
  begin
    if ckReceitas.Checked then
    begin
      FIBQueryAtribuirSQL(wQueryGra, 'INSERT INTO TMPFLUXO ( USUARIO,  EMPRE,  TPLANCTO,  CONTADES,  DESPRECE, '+
                                     ' VLRA00M01, '+
                                     ' VLRA01M01,  VLRA01M02,  VLRA01M03,  VLRA01M04,  VLRA01M05,  VLRA01M06,  VLRA01M07,  VLRA01M08,  VLRA01M09,  VLRA01M10,  VLRA01M11,  VLRA01M12, '+
                                     ' VLRA02M01,  VLRA02M02,  VLRA02M03,  VLRA02M04,  VLRA02M05,  VLRA02M06,  VLRA02M07,  VLRA02M08,  VLRA02M09,  VLRA02M10,  VLRA02M11,  VLRA02M12, '+
                                     ' VLRA03M01,  VLRA03M02,  VLRA03M03,  VLRA03M04,  VLRA03M05,  VLRA03M06,  VLRA03M07,  VLRA03M08,  VLRA03M09,  VLRA03M10,  VLRA03M11,  VLRA03M12, '+
                                     ' VLRA04M01,  VLRA04M02,  VLRA04M03,  VLRA04M04,  VLRA04M05,  VLRA04M06,  VLRA04M07,  VLRA04M08,  VLRA04M09,  VLRA04M10,  VLRA04M11,  VLRA04M12, '+
                                     ' VLRA05M01,  VLRA05M02,  VLRA05M03,  VLRA05M04,  VLRA05M05,  VLRA05M06,  VLRA05M07,  VLRA05M08,  VLRA05M09,  VLRA05M10,  VLRA05M11,  VLRA05M12, '+
                                     ' VLRA06M01,  VLRA06M02,  VLRA06M03,  VLRA06M04,  VLRA06M05,  VLRA06M06,  VLRA06M07,  VLRA06M08,  VLRA06M09,  VLRA06M10,  VLRA06M11,  VLRA06M12, '+
                                     ' VLRA07M01,  VLRA07M02,  VLRA07M03,  VLRA07M04,  VLRA07M05,  VLRA07M06,  VLRA07M07,  VLRA07M08,  VLRA07M09,  VLRA07M10,  VLRA07M11,  VLRA07M12, '+
                                     ' VLRA99M12) '+
                                     '              VALUES (:USUARIO, :EMPRE, :TPLANCTO, :CONTADES, :DESPRECE, '+
                                     ':VLRA00M01, '+
                                     ':VLRA01M01, :VLRA01M02, :VLRA01M03, :VLRA01M04, :VLRA01M05, :VLRA01M06, :VLRA01M07, :VLRA01M08, :VLRA01M09, :VLRA01M10, :VLRA01M11, :VLRA01M12, '+
                                     ':VLRA02M01, :VLRA02M02, :VLRA02M03, :VLRA02M04, :VLRA02M05, :VLRA02M06, :VLRA02M07, :VLRA02M08, :VLRA02M09, :VLRA02M10, :VLRA02M11, :VLRA02M12, '+
                                     ':VLRA03M01, :VLRA03M02, :VLRA03M03, :VLRA03M04, :VLRA03M05, :VLRA03M06, :VLRA03M07, :VLRA03M08, :VLRA03M09, :VLRA03M10, :VLRA03M11, :VLRA03M12, '+
                                     ':VLRA04M01, :VLRA04M02, :VLRA04M03, :VLRA04M04, :VLRA04M05, :VLRA04M06, :VLRA04M07, :VLRA04M08, :VLRA04M09, :VLRA04M10, :VLRA04M11, :VLRA04M12, '+
                                     ':VLRA05M01, :VLRA05M02, :VLRA05M03, :VLRA05M04, :VLRA05M05, :VLRA05M06, :VLRA05M07, :VLRA05M08, :VLRA05M09, :VLRA05M10, :VLRA05M11, :VLRA05M12, '+
                                     ':VLRA06M01, :VLRA06M02, :VLRA06M03, :VLRA06M04, :VLRA06M05, :VLRA06M06, :VLRA06M07, :VLRA06M08, :VLRA06M09, :VLRA06M10, :VLRA06M11, :VLRA06M12, '+
                                     ':VLRA07M01, :VLRA07M02, :VLRA07M03, :VLRA07M04, :VLRA07M05, :VLRA07M06, :VLRA07M07, :VLRA07M08, :VLRA07M09, :VLRA07M10, :VLRA07M11, :VLRA07M12, '+
                                     ':VLRA99M12) ');
      wQueryGra.ParamByName('USUARIO').AsInteger    := fDataM.Usuario;
      wQueryGra.ParamByName('EMPRE').AsInteger      := fDataM.Empresa;
      wQueryGra.ParamByName('TPLANCTO').AsInteger   := 19;
      wQueryGra.ParamByName('CONTADES').AsString    := 'SubTotal de Receitas';
      wQueryGra.ParamByName('DESPRECE').AsString    := 'SubTotal de Receitas';

      wQueryGra.ParamByName('VLRA00M01').AsCurrency := wArrTot10[000];

      wQueryGra.ParamByName('VLRA01M01').AsCurrency := wArrTot10[001];
      wQueryGra.ParamByName('VLRA01M02').AsCurrency := wArrTot10[002];
      wQueryGra.ParamByName('VLRA01M03').AsCurrency := wArrTot10[003];
      wQueryGra.ParamByName('VLRA01M04').AsCurrency := wArrTot10[004];
      wQueryGra.ParamByName('VLRA01M05').AsCurrency := wArrTot10[005];
      wQueryGra.ParamByName('VLRA01M06').AsCurrency := wArrTot10[006];
      wQueryGra.ParamByName('VLRA01M07').AsCurrency := wArrTot10[007];
      wQueryGra.ParamByName('VLRA01M08').AsCurrency := wArrTot10[008];
      wQueryGra.ParamByName('VLRA01M09').AsCurrency := wArrTot10[009];
      wQueryGra.ParamByName('VLRA01M10').AsCurrency := wArrTot10[010];
      wQueryGra.ParamByName('VLRA01M11').AsCurrency := wArrTot10[011];
      wQueryGra.ParamByName('VLRA01M12').AsCurrency := wArrTot10[012];

      wQueryGra.ParamByName('VLRA02M01').AsCurrency := wArrTot10[013];
      wQueryGra.ParamByName('VLRA02M02').AsCurrency := wArrTot10[014];
      wQueryGra.ParamByName('VLRA02M03').AsCurrency := wArrTot10[015];
      wQueryGra.ParamByName('VLRA02M04').AsCurrency := wArrTot10[016];
      wQueryGra.ParamByName('VLRA02M05').AsCurrency := wArrTot10[017];
      wQueryGra.ParamByName('VLRA02M06').AsCurrency := wArrTot10[018];
      wQueryGra.ParamByName('VLRA02M07').AsCurrency := wArrTot10[019];
      wQueryGra.ParamByName('VLRA02M08').AsCurrency := wArrTot10[020];
      wQueryGra.ParamByName('VLRA02M09').AsCurrency := wArrTot10[021];
      wQueryGra.ParamByName('VLRA02M10').AsCurrency := wArrTot10[022];
      wQueryGra.ParamByName('VLRA02M11').AsCurrency := wArrTot10[023];
      wQueryGra.ParamByName('VLRA02M12').AsCurrency := wArrTot10[024];

      wQueryGra.ParamByName('VLRA03M01').AsCurrency := wArrTot10[025];
      wQueryGra.ParamByName('VLRA03M02').AsCurrency := wArrTot10[026];
      wQueryGra.ParamByName('VLRA03M03').AsCurrency := wArrTot10[027];
      wQueryGra.ParamByName('VLRA03M04').AsCurrency := wArrTot10[028];
      wQueryGra.ParamByName('VLRA03M05').AsCurrency := wArrTot10[029];
      wQueryGra.ParamByName('VLRA03M06').AsCurrency := wArrTot10[030];
      wQueryGra.ParamByName('VLRA03M07').AsCurrency := wArrTot10[031];
      wQueryGra.ParamByName('VLRA03M08').AsCurrency := wArrTot10[032];
      wQueryGra.ParamByName('VLRA03M09').AsCurrency := wArrTot10[033];
      wQueryGra.ParamByName('VLRA03M10').AsCurrency := wArrTot10[034];
      wQueryGra.ParamByName('VLRA03M11').AsCurrency := wArrTot10[035];
      wQueryGra.ParamByName('VLRA03M12').AsCurrency := wArrTot10[036];

      wQueryGra.ParamByName('VLRA04M01').AsCurrency := wArrTot10[037];
      wQueryGra.ParamByName('VLRA04M02').AsCurrency := wArrTot10[038];
      wQueryGra.ParamByName('VLRA04M03').AsCurrency := wArrTot10[039];
      wQueryGra.ParamByName('VLRA04M04').AsCurrency := wArrTot10[040];
      wQueryGra.ParamByName('VLRA04M05').AsCurrency := wArrTot10[041];
      wQueryGra.ParamByName('VLRA04M06').AsCurrency := wArrTot10[042];
      wQueryGra.ParamByName('VLRA04M07').AsCurrency := wArrTot10[043];
      wQueryGra.ParamByName('VLRA04M08').AsCurrency := wArrTot10[044];
      wQueryGra.ParamByName('VLRA04M09').AsCurrency := wArrTot10[045];
      wQueryGra.ParamByName('VLRA04M10').AsCurrency := wArrTot10[046];
      wQueryGra.ParamByName('VLRA04M11').AsCurrency := wArrTot10[047];
      wQueryGra.ParamByName('VLRA04M12').AsCurrency := wArrTot10[048];

      wQueryGra.ParamByName('VLRA05M01').AsCurrency := wArrTot10[049];
      wQueryGra.ParamByName('VLRA05M02').AsCurrency := wArrTot10[050];
      wQueryGra.ParamByName('VLRA05M03').AsCurrency := wArrTot10[051];
      wQueryGra.ParamByName('VLRA05M04').AsCurrency := wArrTot10[052];
      wQueryGra.ParamByName('VLRA05M05').AsCurrency := wArrTot10[053];
      wQueryGra.ParamByName('VLRA05M06').AsCurrency := wArrTot10[054];
      wQueryGra.ParamByName('VLRA05M07').AsCurrency := wArrTot10[055];
      wQueryGra.ParamByName('VLRA05M08').AsCurrency := wArrTot10[056];
      wQueryGra.ParamByName('VLRA05M09').AsCurrency := wArrTot10[057];
      wQueryGra.ParamByName('VLRA05M10').AsCurrency := wArrTot10[058];
      wQueryGra.ParamByName('VLRA05M11').AsCurrency := wArrTot10[059];
      wQueryGra.ParamByName('VLRA05M12').AsCurrency := wArrTot10[060];

      wQueryGra.ParamByName('VLRA06M01').AsCurrency := wArrTot10[061];
      wQueryGra.ParamByName('VLRA06M02').AsCurrency := wArrTot10[062];
      wQueryGra.ParamByName('VLRA06M03').AsCurrency := wArrTot10[063];
      wQueryGra.ParamByName('VLRA06M04').AsCurrency := wArrTot10[064];
      wQueryGra.ParamByName('VLRA06M05').AsCurrency := wArrTot10[065];
      wQueryGra.ParamByName('VLRA06M06').AsCurrency := wArrTot10[066];
      wQueryGra.ParamByName('VLRA06M07').AsCurrency := wArrTot10[067];
      wQueryGra.ParamByName('VLRA06M08').AsCurrency := wArrTot10[068];
      wQueryGra.ParamByName('VLRA06M09').AsCurrency := wArrTot10[069];
      wQueryGra.ParamByName('VLRA06M10').AsCurrency := wArrTot10[070];
      wQueryGra.ParamByName('VLRA06M11').AsCurrency := wArrTot10[071];
      wQueryGra.ParamByName('VLRA06M12').AsCurrency := wArrTot10[072];

      wQueryGra.ParamByName('VLRA07M01').AsCurrency := wArrTot10[073];
      wQueryGra.ParamByName('VLRA07M02').AsCurrency := wArrTot10[074];
      wQueryGra.ParamByName('VLRA07M03').AsCurrency := wArrTot10[075];
      wQueryGra.ParamByName('VLRA07M04').AsCurrency := wArrTot10[076];
      wQueryGra.ParamByName('VLRA07M05').AsCurrency := wArrTot10[077];
      wQueryGra.ParamByName('VLRA07M06').AsCurrency := wArrTot10[078];
      wQueryGra.ParamByName('VLRA07M07').AsCurrency := wArrTot10[079];
      wQueryGra.ParamByName('VLRA07M08').AsCurrency := wArrTot10[080];
      wQueryGra.ParamByName('VLRA07M09').AsCurrency := wArrTot10[081];
      wQueryGra.ParamByName('VLRA07M10').AsCurrency := wArrTot10[082];
      wQueryGra.ParamByName('VLRA07M11').AsCurrency := wArrTot10[083];
      wQueryGra.ParamByName('VLRA07M12').AsCurrency := wArrTot10[084];

      wQueryGra.ParamByName('VLRA99M12').AsCurrency := wArrTot10[085];
      wQueryGra.ExecQuery;
      FIBQueryCommit(wQueryGra);
    end;

    // Despesas
    FIBQueryAtribuirSQL(wQueryGra, 'INSERT INTO TMPFLUXO ( USUARIO,  EMPRE,  TPLANCTO,  CONTADES,  DESPRECE, '+
                                      ' VLRA00M01, '+
                                      ' VLRA01M01,  VLRA01M02,  VLRA01M03,  VLRA01M04,  VLRA01M05,  VLRA01M06,  VLRA01M07,  VLRA01M08,  VLRA01M09,  VLRA01M10,  VLRA01M11,  VLRA01M12, '+
                                      ' VLRA02M01,  VLRA02M02,  VLRA02M03,  VLRA02M04,  VLRA02M05,  VLRA02M06,  VLRA02M07,  VLRA02M08,  VLRA02M09,  VLRA02M10,  VLRA02M11,  VLRA02M12, '+
                                      ' VLRA03M01,  VLRA03M02,  VLRA03M03,  VLRA03M04,  VLRA03M05,  VLRA03M06,  VLRA03M07,  VLRA03M08,  VLRA03M09,  VLRA03M10,  VLRA03M11,  VLRA03M12, '+
                                      ' VLRA04M01,  VLRA04M02,  VLRA04M03,  VLRA04M04,  VLRA04M05,  VLRA04M06,  VLRA04M07,  VLRA04M08,  VLRA04M09,  VLRA04M10,  VLRA04M11,  VLRA04M12, '+
                                      ' VLRA05M01,  VLRA05M02,  VLRA05M03,  VLRA05M04,  VLRA05M05,  VLRA05M06,  VLRA05M07,  VLRA05M08,  VLRA05M09,  VLRA05M10,  VLRA05M11,  VLRA05M12, '+
                                      ' VLRA06M01,  VLRA06M02,  VLRA06M03,  VLRA06M04,  VLRA06M05,  VLRA06M06,  VLRA06M07,  VLRA06M08,  VLRA06M09,  VLRA06M10,  VLRA06M11,  VLRA06M12, '+
                                      ' VLRA07M01,  VLRA07M02,  VLRA07M03,  VLRA07M04,  VLRA07M05,  VLRA07M06,  VLRA07M07,  VLRA07M08,  VLRA07M09,  VLRA07M10,  VLRA07M11,  VLRA07M12, '+
                                      ' VLRA99M12) '+
                                      '              VALUES (:USUARIO, :EMPRE, :TPLANCTO, :CONTADES, :DESPRECE, '+
                                      ':VLRA00M01, '+
                                      ':VLRA01M01, :VLRA01M02, :VLRA01M03, :VLRA01M04, :VLRA01M05, :VLRA01M06, :VLRA01M07, :VLRA01M08, :VLRA01M09, :VLRA01M10, :VLRA01M11, :VLRA01M12, '+
                                      ':VLRA02M01, :VLRA02M02, :VLRA02M03, :VLRA02M04, :VLRA02M05, :VLRA02M06, :VLRA02M07, :VLRA02M08, :VLRA02M09, :VLRA02M10, :VLRA02M11, :VLRA02M12, '+
                                      ':VLRA03M01, :VLRA03M02, :VLRA03M03, :VLRA03M04, :VLRA03M05, :VLRA03M06, :VLRA03M07, :VLRA03M08, :VLRA03M09, :VLRA03M10, :VLRA03M11, :VLRA03M12, '+
                                      ':VLRA04M01, :VLRA04M02, :VLRA04M03, :VLRA04M04, :VLRA04M05, :VLRA04M06, :VLRA04M07, :VLRA04M08, :VLRA04M09, :VLRA04M10, :VLRA04M11, :VLRA04M12, '+
                                      ':VLRA05M01, :VLRA05M02, :VLRA05M03, :VLRA05M04, :VLRA05M05, :VLRA05M06, :VLRA05M07, :VLRA05M08, :VLRA05M09, :VLRA05M10, :VLRA05M11, :VLRA05M12, '+
                                      ':VLRA06M01, :VLRA06M02, :VLRA06M03, :VLRA06M04, :VLRA06M05, :VLRA06M06, :VLRA06M07, :VLRA06M08, :VLRA06M09, :VLRA06M10, :VLRA06M11, :VLRA06M12, '+
                                      ':VLRA07M01, :VLRA07M02, :VLRA07M03, :VLRA07M04, :VLRA07M05, :VLRA07M06, :VLRA07M07, :VLRA07M08, :VLRA07M09, :VLRA07M10, :VLRA07M11, :VLRA07M12, '+
                                      ':VLRA99M12) ');
    wQueryGra.ParamByName('USUARIO').AsInteger    := fDataM.Usuario;
    wQueryGra.ParamByName('EMPRE').AsInteger      := fDataM.Empresa;
    wQueryGra.ParamByName('TPLANCTO').AsInteger   := 29;
    wQueryGra.ParamByName('CONTADES').AsString    := 'SubTotal de Despesas';
    wQueryGra.ParamByName('DESPRECE').AsString    := 'SubTotal de Despesas';

    wQueryGra.ParamByName('VLRA00M01').AsCurrency := wArrTot20[000];

    wQueryGra.ParamByName('VLRA01M01').AsCurrency := wArrTot20[001];
    wQueryGra.ParamByName('VLRA01M02').AsCurrency := wArrTot20[002];
    wQueryGra.ParamByName('VLRA01M03').AsCurrency := wArrTot20[003];
    wQueryGra.ParamByName('VLRA01M04').AsCurrency := wArrTot20[004];
    wQueryGra.ParamByName('VLRA01M05').AsCurrency := wArrTot20[005];
    wQueryGra.ParamByName('VLRA01M06').AsCurrency := wArrTot20[006];
    wQueryGra.ParamByName('VLRA01M07').AsCurrency := wArrTot20[007];
    wQueryGra.ParamByName('VLRA01M08').AsCurrency := wArrTot20[008];
    wQueryGra.ParamByName('VLRA01M09').AsCurrency := wArrTot20[009];
    wQueryGra.ParamByName('VLRA01M10').AsCurrency := wArrTot20[010];
    wQueryGra.ParamByName('VLRA01M11').AsCurrency := wArrTot20[011];
    wQueryGra.ParamByName('VLRA01M12').AsCurrency := wArrTot20[012];

    wQueryGra.ParamByName('VLRA02M01').AsCurrency := wArrTot20[013];
    wQueryGra.ParamByName('VLRA02M02').AsCurrency := wArrTot20[014];
    wQueryGra.ParamByName('VLRA02M03').AsCurrency := wArrTot20[015];
    wQueryGra.ParamByName('VLRA02M04').AsCurrency := wArrTot20[016];
    wQueryGra.ParamByName('VLRA02M05').AsCurrency := wArrTot20[017];
    wQueryGra.ParamByName('VLRA02M06').AsCurrency := wArrTot20[018];
    wQueryGra.ParamByName('VLRA02M07').AsCurrency := wArrTot20[019];
    wQueryGra.ParamByName('VLRA02M08').AsCurrency := wArrTot20[020];
    wQueryGra.ParamByName('VLRA02M09').AsCurrency := wArrTot20[021];
    wQueryGra.ParamByName('VLRA02M10').AsCurrency := wArrTot20[022];
    wQueryGra.ParamByName('VLRA02M11').AsCurrency := wArrTot20[023];
    wQueryGra.ParamByName('VLRA02M12').AsCurrency := wArrTot20[024];

    wQueryGra.ParamByName('VLRA03M01').AsCurrency := wArrTot20[025];
    wQueryGra.ParamByName('VLRA03M02').AsCurrency := wArrTot20[026];
    wQueryGra.ParamByName('VLRA03M03').AsCurrency := wArrTot20[027];
    wQueryGra.ParamByName('VLRA03M04').AsCurrency := wArrTot20[028];
    wQueryGra.ParamByName('VLRA03M05').AsCurrency := wArrTot20[029];
    wQueryGra.ParamByName('VLRA03M06').AsCurrency := wArrTot20[030];
    wQueryGra.ParamByName('VLRA03M07').AsCurrency := wArrTot20[031];
    wQueryGra.ParamByName('VLRA03M08').AsCurrency := wArrTot20[032];
    wQueryGra.ParamByName('VLRA03M09').AsCurrency := wArrTot20[033];
    wQueryGra.ParamByName('VLRA03M10').AsCurrency := wArrTot20[034];
    wQueryGra.ParamByName('VLRA03M11').AsCurrency := wArrTot20[035];
    wQueryGra.ParamByName('VLRA03M12').AsCurrency := wArrTot20[036];

    wQueryGra.ParamByName('VLRA04M01').AsCurrency := wArrTot20[037];
    wQueryGra.ParamByName('VLRA04M02').AsCurrency := wArrTot20[038];
    wQueryGra.ParamByName('VLRA04M03').AsCurrency := wArrTot20[039];
    wQueryGra.ParamByName('VLRA04M04').AsCurrency := wArrTot20[040];
    wQueryGra.ParamByName('VLRA04M05').AsCurrency := wArrTot20[041];
    wQueryGra.ParamByName('VLRA04M06').AsCurrency := wArrTot20[042];
    wQueryGra.ParamByName('VLRA04M07').AsCurrency := wArrTot20[043];
    wQueryGra.ParamByName('VLRA04M08').AsCurrency := wArrTot20[044];
    wQueryGra.ParamByName('VLRA04M09').AsCurrency := wArrTot20[045];
    wQueryGra.ParamByName('VLRA04M10').AsCurrency := wArrTot20[046];
    wQueryGra.ParamByName('VLRA04M11').AsCurrency := wArrTot20[047];
    wQueryGra.ParamByName('VLRA04M12').AsCurrency := wArrTot20[048];

    wQueryGra.ParamByName('VLRA05M01').AsCurrency := wArrTot20[049];
    wQueryGra.ParamByName('VLRA05M02').AsCurrency := wArrTot20[050];
    wQueryGra.ParamByName('VLRA05M03').AsCurrency := wArrTot20[051];
    wQueryGra.ParamByName('VLRA05M04').AsCurrency := wArrTot20[052];
    wQueryGra.ParamByName('VLRA05M05').AsCurrency := wArrTot20[053];
    wQueryGra.ParamByName('VLRA05M06').AsCurrency := wArrTot20[054];
    wQueryGra.ParamByName('VLRA05M07').AsCurrency := wArrTot20[055];
    wQueryGra.ParamByName('VLRA05M08').AsCurrency := wArrTot20[056];
    wQueryGra.ParamByName('VLRA05M09').AsCurrency := wArrTot20[057];
    wQueryGra.ParamByName('VLRA05M10').AsCurrency := wArrTot20[058];
    wQueryGra.ParamByName('VLRA05M11').AsCurrency := wArrTot20[059];
    wQueryGra.ParamByName('VLRA05M12').AsCurrency := wArrTot20[060];

    wQueryGra.ParamByName('VLRA06M01').AsCurrency := wArrTot20[061];
    wQueryGra.ParamByName('VLRA06M02').AsCurrency := wArrTot20[062];
    wQueryGra.ParamByName('VLRA06M03').AsCurrency := wArrTot20[063];
    wQueryGra.ParamByName('VLRA06M04').AsCurrency := wArrTot20[064];
    wQueryGra.ParamByName('VLRA06M05').AsCurrency := wArrTot20[065];
    wQueryGra.ParamByName('VLRA06M06').AsCurrency := wArrTot20[066];
    wQueryGra.ParamByName('VLRA06M07').AsCurrency := wArrTot20[067];
    wQueryGra.ParamByName('VLRA06M08').AsCurrency := wArrTot20[068];
    wQueryGra.ParamByName('VLRA06M09').AsCurrency := wArrTot20[069];
    wQueryGra.ParamByName('VLRA06M10').AsCurrency := wArrTot20[070];
    wQueryGra.ParamByName('VLRA06M11').AsCurrency := wArrTot20[071];
    wQueryGra.ParamByName('VLRA06M12').AsCurrency := wArrTot20[072];

    wQueryGra.ParamByName('VLRA07M01').AsCurrency := wArrTot20[073];
    wQueryGra.ParamByName('VLRA07M02').AsCurrency := wArrTot20[074];
    wQueryGra.ParamByName('VLRA07M03').AsCurrency := wArrTot20[075];
    wQueryGra.ParamByName('VLRA07M04').AsCurrency := wArrTot20[076];
    wQueryGra.ParamByName('VLRA07M05').AsCurrency := wArrTot20[077];
    wQueryGra.ParamByName('VLRA07M06').AsCurrency := wArrTot20[078];
    wQueryGra.ParamByName('VLRA07M07').AsCurrency := wArrTot20[079];
    wQueryGra.ParamByName('VLRA07M08').AsCurrency := wArrTot20[080];
    wQueryGra.ParamByName('VLRA07M09').AsCurrency := wArrTot20[081];
    wQueryGra.ParamByName('VLRA07M10').AsCurrency := wArrTot20[082];
    wQueryGra.ParamByName('VLRA07M11').AsCurrency := wArrTot20[083];
    wQueryGra.ParamByName('VLRA07M12').AsCurrency := wArrTot20[084];

    wQueryGra.ParamByName('VLRA99M12').AsCurrency := wArrTot20[085];
    wQueryGra.ExecQuery;
    FIBQueryCommit(wQueryGra);

    // Total Geral
    FIBQueryAtribuirSQL(wQueryGra, 'INSERT INTO TMPFLUXO ( USUARIO,  EMPRE,  TPLANCTO,  CONTADES,  DESPRECE, '+
                                      ' VLRA00M01, '+
                                      ' VLRA01M01,  VLRA01M02,  VLRA01M03,  VLRA01M04,  VLRA01M05,  VLRA01M06,  VLRA01M07,  VLRA01M08,  VLRA01M09,  VLRA01M10,  VLRA01M11,  VLRA01M12, '+
                                      ' VLRA02M01,  VLRA02M02,  VLRA02M03,  VLRA02M04,  VLRA02M05,  VLRA02M06,  VLRA02M07,  VLRA02M08,  VLRA02M09,  VLRA02M10,  VLRA02M11,  VLRA02M12, '+
                                      ' VLRA03M01,  VLRA03M02,  VLRA03M03,  VLRA03M04,  VLRA03M05,  VLRA03M06,  VLRA03M07,  VLRA03M08,  VLRA03M09,  VLRA03M10,  VLRA03M11,  VLRA03M12, '+
                                      ' VLRA04M01,  VLRA04M02,  VLRA04M03,  VLRA04M04,  VLRA04M05,  VLRA04M06,  VLRA04M07,  VLRA04M08,  VLRA04M09,  VLRA04M10,  VLRA04M11,  VLRA04M12, '+
                                      ' VLRA05M01,  VLRA05M02,  VLRA05M03,  VLRA05M04,  VLRA05M05,  VLRA05M06,  VLRA05M07,  VLRA05M08,  VLRA05M09,  VLRA05M10,  VLRA05M11,  VLRA05M12, '+
                                      ' VLRA06M01,  VLRA06M02,  VLRA06M03,  VLRA06M04,  VLRA06M05,  VLRA06M06,  VLRA06M07,  VLRA06M08,  VLRA06M09,  VLRA06M10,  VLRA06M11,  VLRA06M12, '+
                                      ' VLRA07M01,  VLRA07M02,  VLRA07M03,  VLRA07M04,  VLRA07M05,  VLRA07M06,  VLRA07M07,  VLRA07M08,  VLRA07M09,  VLRA07M10,  VLRA07M11,  VLRA07M12, '+
                                      ' VLRA99M12) '+
                                      '              VALUES (:USUARIO, :EMPRE, :TPLANCTO, :CONTADES, :DESPRECE, '+
                                      ':VLRA00M01, '+
                                      ':VLRA01M01, :VLRA01M02, :VLRA01M03, :VLRA01M04, :VLRA01M05, :VLRA01M06, :VLRA01M07, :VLRA01M08, :VLRA01M09, :VLRA01M10, :VLRA01M11, :VLRA01M12, '+
                                      ':VLRA02M01, :VLRA02M02, :VLRA02M03, :VLRA02M04, :VLRA02M05, :VLRA02M06, :VLRA02M07, :VLRA02M08, :VLRA02M09, :VLRA02M10, :VLRA02M11, :VLRA02M12, '+
                                      ':VLRA03M01, :VLRA03M02, :VLRA03M03, :VLRA03M04, :VLRA03M05, :VLRA03M06, :VLRA03M07, :VLRA03M08, :VLRA03M09, :VLRA03M10, :VLRA03M11, :VLRA03M12, '+
                                      ':VLRA04M01, :VLRA04M02, :VLRA04M03, :VLRA04M04, :VLRA04M05, :VLRA04M06, :VLRA04M07, :VLRA04M08, :VLRA04M09, :VLRA04M10, :VLRA04M11, :VLRA04M12, '+
                                      ':VLRA05M01, :VLRA05M02, :VLRA05M03, :VLRA05M04, :VLRA05M05, :VLRA05M06, :VLRA05M07, :VLRA05M08, :VLRA05M09, :VLRA05M10, :VLRA05M11, :VLRA05M12, '+
                                      ':VLRA06M01, :VLRA06M02, :VLRA06M03, :VLRA06M04, :VLRA06M05, :VLRA06M06, :VLRA06M07, :VLRA06M08, :VLRA06M09, :VLRA06M10, :VLRA06M11, :VLRA06M12, '+
                                      ':VLRA07M01, :VLRA07M02, :VLRA07M03, :VLRA07M04, :VLRA07M05, :VLRA07M06, :VLRA07M07, :VLRA07M08, :VLRA07M09, :VLRA07M10, :VLRA07M11, :VLRA07M12, '+
                                      ':VLRA99M12) ');
    wQueryGra.ParamByName('USUARIO').AsInteger    := fDataM.Usuario;
    wQueryGra.ParamByName('EMPRE').AsInteger      := fDataM.Empresa;
    wQueryGra.ParamByName('TPLANCTO').AsInteger   := 99;
    wQueryGra.ParamByName('CONTADES').AsString    := 'Diferença: Receitas - Despesas';
    wQueryGra.ParamByName('DESPRECE').AsString    := 'Diferença: Receitas - Despesas';

    wQueryGra.ParamByName('VLRA00M01').AsCurrency := wArrTot99[000];

    wQueryGra.ParamByName('VLRA01M01').AsCurrency := wArrTot99[001];
    wQueryGra.ParamByName('VLRA01M02').AsCurrency := wArrTot99[002];
    wQueryGra.ParamByName('VLRA01M03').AsCurrency := wArrTot99[003];
    wQueryGra.ParamByName('VLRA01M04').AsCurrency := wArrTot99[004];
    wQueryGra.ParamByName('VLRA01M05').AsCurrency := wArrTot99[005];
    wQueryGra.ParamByName('VLRA01M06').AsCurrency := wArrTot99[006];
    wQueryGra.ParamByName('VLRA01M07').AsCurrency := wArrTot99[007];
    wQueryGra.ParamByName('VLRA01M08').AsCurrency := wArrTot99[008];
    wQueryGra.ParamByName('VLRA01M09').AsCurrency := wArrTot99[009];
    wQueryGra.ParamByName('VLRA01M10').AsCurrency := wArrTot99[010];
    wQueryGra.ParamByName('VLRA01M11').AsCurrency := wArrTot99[011];
    wQueryGra.ParamByName('VLRA01M12').AsCurrency := wArrTot99[012];

    wQueryGra.ParamByName('VLRA02M01').AsCurrency := wArrTot99[013];
    wQueryGra.ParamByName('VLRA02M02').AsCurrency := wArrTot99[014];
    wQueryGra.ParamByName('VLRA02M03').AsCurrency := wArrTot99[015];
    wQueryGra.ParamByName('VLRA02M04').AsCurrency := wArrTot99[016];
    wQueryGra.ParamByName('VLRA02M05').AsCurrency := wArrTot99[017];
    wQueryGra.ParamByName('VLRA02M06').AsCurrency := wArrTot99[018];
    wQueryGra.ParamByName('VLRA02M07').AsCurrency := wArrTot99[019];
    wQueryGra.ParamByName('VLRA02M08').AsCurrency := wArrTot99[020];
    wQueryGra.ParamByName('VLRA02M09').AsCurrency := wArrTot99[021];
    wQueryGra.ParamByName('VLRA02M10').AsCurrency := wArrTot99[022];
    wQueryGra.ParamByName('VLRA02M11').AsCurrency := wArrTot99[023];
    wQueryGra.ParamByName('VLRA02M12').AsCurrency := wArrTot99[024];

    wQueryGra.ParamByName('VLRA03M01').AsCurrency := wArrTot99[025];
    wQueryGra.ParamByName('VLRA03M02').AsCurrency := wArrTot99[026];
    wQueryGra.ParamByName('VLRA03M03').AsCurrency := wArrTot99[027];
    wQueryGra.ParamByName('VLRA03M04').AsCurrency := wArrTot99[028];
    wQueryGra.ParamByName('VLRA03M05').AsCurrency := wArrTot99[029];
    wQueryGra.ParamByName('VLRA03M06').AsCurrency := wArrTot99[030];
    wQueryGra.ParamByName('VLRA03M07').AsCurrency := wArrTot99[031];
    wQueryGra.ParamByName('VLRA03M08').AsCurrency := wArrTot99[032];
    wQueryGra.ParamByName('VLRA03M09').AsCurrency := wArrTot99[033];
    wQueryGra.ParamByName('VLRA03M10').AsCurrency := wArrTot99[034];
    wQueryGra.ParamByName('VLRA03M11').AsCurrency := wArrTot99[035];
    wQueryGra.ParamByName('VLRA03M12').AsCurrency := wArrTot99[036];

    wQueryGra.ParamByName('VLRA04M01').AsCurrency := wArrTot99[037];
    wQueryGra.ParamByName('VLRA04M02').AsCurrency := wArrTot99[038];
    wQueryGra.ParamByName('VLRA04M03').AsCurrency := wArrTot99[039];
    wQueryGra.ParamByName('VLRA04M04').AsCurrency := wArrTot99[040];
    wQueryGra.ParamByName('VLRA04M05').AsCurrency := wArrTot99[041];
    wQueryGra.ParamByName('VLRA04M06').AsCurrency := wArrTot99[042];
    wQueryGra.ParamByName('VLRA04M07').AsCurrency := wArrTot99[043];
    wQueryGra.ParamByName('VLRA04M08').AsCurrency := wArrTot99[044];
    wQueryGra.ParamByName('VLRA04M09').AsCurrency := wArrTot99[045];
    wQueryGra.ParamByName('VLRA04M10').AsCurrency := wArrTot99[046];
    wQueryGra.ParamByName('VLRA04M11').AsCurrency := wArrTot99[047];
    wQueryGra.ParamByName('VLRA04M12').AsCurrency := wArrTot99[048];

    wQueryGra.ParamByName('VLRA05M01').AsCurrency := wArrTot99[049];
    wQueryGra.ParamByName('VLRA05M02').AsCurrency := wArrTot99[050];
    wQueryGra.ParamByName('VLRA05M03').AsCurrency := wArrTot99[051];
    wQueryGra.ParamByName('VLRA05M04').AsCurrency := wArrTot99[052];
    wQueryGra.ParamByName('VLRA05M05').AsCurrency := wArrTot99[053];
    wQueryGra.ParamByName('VLRA05M06').AsCurrency := wArrTot99[054];
    wQueryGra.ParamByName('VLRA05M07').AsCurrency := wArrTot99[055];
    wQueryGra.ParamByName('VLRA05M08').AsCurrency := wArrTot99[056];
    wQueryGra.ParamByName('VLRA05M09').AsCurrency := wArrTot99[057];
    wQueryGra.ParamByName('VLRA05M10').AsCurrency := wArrTot99[058];
    wQueryGra.ParamByName('VLRA05M11').AsCurrency := wArrTot99[059];
    wQueryGra.ParamByName('VLRA05M12').AsCurrency := wArrTot99[060];

    wQueryGra.ParamByName('VLRA06M01').AsCurrency := wArrTot99[061];
    wQueryGra.ParamByName('VLRA06M02').AsCurrency := wArrTot99[062];
    wQueryGra.ParamByName('VLRA06M03').AsCurrency := wArrTot99[063];
    wQueryGra.ParamByName('VLRA06M04').AsCurrency := wArrTot99[064];
    wQueryGra.ParamByName('VLRA06M05').AsCurrency := wArrTot99[065];
    wQueryGra.ParamByName('VLRA06M06').AsCurrency := wArrTot99[066];
    wQueryGra.ParamByName('VLRA06M07').AsCurrency := wArrTot99[067];
    wQueryGra.ParamByName('VLRA06M08').AsCurrency := wArrTot99[068];
    wQueryGra.ParamByName('VLRA06M09').AsCurrency := wArrTot99[069];
    wQueryGra.ParamByName('VLRA06M10').AsCurrency := wArrTot99[070];
    wQueryGra.ParamByName('VLRA06M11').AsCurrency := wArrTot99[071];
    wQueryGra.ParamByName('VLRA06M12').AsCurrency := wArrTot99[072];

    wQueryGra.ParamByName('VLRA07M01').AsCurrency := wArrTot99[073];
    wQueryGra.ParamByName('VLRA07M02').AsCurrency := wArrTot99[074];
    wQueryGra.ParamByName('VLRA07M03').AsCurrency := wArrTot99[075];
    wQueryGra.ParamByName('VLRA07M04').AsCurrency := wArrTot99[076];
    wQueryGra.ParamByName('VLRA07M05').AsCurrency := wArrTot99[077];
    wQueryGra.ParamByName('VLRA07M06').AsCurrency := wArrTot99[078];
    wQueryGra.ParamByName('VLRA07M07').AsCurrency := wArrTot99[079];
    wQueryGra.ParamByName('VLRA07M08').AsCurrency := wArrTot99[080];
    wQueryGra.ParamByName('VLRA07M09').AsCurrency := wArrTot99[081];
    wQueryGra.ParamByName('VLRA07M10').AsCurrency := wArrTot99[082];
    wQueryGra.ParamByName('VLRA07M11').AsCurrency := wArrTot99[083];
    wQueryGra.ParamByName('VLRA07M12').AsCurrency := wArrTot99[084];

    wQueryGra.ParamByName('VLRA99M12').AsCurrency := wArrTot99[085];
    wQueryGra.ExecQuery;
    FIBQueryCommit(wQueryGra);
  end;

var
  wInd: Integer;
  wDia, wMes, wAno: Word;
  wCategoria: TCategoria;
  wDataHoje: TDateTime;
  wDispo: Currency;
begin
  wCategoria := TCategoria.Create;
  try
    wDataHoje := fDataM.fDataHoraServidor;
    wDispo := wCategoria.fSaldoCategoria(3, DateOf(wDataHoje));
  finally
    wCategoria.Free;
  end;

  FIBQueryCriar(wQueryLer, wTransLer);
  FIBQueryCriar(wQueryGra, wTransGra);
  FIBQueryCriar(wQueryAux, wTransAux);
  try
    try
      FIBQueryAtribuirSQL(wQueryGra, 'DELETE FROM TMPFLUXO '+
                                     'WHERE Empre = :Empre and Usuario = :Usuario');
      wQueryGra.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      wQueryGra.ParamByName('Usuario').AsInteger := fDataM.Usuario;
      wQueryGra.ExecQuery;
      FIBQueryCommit(wQueryGra);
      //
      FillChar(wArrDatas, SizeOf(wArrDatas), #0);
      FillChar(wArrValor, SizeOf(wArrValor), #0);
      FillChar(wArrTot10, SizeOf(wArrTot10), #0);
      FillChar(wArrTot20, SizeOf(wArrTot20), #0);
      FillChar(wArrTot99, SizeOf(wArrTot99), #0);
      //
      wDataIni := IncMonth(wDataHoje, -1);
      DecodeDate(wDataIni, wAno, wMes, wDia);
      wDia := 01;
      wDataIni := EncodeDate(wAno, wMes, wDia);
      for wInd := 0 to 85 do
      begin
        wArrDatas[wInd] := wDataIni;
        wDataIni := IncMonth(wDataIni);
      end;

      // Disponibilidades
      if ckDisponibilidades.Checked then
      begin
        pSetValor(01, wDataHoje, wDispo);
        pGravaTMP(00);
      end;

      // Receitas
      if ckReceitas.Checked then
      begin
        FIBQueryAtribuirSQL(wQueryLer, 'select D.ID, D.codigo, D.doctonro, D.dataemissao, D.CategoriaREC as CategoriaA, D.CategoriaENT as CategoriaB, '+
                                       'C.classificacao, C.descricao AS CatNome, D.descricao, D.parcelatipo, D.valorprincipal, D.Status '+
                                       'FROM ctarecdocto D '+
                                       'LEFT OUTER JOIN categoria   C ON (D.categoriaREC = C.codigo) AND (D.empre = C.empre) '+
                                       'WHERE (D.Empre = :Empre) and (D.Status between 1 and 6) '+
                                       'Order BY ID, Codigo, DoctoNro ');
        wQueryLer.ParamByName('Empre').AsInteger := fDataM.Empresa;
        wQueryLer.ExecQuery;
        while (not wQueryLer.Eof) do
        begin
          FillChar(wArrValor, SizeOf(wArrValor), #0);
          FIBQueryAtribuirSQL(wQueryAux, 'select P.doctoid, P.datavencto, P.cartaotip, P.cartaocod, P.moedaTIP, '+
                                         'case P.moedaTIP when 0 then '''' when 1 then ''Dinheiro'' when 2 then ''Cheque'' when 3 then ''Cartão de Crédito'' when 4 then ''Cartão de Débito'' when 5 then ''Depósito Bancário'' when 6 then ''Permuta'' when 7 then ''Outros'' end as MoedaDes, '+
                                         'P.valorparcela, P.valorpago, COALESCE(P.valorparcela,0) - COALESCE(P.valorpago,0) AS VlrSaldo '+
                                         'FROM ctarecparce P '+
                                         'WHERE (P.DoctoID = :ID) '+
                                         'Order BY DataVencto ');
          wQueryAux.ParamByName('ID').AsInteger := wQueryLer.FieldByName('ID').AsInteger;
          wQueryAux.ExecQuery;
          while (not wQueryAux.Eof) do
          begin
            pSetValor(10, wQueryAux.FieldByName('DataVencto').AsDateTime, wQueryAux.FieldByName('VlrSaldo').AsCurrency);
            wQueryAux.Next;
          end;
          pGravaTMP(10);
          wQueryLer.Next;
        end;
      end;

      // Despesas
      FIBQueryAtribuirSQL(wQueryLer, 'select D.ID, D.codigo, D.doctonro, D.dataemissao, D.CategoriaDES as CategoriaA, D.CategoriaSAI as CategoriaB, '+
                                     'C.classificacao, C.descricao AS CatNome, D.descricao, D.parcelatipo, D.valorprincipal, D.Status '+
                                     'FROM ctapagdocto D '+
                                     'LEFT OUTER JOIN categoria   C ON (D.categoriaDES = C.codigo) AND (D.empre = C.empre) '+
                                     'WHERE (D.Empre = :Empre) and (D.Status between 1 and 6) '+
                                     'Order BY ID, Codigo, DoctoNro ');
      wQueryLer.ParamByName('Empre').AsInteger := fDataM.Empresa;
      wQueryLer.ExecQuery;
      while (not wQueryLer.Eof) do
      begin
        FillChar(wArrValor, SizeOf(wArrValor), #0);
        FIBQueryAtribuirSQL(wQueryAux, 'select P.doctoid, P.datavencto, P.cartaotip, P.cartaocod, P.moedaTIP, '+
                                       'case P.moedaTIP when 0 then '''' when 1 then ''Dinheiro'' when 2 then ''Cheque'' when 3 then ''Cartão de Crédito'' when 4 then ''Cartão de Débito'' when 5 then ''Depósito Bancário'' when 6 then ''Permuta'' when 7 then ''Outros'' end as MoedaDes, '+
                                       'P.valorparcela, P.valorpago, COALESCE(P.valorparcela,0) - COALESCE(P.valorpago,0) AS VlrSaldo '+
                                       'FROM ctapagparce P '+
                                       'WHERE (P.DoctoID = :ID) '+
                                       'Order BY DataVencto ');
        wQueryAux.ParamByName('ID').AsInteger := wQueryLer.FieldByName('ID').AsInteger;
        wQueryAux.ExecQuery;
        while (not wQueryAux.Eof) do
        begin
          pSetValor(20, wQueryAux.FieldByName('DataVencto').AsDateTime, wQueryAux.FieldByName('VlrSaldo').AsCurrency);
          wQueryAux.Next;
        end;
        pGravaTMP(20);
        wQueryLer.Next;
      end;
      pSomaTMP;
      Result := True;
    except
      on e: exception do
        MessageDlg('Erro ao gerar o Fluxo de Caixa: ' + e.Message, mtWarning, [mbOK], 0);
    end;
  finally
    FIBQueryCommit(wQueryLer);
    FIBQueryCommit(wQueryGra);
    FIBQueryCommit(wQueryAux);

    FIBQueryDestruir(wQueryLer);
    FIBQueryDestruir(wQueryGra);
    FIBQueryDestruir(wQueryAux);
  end;
end;

procedure TfcConFluxoDeCaixa.FormCreate(Sender: TObject);
begin
  inherited;
  FIBQueryCriar(wQueryGER, wTransGER);
end;

procedure TfcConFluxoDeCaixa.FormDestroy(Sender: TObject);
begin
  inherited;
  FIBQueryDestruir(wQueryGER);
end;

// TPLANCTO: 00-Disponibilidades || 10-Receitas || 19-SubTotal Receitas || 20-Despesas || 29-SubTotal Despesas || 9999-Total Geral
procedure TfcConFluxoDeCaixa.DBGridFluxoDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  inherited;
  case DBGridFluxo.DataSource.DataSet.FieldByName('TPLANCTO').AsInteger of
  00..09: begin // Disponibilidades
            if (gdSelected in State) then
            begin
              DBGridFluxo.Canvas.Brush.Color := CorGradeFundoRealceSele;
              DBGridFluxo.Canvas.Font.Color  := CorGradeFonteRealceSele;
            end
            else
            begin
              DBGridFluxo.Canvas.Brush.Color := CorGradeFundoNormal;
              DBGridFluxo.Canvas.Font.Color  := CorGradeFonteNormal;
            end;
          end;
  10..19: begin //Receitas
          if (gdSelected in State) then
          begin
            DBGridFluxo.Canvas.Brush.Color := clActiveCaption;
            DBGridFluxo.Canvas.Font.Color  := clWhite;
          end
          else
          begin
            DBGridFluxo.Canvas.Brush.Color := clYellow;
            DBGridFluxo.Canvas.Font.Color  := clBlue;
          end;
        end;
  20..29: begin //Receitas
          if (gdSelected in State) then
          begin
            DBGridFluxo.Canvas.Brush.Color := clActiveCaption;
            DBGridFluxo.Canvas.Font.Color  := clWhite;
          end
          else
          begin
            DBGridFluxo.Canvas.Brush.Color := clYellow;
            DBGridFluxo.Canvas.Font.Color  := clBlue;
          end;
        end;
  end;

  DBGridFluxo.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

end.
