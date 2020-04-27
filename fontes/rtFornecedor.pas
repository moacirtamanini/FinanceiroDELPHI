unit rtFornecedor;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, Graphics,
  rtTypes;

type
  TTipForCli = packed record
    Tipo       : Integer;
    Codi       : Integer;
  end;

  TDadosFor = packed record
    id         : Integer;
    Empre      : Integer;
    Codigo     : Integer;
    CPFNPJ     : String;
    Nome       : String;
    Apelido    : String;
    Status     : Integer;
    MoedaTIP   : Integer;
    CartaoTIP  : Integer;
    CartaoCOD  : Integer;
    Endereco   : Integer;
    Fone       : Integer;
  end;

  TFornecedor = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosFor: TDadosFor;
    function  getCodigo: Integer;
    procedure setCodigo(const Value: Integer);
    procedure setFornec(const Value: String);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravar: Integer;
    function    fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
    function    fExcluir(var prErro: String): Boolean;
    function    fPodeExcluir(prCodigo: Integer; prInterativo: Boolean; var prErro: String): Boolean;

    property ppDados: TDadosFor read fDadosFor write fDadosFor;
    property ppCodigo: Integer read getCodigo  write setCodigo;
    property ppBuscar: String  write setFornec;
end;

implementation

uses uDataM, FIBQuery, uUtils;

constructor TFornecedor.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TFornecedor.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TFornecedor.Clear;
begin
  FillChar(fDadosFor, SizeOf(fDadosFor), #0);
end;

function TFornecedor.getCodigo: Integer;
begin
  Result := fDadosFor.Codigo;
end;

procedure TFornecedor.setCodigo(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Fornecedor '+
                                'WHERE Empre = :Empre and Codigo = :Codigo');
    fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
    fQuery.ParamByName('Codigo').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosFor.id          := fQuery.FieldByName('id').AsInteger;
      fDadosFor.Empre       := fQuery.FieldByName('Empre').AsInteger;
      fDadosFor.Codigo      := fQuery.FieldByName('Codigo').AsInteger;
      fDadosFor.CPFNPJ      := fSomenteNumeros(fQuery.FieldByName('CPFCNPJ').AsString);
      fDadosFor.Nome        := fQuery.FieldByName('NOME').AsString;
      fDadosFor.Apelido     := fQuery.FieldByName('APELIDO').AsString;
      fDadosFor.Status      := fQuery.FieldByName('Status').AsInteger;
      fDadosFor.MoedaTIP    := fQuery.FieldByName('MoedaTIP').AsInteger;
      fDadosFor.CartaoTIP   := fQuery.FieldByName('CartaoTIP').AsInteger;
      fDadosFor.CartaoCOD   := fQuery.FieldByName('CartaoCOD').AsInteger;
      fDadosFor.Endereco    := fQuery.FieldByName('Endereco').AsInteger;
      fDadosFor.Fone        := fQuery.FieldByName('Fone').AsInteger;
    end;
  end;
end;

procedure TFornecedor.setFornec(const Value: String);
var
  wCod: Integer;
begin
  Clear;
  wCod := StrToIntDef(Trim(Value), 0);

  if (wCod > 0) then
    setCodigo(wCod)
  else
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Fornecedor '+
                                'WHERE Empre = :Empre and Nome = :Nome');
    fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
    fQuery.ParamByName('Nome').AsString    := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosFor.id          := fQuery.FieldByName('id').AsInteger;
      fDadosFor.Empre       := fQuery.FieldByName('Empre').AsInteger;
      fDadosFor.Codigo      := fQuery.FieldByName('Codigo').AsInteger;
      fDadosFor.CPFNPJ      := fSomenteNumeros(fQuery.FieldByName('CPFCNPJ').AsString);
      fDadosFor.Nome        := fQuery.FieldByName('NOME').AsString;
      fDadosFor.Apelido     := fQuery.FieldByName('APELIDO').AsString;
      fDadosFor.Status      := fQuery.FieldByName('Status').AsInteger;
      fDadosFor.MoedaTIP    := fQuery.FieldByName('MoedaTIP').AsInteger;
      fDadosFor.CartaoTIP   := fQuery.FieldByName('CartaoTIP').AsInteger;
      fDadosFor.CartaoCOD   := fQuery.FieldByName('CartaoCOD').AsInteger;
      fDadosFor.Endereco    := fQuery.FieldByName('Endereco').AsInteger;
      fDadosFor.Fone        := fQuery.FieldByName('Fone').AsInteger;
    end
    else
    begin
      FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Fornecedor '+
                                  'WHERE Empre = :Empre and Apelido = :Apelido');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Apelido').AsString := Value;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        fDadosFor.id          := fQuery.FieldByName('id').AsInteger;
        fDadosFor.Empre       := fQuery.FieldByName('Empre').AsInteger;
        fDadosFor.Codigo      := fQuery.FieldByName('Codigo').AsInteger;
        fDadosFor.CPFNPJ      := fSomenteNumeros(fQuery.FieldByName('CPFCNPJ').AsString);
        fDadosFor.Nome        := fQuery.FieldByName('NOME').AsString;
        fDadosFor.Apelido     := fQuery.FieldByName('APELIDO').AsString;
        fDadosFor.Status      := fQuery.FieldByName('Status').AsInteger;
        fDadosFor.MoedaTIP    := fQuery.FieldByName('MoedaTIP').AsInteger;
        fDadosFor.CartaoTIP   := fQuery.FieldByName('CartaoTIP').AsInteger;
        fDadosFor.CartaoCOD   := fQuery.FieldByName('CartaoCOD').AsInteger;
        fDadosFor.Endereco    := fQuery.FieldByName('Endereco').AsInteger;
        fDadosFor.Fone        := fQuery.FieldByName('Fone').AsInteger;
      end;
    end;
  end;
