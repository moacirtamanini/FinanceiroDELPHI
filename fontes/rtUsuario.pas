unit rtUsuario;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, Graphics,
  rtTypes;

type
  TDadosUsu = packed record
    id         : Integer;
    Empre      : Integer;
    CPFNPJ     : String;
    Nome       : String;
    Apelido    : String;
    Status     : Integer;
    Endereco   : Integer;
    Fone       : Integer;
  end;

  TUsuario = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosUsu: TDadosUsu;
    function  getID: Integer;
    procedure setID(const Value: Integer);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravaUsuario: Integer;
    function    fSetStatusUsuario(const prStatus: Integer; var prErro: String): Boolean;
    function    fExcluirUsuario(var prErro: String): Boolean;

    property ppDados: TDadosUsu read fDadosUsu write fDadosUsu;
    property ppID: Integer read getID write setID;
end;

implementation

uses uDataM, FIBQuery, uUtils;

constructor TUsuario.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TUsuario.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TUsuario.Clear;
begin
  FillChar(fDadosUsu, SizeOf(fDadosUsu), #0);
end;

function TUsuario.getID: Integer;
begin
  Result := fDadosUsu.id;
end;

procedure TUsuario.setID(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Usuario '+
                                'WHERE id = :id');
    fQuery.ParamByName('id').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosUsu.id          := fQuery.FieldByName('id').AsInteger;
      fDadosUsu.Empre       := fQuery.FieldByName('Empre').AsInteger;
      fDadosUsu.CPFNPJ      := fSomenteNumeros(fQuery.FieldByName('CPFCNPJ').AsString);
      fDadosUsu.Nome        := fQuery.FieldByName('NOME').AsString;
      fDadosUsu.Apelido     := fQuery.FieldByName('APELIDO').AsString;
      fDadosUsu.Status      := fQuery.FieldByName('Status').AsInteger;
      fDadosUsu.Endereco    := fQuery.FieldByName('Endereco').AsInteger;
      fDadosUsu.Fone        := fQuery.FieldByName('Fone').AsInteger;
    end;
  end;
end;

function TUsuario.fGravaUsuario: Integer;
var
  wExiste: Boolean;
begin
  wExiste:= False;

  try
    try
      if (fDadosUsu.id > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Usuario '+
                                    'WHERE id = :id');
        fQuery.ParamByName('id').AsInteger := fDadosUsu.id;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof) and (fDadosUsu.id <= fGetGenerator('GEN_USUARIO', 0));
      end;

      if (fDadosUsu.id > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Usuario '+
                                    'SET Empre       = :Empre, '+
                                    '    CPFCNPJ     = :CPFCNPJ, '+
                                    '    NOME        = :NOME, '+
                                    '    APELIDO     = :APELIDO, '+
                                    '    Status      = :Status, '+
                                    '    Endereco    = :Endereco, '+
                                    '    Fone        = :Fone '+
                                    'WHERE id = :id')
      else
      begin
        if (not wExiste) then
          fDadosUsu.id := fGetGenerator('GEN_USUARIO');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Usuario ( id,  Empre,  CPFCNPJ,  NOME,  APELIDO,  STATUS,  ENDERECO,  FONE) '+
                                    '             VALUES (:ID, :Empre, :CPFCNPJ, :NOME, :APELIDO, :STATUS, :ENDERECO, :FONE) ');
      end;
      //
      fQuery.ParamByName('id').AsInteger          := fDadosUsu.id;
      fQuery.ParamByName('Empre').AsInteger       := fDadosUsu.Empre;
      fQuery.ParamByName('CPFCNPJ').AsString      := fDadosUsu.CPFNPJ;
      fQuery.ParamByName('NOME').AsString         := fDadosUsu.Nome;
      fQuery.ParamByName('APELIDO').AsString      := fDadosUsu.Apelido;
      fQuery.ParamByName('STATUS').AsInteger      := fDadosUsu.Status;
      fQuery.ParamByName('ENDERECO').AsInteger    := fDadosUsu.Endereco;
      fQuery.ParamByName('FONE').AsInteger        := fDadosUsu.Fone;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosUsu.id := 0;
        MessageDlg('Erro ao gravar o Usuário!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosUsu.id;
  end;
end;

function TUsuario.fSetStatusUsuario(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para o Usuário!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Usuario WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Usuário '+IntToStr(ppID)+' não foi encontrado.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Usuario SET Status = :Status WHERE id = :id');
      fQuery.ParamByName('id').AsInteger      := ppID;
      fQuery.ParamByName('Status').AsInteger  := prStatus;
      fQuery.ExecQuery;

      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao alterar o status do Usuário '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TUsuario.fExcluirUsuario(var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;
  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Usuario WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Usuário '+IntToStr(ppID)+' não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Fones WHERE Fone = :Fone');
      fQuery.ParamByName('Fone').AsInteger := fDadosUsu.Fone;
      fQuery.ExecQuery;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Endereco WHERE Endereco = :Endereco');
      fQuery.ParamByName('Endereco').AsInteger := fDadosUsu.Endereco;
      fQuery.ExecQuery;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Usuario WHERE Id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao excluir o Usuário '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

end.
