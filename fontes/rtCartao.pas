unit rtCartao;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, Graphics,
  rtTypes;

type
  TDadosCartao = packed record
    id           : Integer;
    Empre        : Integer;
    Codigo       : Integer;
    tpDebCre     : Integer;
    Bandeira     : Integer;
    Descricao    : String;
    Nome         : String;
    NroIni       : String;
    NroFim       : String;
    SenhaComp    : String;
    SiteBanco    : String;
    SenhaSite    : String;
    Validade     : TDate;
    DiaFatFec    : Integer;
    DiaFatVen    : Integer;
    CategoriaDeb : Integer;
    CategoriaCre : Integer;
    Status       : Integer;
  end;

  TCartao = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosCartao: TDadosCartao;
    function  getCodigo: Integer;
    procedure setCodigo(const Value: Integer);
    function  getDescri: String;
    procedure setDescri(const Value: String);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravar: Integer;
    function    fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
    function    fExcluir(var prErro: String): Boolean;

    property ppDados: TDadosCartao read fDadosCartao write fDadosCartao;
    property ppCodigo: Integer     read getCodigo    write setCodigo;
    property ppDescri: String      read getDescri    write setDescri;
end;

implementation

uses uDataM, FIBQuery, uUtils;

constructor TCartao.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TCartao.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TCartao.Clear;
begin
  FillChar(fDadosCartao, SizeOf(fDadosCartao), #0);
end;

function TCartao.getCodigo: Integer;
begin
  Result := fDadosCartao.Codigo;
end;

procedure TCartao.setCodigo(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM CartaoDebCre '+
                                'WHERE Codigo = :Codigo and Empre = :Empre');
    fQuery.ParamByName('Codigo').AsInteger  := Value;
    fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosCartao.id           := fQuery.FieldByName('id').AsInteger;
      fDadosCartao.Empre        := fQuery.FieldByName('Empre').AsInteger;
      fDadosCartao.Codigo       := fQuery.FieldByName('Codigo').AsInteger;
      fDadosCartao.tpDebCre     := fQuery.FieldByName('tpDebCre').AsInteger;
      fDadosCartao.Bandeira     := fQuery.FieldByName('Bandeira').AsInteger;
      fDadosCartao.Descricao    := fQuery.FieldByName('Descricao').AsString;
      fDadosCartao.Nome         := fQuery.FieldByName('Nome').AsString;
      fDadosCartao.NroIni       := fQuery.FieldByName('NroIni').AsString;
      fDadosCartao.NroFim       := fQuery.FieldByName('NroFim').AsString;
      fDadosCartao.SenhaComp    := rijndael_decrypt(fQuery.FieldByName('SenhaComp').AsString, DCPKeyName, DCPVectorName);
      fDadosCartao.SiteBanco    := fQuery.FieldByName('SiteBanco').AsString;
      fDadosCartao.SenhaSite    := rijndael_decrypt(fQuery.FieldByName('SenhaSite').AsString, DCPKeyName, DCPVectorName);
      fDadosCartao.Validade     := fQuery.FieldByName('Validade').AsDate;
      fDadosCartao.DiaFatFec    := fQuery.FieldByName('DiaFatFec').AsInteger;
      fDadosCartao.DiaFatVen    := fQuery.FieldByName('DiaFatVen').AsInteger;
      fDadosCartao.CategoriaDeb := fQuery.FieldByName('CategoriaDeb').AsInteger;
      fDadosCartao.CategoriaCre := fQuery.FieldByName('CategoriaCre').AsInteger;
      fDadosCartao.Status       := fQuery.FieldByName('Status').AsInteger;
    end;
  end;
end;

function TCartao.getDescri: String;
begin
  Result := fDadosCartao.Descricao;
end;

procedure TCartao.setDescri(const Value: String);
begin
  Clear;
  if (Value <> '') then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM CartaoDebCre '+
                                'WHERE Descricao = :Descricao and Empre = :Empre');
    fQuery.ParamByName('Descricao').AsString := AnsiUpperCase(Trim(Value));
    fQuery.ParamByName('Empre').AsInteger    := fDataM.Empresa;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosCartao.id           := fQuery.FieldByName('id').AsInteger;
      fDadosCartao.Empre        := fQuery.FieldByName('Empre').AsInteger;
      fDadosCartao.Codigo       := fQuery.FieldByName('Codigo').AsInteger;
      fDadosCartao.tpDebCre     := fQuery.FieldByName('tpDebCre').AsInteger;
      fDadosCartao.Bandeira     := fQuery.FieldByName('Bandeira').AsInteger;
      fDadosCartao.Descricao    := fQuery.FieldByName('Descricao').AsString;
      fDadosCartao.Nome         := fQuery.FieldByName('Nome').AsString;
      fDadosCartao.NroIni       := fQuery.FieldByName('NroIni').AsString;
      fDadosCartao.NroFim       := fQuery.FieldByName('NroFim').AsString;
      fDadosCartao.SenhaComp    := rijndael_decrypt(fQuery.FieldByName('SenhaComp').AsString, DCPKeyName, DCPVectorName);
      fDadosCartao.SiteBanco    := fQuery.FieldByName('SiteBanco').AsString;
      fDadosCartao.SenhaSite    := rijndael_decrypt(fQuery.FieldByName('SenhaSite').AsString, DCPKeyName, DCPVectorName);
      fDadosCartao.Validade     := fQuery.FieldByName('Validade').AsDate;
      fDadosCartao.DiaFatFec    := fQuery.FieldByName('DiaFatFec').AsInteger;
      fDadosCartao.DiaFatVen    := fQuery.FieldByName('DiaFatVen').AsInteger;
      fDadosCartao.CategoriaDeb := fQuery.FieldByName('CategoriaDeb').AsInteger;
      fDadosCartao.CategoriaCre := fQuery.FieldByName('CategoriaCre').AsInteger;
      fDadosCartao.Status       := fQuery.FieldByName('Status').AsInteger;
    end;
  end;
