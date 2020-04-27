unit rtEndereco;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, rtTypes;

type
  TDadosEnd = packed record
    id         : Integer;
    CEP        : String;
    UF         : String;
    Cidade     : String;
    Logradouro : String;
    Numero     : String;
    Bairro     : String;
    Complemento: String;
    Email      : String;
    Site       : String;
  end;

  TEndereco = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosEnd: TDadosEnd;
    function  getID: Integer;
    procedure setID(const Value: Integer);
    procedure SetDadosEnd(const Value: TDadosEnd);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravaEndereco: Integer;
    function    fSetStatusEndereco(const prStatus: Integer; var prErro: String): Boolean;
    function    fExcluirEndereco(var prErro: String): Boolean;

    property ppDados: TDadosEnd read fDadosEnd write SetDadosEnd;
    property ppID: Integer read getID write setID;
end;

implementation

uses uDataM, FIBQuery;

constructor TEndereco.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TEndereco.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TEndereco.Clear;
begin
  FillChar(fDadosEnd, SizeOf(fDadosEnd), #0);
end;

function TEndereco.getID: Integer;
begin
  Result := fDadosEnd.id;
end;

procedure TEndereco.setID(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Endereco '+
                                'WHERE id = :id');
    fQuery.ParamByName('id').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosEnd.id          := fQuery.FieldByName('id').AsInteger;
      fDadosEnd.CEP         := fQuery.FieldByName('CEP').AsString;
      fDadosEnd.UF          := fQuery.FieldByName('UF').AsString;
      fDadosEnd.Cidade      := fQuery.FieldByName('Cidade').AsString;
      fDadosEnd.Logradouro  := fQuery.FieldByName('Logradouro').AsString;
      fDadosEnd.Numero      := fQuery.FieldByName('Numero').AsString;
      fDadosEnd.Bairro      := fQuery.FieldByName('Bairro').AsString;
      fDadosEnd.Complemento := fQuery.FieldByName('Complemento').AsString;
      fDadosEnd.Email       := fQuery.FieldByName('Email').AsString;
      fDadosEnd.Site        := fQuery.FieldByName('Site').AsString;
    end;
  end;
end;

function TEndereco.fGravaEndereco: Integer;
var
  wExiste: Boolean;
begin
  wExiste := False;

  try
    try
      if (fDadosEnd.id > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Endereco '+
                                    'WHERE id = :id');
        fQuery.ParamByName('id').AsInteger := fDadosEnd.id;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof) and (fDadosEnd.id <= fGetGenerator('GEN_ENDERECO', 0));
      end;

      if (fDadosEnd.id > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Endereco '+
                                    'SET      CEP = :CEP, '+
                                    '         UF  = :UF, '+
                                    '      CIDADE = :CIDADE, '+
                                    '  LOGRADOURO = :LOGRADOURO, ' +
                                    '      NUMERO = :NUMERO, '+
                                    '      BAIRRO = :BAIRRO, '+
                                    ' COMPLEMENTO = :COMPLEMENTO, '+
                                    '       EMAIL = :EMAIL, '+
                                    '        SITE = :SITE '+
                                    'WHERE id = :id')
      else
      begin
        if (not wExiste) then
          fDadosEnd.id := fGetGenerator('GEN_ENDERECO');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Endereco ( id,  CEP,  UF,  CIDADE,  LOGRADOURO,  NUMERO,  BAIRRO,  COMPLEMENTO,  EMAIL,  SITE) '+
                                    '              VALUES (:ID, :CEP, :UF, :CIDADE, :LOGRADOURO, :NUMERO, :BAIRRO, :COMPLEMENTO, :EMAIL, :SITE) ');
      end;
      //
      fQuery.ParamByName('id').AsInteger         := fDadosEnd.id;
      fQuery.ParamByName('CEP').AsString         := fDadosEnd.CEP;
      fQuery.ParamByName('UF').AsString          := fDadosEnd.UF;
      fQuery.ParamByName('CIDADE').AsString      := fDadosEnd.Cidade;
      fQuery.ParamByName('Logradouro').AsString  := fDadosEnd.Logradouro;
      fQuery.ParamByName('Numero').AsString      := fDadosEnd.Numero;
      fQuery.ParamByName('Bairro').AsString      := fDadosEnd.Bairro;
      fQuery.ParamByName('Complemento').AsString := fDadosEnd.Complemento;
      fQuery.ParamByName('Email').AsString       := fDadosEnd.Email;
      fQuery.ParamByName('Site').AsString        := fDadosEnd.Site;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosEnd.id := 0;
        MessageDlg('Erro ao gravar o Endereço!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosEnd.id;
  end;
end;

function TEndereco.fSetStatusEndereco(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para o Endereço!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Endereco WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O endereço '+IntToStr(ppID)+' não foi encontrado.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Endereco SET Status = :Status WHERE id = :id');
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
        MessageDlg('Erro ao alterar o status do Endereço '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TEndereco.fExcluirEndereco(var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  wRotina := 0;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Endereco WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O endereço '+IntToStr(ppID)+' não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT id, CPFCNPJ, NOME FROM Empresa WHERE endereco_id = :endereco_id');
      fQuery.ParamByName('endereco_id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        prErro := 'O endereço '+IntToStr(ppID)+' não pode ser excluído.'+Eol+
                  'Está sendo usado na Empresa: '+fQuery.FieldByName('id').AsString+' - '+fQuery.FieldByName('CPFCNPJ').AsString+' - '+fQuery.FieldByName('NOME').AsString;
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT id, CPFCNPJ, NOME FROM Usuario WHERE endereco_id = :endereco_id');
      fQuery.ParamByName('endereco_id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        prErro := 'O endereço '+IntToStr(ppID)+' não pode ser excluído.'+Eol+
                  'Está sendo usado no Usuário: '+fQuery.FieldByName('id').AsString+' - '+fQuery.FieldByName('CPFCNPJ').AsString+' - '+fQuery.FieldByName('NOME').AsString;
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT id, CPFCNPJ, NOME FROM Cliente WHERE endereco_id = :endereco_id');
      fQuery.ParamByName('endereco_id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        prErro := 'O endereço '+IntToStr(ppID)+' não pode ser excluído.'+Eol+
                  'Está sendo usado no Cliente: '+fQuery.FieldByName('id').AsString+' - '+fQuery.FieldByName('CPFCNPJ').AsString+' - '+fQuery.FieldByName('NOME').AsString;
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT id, CPFCNPJ, NOME FROM Fornecedor WHERE endereco_id = :endereco_id');
      fQuery.ParamByName('endereco_id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        prErro := 'O endereço '+IntToStr(ppID)+' não pode ser excluído.'+Eol+
                  'Está sendo usado no Fornecedor: '+fQuery.FieldByName('id').AsString+' - '+fQuery.FieldByName('CPFCNPJ').AsString+' - '+fQuery.FieldByName('NOME').AsString;
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Endereco WHERE Id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao excluir o Endereço '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

procedure TEndereco.SetDadosEnd(const Value: TDadosEnd);
begin
  fDadosEnd := Value;
end;

end.
