unit rtCliente;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, Graphics,
  rtTypes;

type
  TDadosCli = packed record
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

  TCliente = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosCli: TDadosCli;
    function  getCodigo: Integer;
    procedure setCodigo(const Value: Integer);
    procedure setCliente(const Value: String);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravar: Integer;
    function    fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
    function    fExcluir(var prErro: String): Boolean;
    function    fPodeExcluir(prCodigo: Integer; prInterativo: Boolean; var prErro: String): Boolean;

    property ppDados: TDadosCli read fDadosCli write fDadosCli;
    property ppCodigo: Integer read getCodigo write setCodigo;
    property ppBuscar: String  write setCliente;
end;

implementation

uses uDataM, FIBQuery, uUtils;

constructor TCliente.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TCliente.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TCliente.Clear;
begin
  FillChar(fDadosCli, SizeOf(fDadosCli), #0);
end;

function TCliente.getCodigo: Integer;
begin
  Result := fDadosCli.Codigo;
end;

procedure TCliente.setCodigo(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Cliente '+
                                'WHERE Empre = :Empre and Codigo = :Codigo');
    fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
    fQuery.ParamByName('Codigo').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosCli.id          := fQuery.FieldByName('id').AsInteger;
      fDadosCli.Empre       := fQuery.FieldByName('Empre').AsInteger;
      fDadosCli.Codigo      := fQuery.FieldByName('Codigo').AsInteger;
      fDadosCli.CPFNPJ      := fSomenteNumeros(fQuery.FieldByName('CPFCNPJ').AsString);
      fDadosCli.Nome        := fQuery.FieldByName('NOME').AsString;
      fDadosCli.Apelido     := fQuery.FieldByName('APELIDO').AsString;
      fDadosCli.Status      := fQuery.FieldByName('Status').AsInteger;
      fDadosCli.MoedaTIP    := fQuery.FieldByName('MoedaTIP').AsInteger;
      fDadosCli.CartaoTIP   := fQuery.FieldByName('CartaoTIP').AsInteger;
      fDadosCli.CartaoCOD   := fQuery.FieldByName('CartaoCOD').AsInteger;
      fDadosCli.Endereco    := fQuery.FieldByName('Endereco').AsInteger;
      fDadosCli.Fone        := fQuery.FieldByName('Fone').AsInteger;
    end;
  end;
end;

procedure TCliente.setCliente(const Value: String);
var
  wCod: Integer;
begin
  Clear;
  wCod := StrToIntDef(Trim(Value), 0);

  if (wCod > 0) then
    setCodigo(wCod)
  else
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Cliente '+
                                'WHERE Empre = :Empre and Nome = :Nome');
    fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
    fQuery.ParamByName('Nome').AsString    := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosCli.id          := fQuery.FieldByName('id').AsInteger;
      fDadosCli.Empre       := fQuery.FieldByName('Empre').AsInteger;
      fDadosCli.Codigo      := fQuery.FieldByName('Codigo').AsInteger;
      fDadosCli.CPFNPJ      := fSomenteNumeros(fQuery.FieldByName('CPFCNPJ').AsString);
      fDadosCli.Nome        := fQuery.FieldByName('NOME').AsString;
      fDadosCli.Apelido     := fQuery.FieldByName('APELIDO').AsString;
      fDadosCli.Status      := fQuery.FieldByName('Status').AsInteger;
      fDadosCli.MoedaTIP    := fQuery.FieldByName('MoedaTIP').AsInteger;
      fDadosCli.CartaoTIP   := fQuery.FieldByName('CartaoTIP').AsInteger;
      fDadosCli.CartaoCOD   := fQuery.FieldByName('CartaoCOD').AsInteger;
      fDadosCli.Endereco    := fQuery.FieldByName('Endereco').AsInteger;
      fDadosCli.Fone        := fQuery.FieldByName('Fone').AsInteger;
    end
    else
    begin
      FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Cliente '+
                                  'WHERE Empre = :Empre and Apelido = :Apelido');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Apelido').AsString := Value;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        fDadosCli.id          := fQuery.FieldByName('id').AsInteger;
        fDadosCli.Empre       := fQuery.FieldByName('Empre').AsInteger;
        fDadosCli.Codigo      := fQuery.FieldByName('Codigo').AsInteger;
        fDadosCli.CPFNPJ      := fSomenteNumeros(fQuery.FieldByName('CPFCNPJ').AsString);
        fDadosCli.Nome        := fQuery.FieldByName('NOME').AsString;
        fDadosCli.Apelido     := fQuery.FieldByName('APELIDO').AsString;
        fDadosCli.Status      := fQuery.FieldByName('Status').AsInteger;
        fDadosCli.MoedaTIP    := fQuery.FieldByName('MoedaTIP').AsInteger;
        fDadosCli.CartaoTIP   := fQuery.FieldByName('CartaoTIP').AsInteger;
        fDadosCli.CartaoCOD   := fQuery.FieldByName('CartaoCOD').AsInteger;
        fDadosCli.Endereco    := fQuery.FieldByName('Endereco').AsInteger;
        fDadosCli.Fone        := fQuery.FieldByName('Fone').AsInteger;
      end;
    end;
  end;
