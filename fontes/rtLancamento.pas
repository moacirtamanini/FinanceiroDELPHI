unit rtLancamento;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, Graphics,
  rtTypes;

type
  TDadosLan = packed record
    id           : Integer;
    Empre        : Integer;
    DataLancto   : TDateTime;
    CategoriaEnt : Integer;
    CategoriaSai : Integer;
    ValorLancto  : Currency;
    CliForTIP    : Integer;
    CliForCOD    : Integer;
    DoctoNro     : String;
    HistoCOD     : Integer;
    HistoDES     : String;
    Status       : Integer;
  end;

  TLancamento = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosLan: TDadosLan;
    function  getID: Integer;
    procedure setID(const Value: Integer);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravaLancto: Integer;
    function    fSetStatusLancto(const prStatus: Integer; var prErro: String): Boolean;
    function    fExcluirLancto(var prErro: String): Boolean;

    property ppDados: TDadosLan read fDadosLan write fDadosLan;
    property ppID: Integer read getID write setID;
end;

implementation

uses uDataM, FIBQuery, uUtils;

constructor TLancamento.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TLancamento.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TLancamento.Clear;
begin
  FillChar(fDadosLan, SizeOf(fDadosLan), #0);
end;

function TLancamento.getID: Integer;
begin
  Result := fDadosLan.id;
end;

procedure TLancamento.setID(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Lancamento '+
                                 'WHERE id = :id');
    fQuery.ParamByName('id').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosLan.id           := fQuery.FieldByName('id').AsInteger;
      fDadosLan.Empre        := fQuery.FieldByName('Empre').AsInteger;
      fDadosLan.DataLancto   := fQuery.FieldByName('DATALANCTO').AsDateTime;
      fDadosLan.CategoriaEnt := fQuery.FieldByName('CategoriaEnt').AsInteger;
      fDadosLan.CategoriaSai := fQuery.FieldByName('CategoriaSai').AsInteger;
      fDadosLan.ValorLancto  := fQuery.FieldByName('VALORLANCTO').AsCurrency;
      fDadosLan.CliForTIP    := fQuery.FieldByName('CliForTIP').AsInteger;
      fDadosLan.CliForCOD    := fQuery.FieldByName('CliForCOD').AsInteger;
      fDadosLan.DoctoNro     := fQuery.FieldByName('DOCTONRO').AsString;
      fDadosLan.HistoCOD     := fQuery.FieldByName('HISTOCOD').AsInteger;
      fDadosLan.HistoDES     := fQuery.FieldByName('HISTODES').AsString;
      fDadosLan.Status       := fQuery.FieldByName('Status').AsInteger;
    end;
  end;
end;

function TLancamento.fGravaLancto: Integer;
begin
  try
    try
      if (fDadosLan.id > 0) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Lancamento '+
                                    'SET Empre        = :Empre, '+
                                    '    bandeira_id  = :bandeira_id, '+
                                    '    DATALANCTO   = :DATALANCTO, '+
                                    '    CategoriaEnt = :CategoriaEnt, '+
                                    '    CategoriaSai = :CategoriaSai, '+
                                    '    VALORLANCTO  = :VALORLANCTO, '+
                                    '    CliForTIP    = :CliForTIP, '+
                                    '    CliForCOD    = :CliForCOD, '+
                                    '    DOCTONRO     = :DOCTONRO, '+
                                    '    HISTOCOD     = :HISTOCOD, ' +
                                    '    HISTODES     = :HISTODES, '+
                                    '    Status       = :Status '+
                                    'WHERE id = :id')
      else
      begin
        fDadosLan.id := fGetGenerator('GEN_LANCAMENTO');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Lancamento ( id,  Empre,  DATALANCTO,  CategoriaEnt,  CategoriaSai,  VALORLANCTO, '+
                                    '                         CliForTIP,  CliForCOD,  DOCTONRO,  HISTOCOD,  HISTODES,  Status) '+
                                    '                VALUES (:ID, :Empre, :DATALANCTO, :CategoriaEnt, :CategoriaSai, :VALORLANCTO, '+
                                    '                        :CliForTIP, :CliForCOD, :DOCTONRO, :HISTOCOD, :HISTODES, :Status) ');
      end;
      //
      fQuery.ParamByName('id').AsInteger           := fDadosLan.id;
      fQuery.ParamByName('Empre').AsInteger        := fDadosLan.Empre;
      fQuery.ParamByName('DATALANCTO').AsDateTime  := fDadosLan.DataLancto;
      fQuery.ParamByName('CategoriaEnt').AsInteger := fDadosLan.CategoriaEnt;
      fQuery.ParamByName('CategoriaSai').AsInteger := fDadosLan.CategoriaSai;
      fQuery.ParamByName('VALORLANCTO').AsCurrency := fDadosLan.ValorLancto;
      fQuery.ParamByName('CliForTIP').AsInteger    := fDadosLan.CliForTIP;
      fQuery.ParamByName('CliForCOD').AsInteger    := fDadosLan.CliForCOD;
      fQuery.ParamByName('DOCTONRO').AsString      := fDadosLan.DoctoNro;
      fQuery.ParamByName('HISTOCOD').AsInteger     := fDadosLan.HistoCOD;
      fQuery.ParamByName('HISTODES').AsString      := fDadosLan.HistoDES;
      fQuery.ParamByName('Status').AsInteger       := fDadosLan.Status;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosLan.id := 0;
        MessageDlg('Erro ao gravar o Lançamento!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosLan.id;
  end;
end;

function TLancamento.fSetStatusLancto(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para o Lançamento!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Lancamento WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Lançamento '+IntToStr(ppID)+' não foi encontrado.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Lancamento SET Status = :Status WHERE id = :id');
      fQuery.ParamByName('id').AsInteger     := ppID;
      fQuery.ParamByName('Status').AsInteger := prStatus;
      fQuery.ExecQuery;

      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao alterar o status do Lançamento '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TLancamento.fExcluirLancto(var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;
  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Lancamento WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Lançamento '+IntToStr(ppID)+' não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Lancamento WHERE Id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao excluir o Lançamento '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

end.