end;

function TFornecedor.fGravar: Integer;

  function fGeraCodigo: Integer;
  var
    wQueryLoc: TpFIBQuery;
    wTransLoc: TpFIBTransaction;
  begin
    FIBQueryCriar(wQueryLoc, wTransLoc);
    try
      FIBQueryAtribuirSQL(wQueryLoc, 'SELECT coalesce(max(Codigo),0)+1 from Fornecedor where '+
                                     '  Empre = :Empre');
      wQueryLoc.ParamByName('Empre').AsInteger := fDataM.Empresa;
      wQueryLoc.ExecQuery;
      Result := wQueryLoc.Fields[0].AsInteger;
    finally
      FIBQueryDestruir(wQueryLoc);
    end;
  end;

var
  wExiste: Boolean;
begin
  wExiste:= False;

  try
    try
      if (fDadosFor.Codigo > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Fornecedor '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre');
        fQuery.ParamByName('Codigo').AsInteger  := fDadosFor.Codigo;
        fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof);
        fDadosFor.id := fQuery.FieldByName('id').AsInteger;
      end;

      if (fDadosFor.Codigo > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Fornecedor '+
                                    'SET CPFCNPJ     = :CPFCNPJ, '+
                                    '    NOME        = :NOME, '+
                                    '    APELIDO     = :APELIDO, '+
                                    '    Status      = :Status, '+
                                    '    MoedaTIP    = :MoedaTIP, '+
                                    '    CartaoTIP   = :CartaoTIP, '+
                                    '    CartaoCOD   = :CartaoCOD, '+
                                    '    Endereco    = :Endereco, '+
                                    '    Fone        = :Fone '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre')
      else
      begin
        if (not wExiste) and ((fDadosFor.Codigo = 0) or (fDadosFor.Codigo > fGetMax('Fornecedor','Codigo',True))) then
          fDadosFor.Codigo := fGeraCodigo;
        if (not wExiste) then
          fDadosFor.id := fGetGenerator('GEN_FORNECEDOR');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Fornecedor ( id,  Empre,  Codigo,  CPFCNPJ,  NOME,  APELIDO,  Status,  MoedaTIP,  CartaoTIP,  CartaoCOD,  Endereco,  Fone) '+
                                    '                VALUES (:ID, :Empre, :Codigo, :CPFCNPJ, :NOME, :APELIDO, :Status, :MoedaTIP, :CartaoTIP, :CartaoCOD, :Endereco, :Fone) ');
        fQuery.ParamByName('id').AsInteger         := fDadosFor.id;
      end;
      //
      fQuery.ParamByName('Empre').AsInteger        := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger       := fDadosFor.Codigo;
      fQuery.ParamByName('CPFCNPJ').AsString       := fSomenteNumeros(fDadosFor.CPFNPJ);
      fQuery.ParamByName('NOME').AsString          := fDadosFor.Nome;
      fQuery.ParamByName('APELIDO').AsString       := fDadosFor.Apelido;
      fQuery.ParamByName('APELIDO').AsString       := fDadosFor.Apelido;
      fQuery.ParamByName('Status').AsInteger       := fDadosFor.Status;
      fQuery.ParamByName('MoedaTIP').AsInteger     := fDadosFor.MoedaTIP;
      fQuery.ParamByName('CartaoTIP').AsInteger    := fDadosFor.CartaoTIP;
      fQuery.ParamByName('CartaoCOD').AsInteger    := fDadosFor.CartaoCOD;
      fQuery.ParamByName('Endereco').AsInteger     := fDadosFor.Endereco;
      fQuery.ParamByName('Fone').AsInteger         := fDadosFor.Fone;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosFor.id := 0;
        MessageDlg('Erro ao gravar o Fornecedor!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosFor.id;
  end;
end;

function TFornecedor.fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para o Fornecedor!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Fornecedor WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := ppDados.Codigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Fornecedor '+IntToStr(ppDados.Codigo)+' não foi encontrado.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Fornecedor SET Status = :Status WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := ppDados.Codigo;
      fQuery.ParamByName('Status').AsInteger := prStatus;
      fQuery.ExecQuery;

      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao alterar o status do Fornecedor '+IntToStr(ppDados.Codigo)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TFornecedor.fExcluir(var prErro: String): Boolean;
var
  wRotina: Integer;
  wErro: String;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (not fPodeExcluir(ppDados.id, True, wErro)) then Exit;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Fone WHERE Id = :Id');
      fQuery.ParamByName('Id').AsInteger := fDadosFor.Fone;
      fQuery.ExecQuery;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Endereco WHERE Id = :Id');
      fQuery.ParamByName('Id').AsInteger := fDadosFor.Endereco;
      fQuery.ExecQuery;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Fornecedor WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := ppDados.Codigo;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        prErro := 'Erro ao excluir o Fornecedor '+IntToStr(ppDados.Codigo)+eol+'Rotina: '+IntToStr(wRotina)+eol+e.Message;
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TFornecedor.fPodeExcluir(prCodigo: Integer; prInterativo: Boolean; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prCodigo < 1) then Exit;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Fornecedor WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := prCodigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Fornecedor '+IntToStr(prCodigo)+' não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Lancamento WHERE CliForTIP = 0 AND CliForCOD = :CliForCOD');
      fQuery.ParamByName('CliForCOD').AsInteger := prCodigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'O Fornecedor '+IntToStr(prCodigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' lançamentos.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CtaPagDocto WHERE EmitenteTIP = 0 AND EmitenteCOD = :EmitenteCOD');
      fQuery.ParamByName('EmitenteCOD').AsInteger := prCodigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'O Fornecedor '+IntToStr(prCodigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' faturas A PAGAR.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CtaRecDocto WHERE EmitenteTIP = 0 AND EmitenteCOD = :EmitenteCOD');
      fQuery.ParamByName('EmitenteCOD').AsInteger := prCodigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'O Fornecedor '+IntToStr(prCodigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' faturas A RECEBER.';
        Exit
      end;

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        prErro := prErro + eol + 'Erro ao verificar se pode excluir o Fornecedor '+IntToStr(prCodigo)+eol+'Rotina: '+IntToStr(wRotina)+eol+e.Message;
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