end;

function TCliente.fGravar: Integer;

  function fGeraCodigo: Integer;
  var
    wQueryLoc: TpFIBQuery;
    wTransLoc: TpFIBTransaction;
  begin
    FIBQueryCriar(wQueryLoc, wTransLoc);
    try
      FIBQueryAtribuirSQL(wQueryLoc, 'SELECT coalesce(max(Codigo),0)+1 from Cliente where '+
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
      if (fDadosCli.Codigo > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Cliente '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre');
        fQuery.ParamByName('Codigo').AsInteger  := fDadosCli.Codigo;
        fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof);
        fDadosCli.id := fQuery.FieldByName('id').AsInteger;
      end;

      if (fDadosCli.Codigo > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Cliente '+
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
        if (not wExiste) and ((fDadosCli.Codigo = 0) or (fDadosCli.Codigo > fGetMax('Cliente','Codigo',True))) then
          fDadosCli.Codigo := fGeraCodigo;
        if (not wExiste) then
          fDadosCli.id := fGetGenerator('GEN_CLIENTE');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Cliente ( id,  Empre,  Codigo,  CPFCNPJ,  NOME,  APELIDO,  Status,  MoedaTIP,  CartaoTIP,  CartaoCOD,  Endereco,  Fone) '+
                                    '             VALUES (:ID, :Empre, :Codigo, :CPFCNPJ, :NOME, :APELIDO, :Status, :MoedaTIP, :CartaoTIP, :CartaoCOD, :Endereco, :Fone) ');
        fQuery.ParamByName('id').AsInteger         := fDadosCli.id;
      end;
      //
      fQuery.ParamByName('Empre').AsInteger        := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger       := fDadosCli.Codigo;
      fQuery.ParamByName('CPFCNPJ').AsString       := fSomenteNumeros(fDadosCli.CPFNPJ);
      fQuery.ParamByName('NOME').AsString          := fDadosCli.Nome;
      fQuery.ParamByName('APELIDO').AsString       := fDadosCli.Apelido;
      fQuery.ParamByName('Status').AsInteger       := fDadosCli.Status;
      fQuery.ParamByName('MoedaTIP').AsInteger     := fDadosCli.MoedaTIP;
      fQuery.ParamByName('CartaoTIP').AsInteger    := fDadosCli.CartaoTIP;
      fQuery.ParamByName('CartaoCOD').AsInteger    := fDadosCli.CartaoCOD;
      fQuery.ParamByName('Endereco').AsInteger     := fDadosCli.Endereco;
      fQuery.ParamByName('Fone').AsInteger         := fDadosCli.Fone;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosCli.id := 0;
        MessageDlg('Erro ao gravar o Cliente!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosCli.id;
  end;
end;

function TCliente.fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para o Cliente!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Cliente WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := ppDados.Codigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Cliente '+IntToStr(ppDados.Codigo)+' não foi encontrado.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Cliente SET Status = :Status WHERE Empre = :Empre and Codigo = :Codigo');
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
        MessageDlg('Erro ao alterar o status do Cliente '+IntToStr(ppDados.Codigo)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCliente.fExcluir(var prErro: String): Boolean;
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
      fQuery.ParamByName('Id').AsInteger := fDadosCli.Fone;
      fQuery.ExecQuery;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Endereco WHERE Id = :Id');
      fQuery.ParamByName('Id').AsInteger := fDadosCli.Endereco;
      fQuery.ExecQuery;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Cliente WHERE Empre = :Empre and Codigo = :Codigo');
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
        prErro := 'Erro ao excluir o Cliente '+IntToStr(ppDados.Codigo)+eol+'Rotina: '+IntToStr(wRotina)+eol+e.Message;
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCliente.fPodeExcluir(prCodigo: Integer; prInterativo: Boolean; var prErro: String): Boolean;
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
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Cliente WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := prCodigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Cliente '+IntToStr(prCodigo)+' não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Lancamento WHERE CliForTIP = 1 AND CliForCOD = :CliForCOD');
      fQuery.ParamByName('CliForCOD').AsInteger := prCodigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'O Cliente '+IntToStr(prCodigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' lançamentos.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CtaPagDocto WHERE EmitenteTIP = 1 AND EmitenteCOD = :EmitenteCOD');
      fQuery.ParamByName('EmitenteCOD').AsInteger := prCodigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'O Cliente '+IntToStr(prCodigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' faturas A PAGAR.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CtaRecDocto WHERE EmitenteTIP = 1 AND EmitenteCOD = :EmitenteCOD');
      fQuery.ParamByName('EmitenteCOD').AsInteger := prCodigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'O Cliente '+IntToStr(prCodigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' faturas A RECEBER.';
        Exit
      end;

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        prErro := prErro + eol + 'Erro ao verificar se pode excluir o Cliente '+IntToStr(prCodigo)+eol+'Rotina: '+IntToStr(wRotina)+eol+e.Message;
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
