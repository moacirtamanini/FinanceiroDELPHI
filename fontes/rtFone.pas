unit rtFone;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, rtTypes;

type
  TDadosFon = packed record
    id         : Integer;
    FoneCenDDD : String;
    FoneCenNRO : String;
    FoneComDDD : String;
    FoneComNRO : String;
    FoneCelDDD : String;
    FoneCelNRO : String;
    FoneFaxDDD : String;
    FoneFaxNRO : String;
  end;
//  PDadosFon = ^TDadosFon;

  TFone = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosFon: TDadosFon;
    function  getID: Integer;
    procedure setID(const Value: Integer);
    procedure setDadosFon(const Value: TDadosFon);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravaFone: Integer;
    function    fSetStatusFone(const prStatus: Integer; var prErro: String): Boolean;
    function    fExcluirFone(var prErro: String): Boolean;

    property ppDados: TDadosFon read fDadosFon write setDadosFon;
    property ppID: Integer read getID write setID;
end;

implementation

uses uDataM, FIBQuery;

constructor TFone.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TFone.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TFone.Clear;
begin
  FillChar(fDadosFon, SizeOf(fDadosFon), #0);
end;

function TFone.getID: Integer;
begin
  Result := fDadosFon.id;
end;

procedure TFone.setID(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Fone '+
                                'WHERE id = :id');
    fQuery.ParamByName('id').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosFon.id          := fQuery.FieldByName('id').AsInteger;
      fDadosFon.FoneCenDDD  := fQuery.FieldByName('FoneCenDDD').AsString;
      fDadosFon.FoneCenNRO  := fQuery.FieldByName('FoneCenNRO').AsString;
      fDadosFon.FoneComDDD  := fQuery.FieldByName('FoneComDDD').AsString;
      fDadosFon.FoneComNRO  := fQuery.FieldByName('FoneComNRO').AsString;
      fDadosFon.FoneCelDDD  := fQuery.FieldByName('FoneCelDDD').AsString;
      fDadosFon.FoneCelNRO  := fQuery.FieldByName('FoneCelNRO').AsString;
      fDadosFon.FoneFaxDDD  := fQuery.FieldByName('FoneFaxDDD').AsString;
      fDadosFon.FoneFaxNRO  := fQuery.FieldByName('FoneFaxNRO').AsString;
    end;
  end;
end;

function TFone.fGravaFone: Integer;
var
  wExiste: Boolean;
begin
  wExiste:= False;
  try
    try
      if (fDadosFon.id > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Fone '+
                                    'WHERE id = :id');
        fQuery.ParamByName('id').AsInteger := fDadosFon.id;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof) and (fDadosFon.id <= fGetGenerator('GEN_FONE', 0));
      end;

      if (fDadosFon.id > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Fone '+
                                    'SET FoneCenDDD = :FoneCenDDD, '+
                                    '    FoneCenNRO = :FoneCenNRO, '+
                                    '    FoneComDDD = :FoneComDDD, '+
                                    '    FoneComNRO = :FoneComNRO, '+
                                    '    FoneCelDDD = :FoneCelDDD, '+
                                    '    FoneCelNRO = :FoneCelNRO, '+
                                    '    FoneFaxDDD = :FoneFaxDDD, '+
                                    '    FoneFaxNRO = :FoneFaxNRO '+
                                    'WHERE id = :id')
      else
      begin
        if (not wExiste) then
          fDadosFon.id := fGetGenerator('GEN_FONE');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Fone ( id,  FoneCenDDD,  FoneCenNRO,  FoneComDDD,  FoneComNRO,  FoneCelDDD,  FoneCelNRO,  FoneFaxDDD,  FoneFaxNRO) '+
                                    '          VALUES (:ID, :FoneCenDDD, :FoneCenNRO, :FoneComDDD, :FoneComNRO, :FoneCelDDD, :FoneCelNRO, :FoneFaxDDD, :FoneFaxNRO) ');
      end;
      //
      fQuery.ParamByName('id').AsInteger         := fDadosFon.id;
      fQuery.ParamByName('FoneCenDDD').AsString  := fDadosFon.FoneCenDDD;
      fQuery.ParamByName('FoneCenNRO').AsString  := fDadosFon.FoneCenNRO;
      fQuery.ParamByName('FoneComDDD').AsString  := fDadosFon.FoneComDDD;
      fQuery.ParamByName('FoneComNRO').AsString  := fDadosFon.FoneComNRO;
      fQuery.ParamByName('FoneCelDDD').AsString  := fDadosFon.FoneCelDDD;
      fQuery.ParamByName('FoneCelNRO').AsString  := fDadosFon.FoneCelNRO;
      fQuery.ParamByName('FoneFaxDDD').AsString  := fDadosFon.FoneFaxDDD;
      fQuery.ParamByName('FoneFaxNRO').AsString  := fDadosFon.FoneFaxNRO;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosFon.id := 0;
        MessageDlg('Erro ao gravar o Fone!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosFon.id;
  end;
end;

function TFone.fSetStatusFone(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para o Fone!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Fone WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O fone '+IntToStr(ppID)+' não foi encontrado.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Fone SET Status = :Status WHERE id = :id');
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
        MessageDlg('Erro ao alterar o status do Fone '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TFone.fExcluirFone(var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  wRotina := 0;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Fone WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O fone '+IntToStr(ppID)+' não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT id, CPFCNPJ, NOME FROM Empresa WHERE fone_id = :fone_id');
      fQuery.ParamByName('fone_id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        prErro := 'O fone '+IntToStr(ppID)+' não pode ser excluído.'+Eol+
                  'Está sendo usado na Empresa: '+fQuery.FieldByName('id').AsString+' - '+fQuery.FieldByName('CPFCNPJ').AsString+' - '+fQuery.FieldByName('NOME').AsString;
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT id, CPFCNPJ, NOME FROM Usuario WHERE fone_id = :fone_id');
      fQuery.ParamByName('fone_id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        prErro := 'O fone '+IntToStr(ppID)+' não pode ser excluído.'+Eol+
                  'Está sendo usado no Usuário: '+fQuery.FieldByName('id').AsString+' - '+fQuery.FieldByName('CPFCNPJ').AsString+' - '+fQuery.FieldByName('NOME').AsString;
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT id, CPFCNPJ, NOME FROM Cliente WHERE fone_id = :fone_id');
      fQuery.ParamByName('fone_id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        prErro := 'O fone '+IntToStr(ppID)+' não pode ser excluído.'+Eol+
                  'Está sendo usado no Cliente: '+fQuery.FieldByName('id').AsString+' - '+fQuery.FieldByName('CPFCNPJ').AsString+' - '+fQuery.FieldByName('NOME').AsString;
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT id, CPFCNPJ, NOME FROM Fornecedor WHERE fone_id = :fone_id');
      fQuery.ParamByName('fone_id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        prErro := 'O fone '+IntToStr(ppID)+' não pode ser excluído.'+Eol+
                  'Está sendo usado no Fornecedor: '+fQuery.FieldByName('id').AsString+' - '+fQuery.FieldByName('CPFCNPJ').AsString+' - '+fQuery.FieldByName('NOME').AsString;
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Fone WHERE Id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao excluir o Fone '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

procedure TFone.setDadosFon(const Value: TDadosFon);
begin
  fDadosFon := Value;
end;

end.