end;

function TCartao.fGravar: Integer;

  function fGeraCodigo: Integer;
  var
    wQueryLoc: TpFIBQuery;
    wTransLoc: TpFIBTransaction;
  begin
    FIBQueryCriar(wQueryLoc, wTransLoc);
    try
      FIBQueryAtribuirSQL(wQueryLoc, 'SELECT coalesce(max(Codigo),0)+1 from CartaoDebCre where '+
                                     ' Empre = :Empre');
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
  Result := 0;
  wExiste:= False;

  if fDataM.Empresa < 1 then
  begin
    MessageDlg('A empresa deve ser maior que zero!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if Length(Trim(fDadosCartao.Descricao)) = 0 then
  begin
    MessageDlg('A descrição do cartão não foi informada!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if Length(Trim(fDadosCartao.Nome)) = 0 then
  begin
    MessageDlg('O nome impresso no cartão não foi informado!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if StrToIntDef(Trim(fDadosCartao.NroIni),0) = 0 then
  begin
    MessageDlg('Os números iniciais do cartão não foram informados!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if StrToIntDef(Trim(fDadosCartao.NroFim),0) = 0 then
  begin
    MessageDlg('Os números finais do cartão não foram informados!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosCartao.Validade < cDataMinima) then
  begin
    MessageDlg('A data de validade do cartão não foi informada!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosCartao.Validade > cDataMaxima) then
  begin
    MessageDlg('A data de validade do cartão é muito distante!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosCartao.tpDebCre > 0) then
  begin
    if (fDadosCartao.DiaFatFec < 1) or (fDadosCartao.DiaFatFec > 28) then
    begin
      MessageDlg('O dia de fechamento da fatura deve estar entre 01 a 28', mtWarning, [mbOk], 0);
      Exit;
    end;

    if (fDadosCartao.DiaFatVen < 1) or (fDadosCartao.DiaFatVen > 28) then
    begin
      MessageDlg('O dia de vencimento da fatura deve estar entre 01 a 28', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (fDadosCartao.tpDebCre < 0) or (fDadosCartao.tpDebCre > 2) then
  begin
    MessageDlg('O tipo de cartão não foi informado', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosCartao.Bandeira < 1) then
  begin
    MessageDlg('A bandeira do cartão não foi informada', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosCartao.CategoriaDeb < 1) then
  begin
    MessageDlg('A categoria padrão para Débito do cartão não foi informada', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosCartao.CategoriaCre < 1) then
  begin
    MessageDlg('A categoria padrão para Crédito do cartão não foi informada', mtWarning, [mbOk], 0);
    Exit;
  end;

  try
    try
      if (fDadosCartao.Codigo > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from CartaoDebCre '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre');
        fQuery.ParamByName('Codigo').AsInteger  := fDadosCartao.Codigo;
        fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof);
        fDadosCartao.id := fQuery.FieldByName('id').AsInteger;
      end;

      if (fDadosCartao.Codigo > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE CartaoDebCre '+
                                    'SET tpDebCre     = :tpDebCre, '+
                                    '    bandeira     = :bandeira, '+
                                    '    DESCRICAO    = :DESCRICAO, '+
                                    '    NOME         = :NOME, '+
                                    '    NROINI       = :NROINI, '+
                                    '    NROFIM       = :NROFIM, '+
                                    '    SENHACOMP    = :SENHACOMP, '+
                                    '    SITEBANCO    = :SITEBANCO, '+
                                    '    SENHASITE    = :SENHASITE, '+
                                    '    VALIDADE     = :VALIDADE, '+
                                    '    DiaFatFec    = :DiaFatFec, '+
                                    '    DiaFatVen    = :DiaFatVen, '+
                                    '    CategoriaDeb = :CategoriaDeb, '+
                                    '    CategoriaCre = :CategoriaCre, '+
                                    '    Status       = :Status '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre')
      else
      begin
        if (not wExiste) and ((fDadosCartao.Codigo = 0) or (fDadosCartao.Codigo > fGetMax('Cartao','Codigo',True))) then
          fDadosCartao.Codigo := fGeraCodigo;

        if (not wExiste) then
          fDadosCartao.id := fGetGenerator('GEN_CARTAODEBCRE');

        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO CartaoDebCre ( id,  Empre,  Codigo,  tpDebCre,  bandeira,  DESCRICAO,  NOME,  NROINI,  NROFIM,  SENHACOMP,  SITEBANCO,  SENHASITE, '+
                                    '                     VALIDADE,  DiaFatFec,  DiaFatVen,  CategoriaDeb,  CategoriaCre,  Status) '+
                                    '                  VALUES (:ID, :Empre, :Codigo, :tpDebCre, :bandeira, :DESCRICAO, :NOME, :NROINI, :NROFIM, :SENHACOMP, :SITEBANCO, :SENHASITE, '+
                                    '                    :VALIDADE, :DiaFatFec, :DiaFatVen, :CategoriaDeb, :CategoriaCre, :Status) ');
        fQuery.ParamByName('id').AsInteger         := fDadosCartao.id;
      end;
      //
      fQuery.ParamByName('Empre').AsInteger        := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger       := fDadosCartao.Codigo;
      fQuery.ParamByName('tpDebCre').AsInteger     := fDadosCartao.tpDebCre;
      fQuery.ParamByName('Bandeira').AsInteger     := fDadosCartao.Bandeira;
      fQuery.ParamByName('DESCRICAO').AsString     := fDadosCartao.Descricao;
      fQuery.ParamByName('NOME').AsString          := fDadosCartao.Nome;
      fQuery.ParamByName('NROINI').AsString        := fDadosCartao.NroIni;
      fQuery.ParamByName('NROFIM').AsString        := fDadosCartao.NroFim;
      fQuery.ParamByName('SENHACOMP').AsString     := rijndael_encrypt(fDadosCartao.SenhaComp, DCPKeyName, DCPVectorName);
      fQuery.ParamByName('SITEBANCO').AsString     := fDadosCartao.SiteBanco;
      fQuery.ParamByName('SENHASITE').AsString     := rijndael_encrypt(fDadosCartao.SenhaSite, DCPKeyName, DCPVectorName);
      fQuery.ParamByName('VALIDADE').AsDate        := fDadosCartao.Validade;
      fQuery.ParamByName('DiaFatFec').AsInteger    := fDadosCartao.DiaFatFec;
      fQuery.ParamByName('DiaFatVen').AsInteger    := fDadosCartao.DiaFatVen;
      fQuery.ParamByName('CategoriaDeb').AsInteger := fDadosCartao.CategoriaDeb;
      fQuery.ParamByName('CategoriaCre').AsInteger := fDadosCartao.CategoriaCre;
      fQuery.ParamByName('Status').AsInteger       := fDadosCartao.Status;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosCartao.id := 0;
        MessageDlg('Erro ao gravar o Cartão de Débito e/ou Crédito!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosCartao.id;
  end;
end;

function TCartao.fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para o Cartão de Débito e/ou Crédito!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CartaoDebCre WHERE Codigo = :Codigo and Empre = :Empre ');
      fQuery.ParamByName('Codigo').AsInteger   := ppCodigo;
      fQuery.ParamByName('Empre').AsInteger    := fDataM.Empresa;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Cartão de Débito e/ou Crédito '+IntToStr(ppCodigo)+' não foi encontrado.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE CartaoDebCre SET Status = :Status Codigo = :Codigo and Empre = :Empre ');
      fQuery.ParamByName('Codigo').AsInteger  := ppCodigo;
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ParamByName('Status').AsInteger  := prStatus;
      fQuery.ExecQuery;

      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao alterar o status do Cartão de Débito e/ou Crédito '+IntToStr(ppCodigo)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCartao.fExcluir(var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;
  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CartaoDebCre WHERE Codigo = :Codigo and Empre = :Empre ');
      fQuery.ParamByName('Codigo').AsInteger  := ppCodigo;
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O Cartão de Débito e/ou Crédito '+IntToStr(ppCodigo)+' não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CtaPagParce WHERE cartao_cd = :cartao_cd and Empre = :Empre');
      fQuery.ParamByName('cartao_cd').AsInteger := ppCodigo;
      fQuery.ParamByName('Empre').AsInteger     := fDataM.Empresa;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'O Cartão de Débito e/ou Crédito '+IntToStr(ppCodigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' lançamentos do Contas A Pagar.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM CartaoDebCre WHERE Codigo = :Codigo and Empre = :Empre ');
      fQuery.ParamByName('Codigo').AsInteger  := ppCodigo;
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao excluir o Cartão de Débito e/ou Crédito '+IntToStr(ppCodigo)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

end.
