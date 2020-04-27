unit rtBandeira;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, rtTypes;

type
  TDadosBan = packed record
    id         : Integer;
    Descricao  : String;
  end;

  TBandeira = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosBan: TDadosBan;
    function  getID: Integer;
    procedure setID(const Value: Integer);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravar: Integer;
    function    fExcluir(var prErro: String): Boolean;
    function    fPodeExcluir(ID: Integer; prInterativo: Boolean; var prErro: String): Boolean;
    property ppDados: TDadosBan read fDadosBan write fDadosBan;
    property ppID: Integer read getID write setID;
end;

implementation

uses uDataM, FIBQuery;

constructor TBandeira.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TBandeira.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TBandeira.Clear;
begin
  FillChar(fDadosBan, SizeOf(fDadosBan), #0);
end;

function TBandeira.getID: Integer;
begin
  Result := fDadosBan.id;
end;

procedure TBandeira.setID(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Bandeira '+
                                'WHERE id = :id');
    fQuery.ParamByName('id').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosBan.id        := fQuery.FieldByName('id').AsInteger;
      fDadosBan.Descricao := fQuery.FieldByName('Descricao').AsString;
    end;
  end;
end;

function TBandeira.fGravar: Integer;
var
  wExiste: Boolean;
begin
  Result := 0;
  wExiste:= False;

  if Length(Trim(fDadosBan.Descricao)) = 0 then
  begin
    MessageDlg('Informe o nome da bandeira!', mtWarning, [mbOK], 0);
    Exit;
  end;

  if (fDadosBan.id = 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Bandeira WHERE Descricao = :Descricao ');
    fQuery.ParamByName('Descricao').AsString      := fDadosBan.Descricao;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      MessageDlg('Já existe a bandeira '+IntToStr(fQuery.FieldByName('ID').AsInteger)+' com este nome!', mtWarning, [mbOK], 0);
      Exit;
    end;
  end;

  try
    try
      if (fDadosBan.id > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Bandeira '+
                                    'WHERE id = :id');
        fQuery.ParamByName('id').AsInteger := fDadosBan.id;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof);
      end;

      if (fDadosBan.id > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Bandeira '+
                                    'SET Descricao = :Descricao '+
                                    'WHERE id = :id')
      else
      begin
        if (not wExiste) and ((fDadosBan.id = 0) or (fDadosBan.id > fGetGenerator('GEN_BANDEIRA', 0))) then
          fDadosBan.id := fGetGenerator('GEN_BANDEIRA');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Bandeira ( id,  Descricao) '+
                                    '              VALUES (:ID, :Descricao) ');
      end;
      //
      fQuery.ParamByName('id').AsInteger         := fDadosBan.id;
      fQuery.ParamByName('Descricao').AsString   := fDadosBan.Descricao;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosBan.id := 0;
        MessageDlg('Erro ao gravar a Bandeira!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosBan.id;
  end;
end;

function TBandeira.fExcluir(var prErro: String): Boolean;
var
  wRotina: Integer;
  wErro: String;
begin
  Result  := False;
  wRotina := 0;
  prErro  := '';

  if (not fPodeExcluir(ppID, True, wErro)) then Exit;
  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Bandeira WHERE Id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        prErro := prErro + eol + 'Erro ao excluir a Bandeira '+IntToStr(ppID)+eol+'Rotina: '+IntToStr(wRotina)+eol+e.Message;
        MessageDlg(prErro, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TBandeira.fPodeExcluir(ID: Integer; prInterativo: Boolean; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (ID < 1) then Exit;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Bandeira WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'A bandeira '+IntToStr(ID)+' não foi encontrada para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) AS QTDE FROM CartaoDebito WHERE bandeira = :bandeira');
      fQuery.ParamByName('bandeira').AsInteger := ID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'A bandeira '+IntToStr(ID)+' não pode ser excluída.'+Eol+
                  'Está sendo usada em '+fQuery.FieldByName('QTDE').AsString+' Cartões de Débito';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) AS QTDE FROM CartaoCredito WHERE bandeira = :bandeira');
      fQuery.ParamByName('bandeira').AsInteger := ID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'A bandeira '+IntToStr(ID)+' não pode ser excluída.'+Eol+
                  'Está sendo usada em '+fQuery.FieldByName('QTDE').AsString+' Cartões de Crédito';
        Exit
      end;
      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        prErro := prErro + eol + 'Erro ao verificar se pode excluir a Bandeira '+IntToStr(ID)+eol+'Rotina: '+IntToStr(wRotina)+eol+e.Message;
        if prInterativo then
          MessageDlg(prErro, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    if (not Result) and (prInterativo) and (prErro <> '') then
      MessageDlg(prErro, mtWarning, [mbOk], 0);
  end;
end;

end.
