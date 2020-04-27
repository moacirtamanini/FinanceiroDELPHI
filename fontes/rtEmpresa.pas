unit rtEmpresa;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, Graphics,
  rtTypes;

type
  TDadosEmp = packed record
    id         : Integer;
    CPFNPJ     : String;
    EMAIL      : String;
    SENHA      : String;
    Nome       : String;
    Apelido    : String;
    Status     : Integer;
    Endereco   : Integer;
    Fone       : Integer;
  end;

  TEmpresa = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosEmp: TDadosEmp;
    function  getID: Integer;
    procedure setID(const Value: Integer);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    CarregaCPFCNPJ(prCPFCNPJ, prSenha: String): Integer;
    function    CarregaEMAIL (prEMAIL, prSenha: String): Integer;
    function    CarregaAPELIDO(prAPELIDO, prSenha: String): Integer;

    function    fPodeGravar(Msg: Boolean; var prID: Integer): Boolean;
    function    fValidarNova(var prID: Integer): Boolean;
    function    fGravaEmpresa: Integer;
    function    fSetStatusEmpresa(const prStatus: Integer; var prErro: String): Boolean;
    function    fExcluirEmpresa(const prForce: Boolean; var prErro: String): Boolean;

    property ppDados: TDadosEmp read fDadosEmp write fDadosEmp;
    property ppID   : Integer   read getID     write setID;
end;

implementation

uses uDataM, FIBQuery, uUtils;

constructor TEmpresa.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TEmpresa.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TEmpresa.Clear;
begin
  FillChar(fDadosEmp, SizeOf(fDadosEmp), #0);
end;

function TEmpresa.getID: Integer;
begin
  Result := fDadosEmp.id;
end;

procedure TEmpresa.setID(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Empresa '+
                                'WHERE id = :id');
    fQuery.ParamByName('id').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosEmp.id          := fQuery.FieldByName('id').AsInteger;
      fDadosEmp.CPFNPJ      := fSomenteNumeros(fQuery.FieldByName('CPFCNPJ').AsString);
      fDadosEmp.Email       := fQuery.FieldByName('EMAIL').AsString;
      fDadosEmp.Senha       := fQuery.FieldByName('SENHA').AsString;
      fDadosEmp.Nome        := fQuery.FieldByName('NOME').AsString;
      fDadosEmp.Apelido     := fQuery.FieldByName('APELIDO').AsString;
      fDadosEmp.Status      := fQuery.FieldByName('Status').AsInteger;
      fDadosEmp.Endereco    := fQuery.FieldByName('Endereco').AsInteger;
      fDadosEmp.Fone        := fQuery.FieldByName('Fone').AsInteger;
    end;
  end;
end;

function TEmpresa.CarregaCPFCNPJ(prCPFCNPJ, prSenha: String): Integer;
begin
  Result := 0;

  if (prCPFCNPJ <> '') then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT id, Status FROM Empresa '+
                                'WHERE CPFCNPJ = :CPFCNPJ AND Senha = :Senha');
    fQuery.ParamByName('CPFCNPJ').AsString := fSomenteNumeros(prCPFCNPJ);
    fQuery.ParamByName('Senha').AsString  := prSenha;
    fQuery.ExecQuery;

    if (not fQuery.Eof) then
      if (fQuery.FieldByName('Status').AsInteger = 1) then
        Result := fQuery.FieldByName('id').AsInteger;
  end;
  setID(Result);
end;

function TEmpresa.CarregaEMAIL(prEmail, prSenha: String): Integer;
begin
  Result := 0;

  if (prEmail <> '') then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT id, Status FROM Empresa '+
                                'WHERE Email = :Email AND Senha = :Senha');
    fQuery.ParamByName('Email').AsString  := AnsiLowerCase(Trim(prEmail));
    fQuery.ParamByName('Senha').AsString  := prSenha;
    fQuery.ExecQuery;

    if (not fQuery.Eof) then
      if (fQuery.FieldByName('Status').AsInteger = 1) then
        Result := fQuery.FieldByName('id').AsInteger;
  end;
  setID(Result);
end;

function TEmpresa.CarregaAPELIDO(prAPELIDO, prSenha: String): Integer;
begin
  Result := 0;

  if (prAPELIDO <> '') then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT id, Status FROM Empresa '+
                                'WHERE Apelido = :Apelido AND Senha = :Senha');
    fQuery.ParamByName('Apelido').AsString  := AnsiUpperCase(Trim(prAPELIDO));
    fQuery.ParamByName('Senha').AsString    := prSenha;
    fQuery.ExecQuery;

    if (not fQuery.Eof) then
      if (fQuery.FieldByName('Status').AsInteger = 1) then
        Result := fQuery.FieldByName('id').AsInteger;
  end;
  setID(Result);
end;

function TEmpresa.fPodeGravar(Msg: Boolean; var prID: Integer): Boolean;
begin
  Result := False;
  prID   := 0;

  if (fDadosEmp.id < 0) then Exit;

  prID := CarregaCPFCNPJ(fDadosEmp.CPFNPJ, fDadosEmp.SENHA);
  if prID = -2 then
  begin
    if Msg then
      MessageDlg('Informe corretamente o CPF/CNPJ e a Senha', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (prID < 1) then
  begin
    prID := CarregaEMAIL(fDadosEmp.EMAIL, fDadosEmp.SENHA);
    if prID = -2 then
    begin
      if Msg then
        MessageDlg('Informe corretamente o e-mail e a Senha', mtWarning, [mbOk], 0);
      Exit;
    end;

    if (prID = -1) then
    begin
      if Msg then
        MessageDlg('Informe a Senha para poder acessar!', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  Result := (prID > -1);
end;

function TEmpresa.fValidarNova(var prID: Integer): Boolean;
var
  wID0, wID1, wID2: Integer;
begin
  Result := False;
  prID   := 0;

  if (fDadosEmp.id < 0) then Exit;

  if (Length(Trim(fDadosEmp.CPFNPJ)) = 0) or
     (Length(Trim(fDadosEmp.EMAIL)) = 0) or
     (Length(Trim(fDadosEmp.SENHA)) = 0) then
  begin
    MessageDlg('O CPF/CNPJ, o E-Mail e Senha devem ser informados.', mtWarning, [mbOk], 0);
    Exit;
  end;

  wID0 := CarregaCPFCNPJ(fDadosEmp.CPFNPJ, fDadosEmp.SENHA);
  if wID0 = -2 then
  begin
    MessageDlg('CPF/CNPJ já está cadastrado.'+eol+'Informe corretamente o CPF/CNPJ e a Senha', mtWarning, [mbOk], 0);
    Exit;
  end;

  wID1 := CarregaEMAIL(fDadosEmp.EMAIL, fDadosEmp.SENHA);
  if wID1 = -2 then
  begin
    MessageDlg('E-Mail já cadastrado.'+eol+'Informe corretamente o E-Mail e a Senha', mtWarning, [mbOk], 0);
    Exit;
  end;

  wID2 := CarregaAPELIDO(fDadosEmp.Apelido, fDadosEmp.SENHA);
  if wID2 = -2 then
  begin
    MessageDlg('Apelido já cadastrado.'+eol+'Informe corretamente o Apelido e a Senha', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (wID0 = -1) or (wID1 = -1) or (wID2 = -1) then
  begin
    MessageDlg('CPF/CNPJ ou E-Mail ou Apelido já existe!'+eol+'Informe a Senha para poder acessar!', mtWarning, [mbOk], 0);
    Exit;
  end;

  Result := (wID0 > -1) and (wID1 > 0) and (wID2 > 0) and (wID0 = wID1) and (wID1 = wID2);
  if Result then
    prID := wID0
  else
    Result := True;
end;

function TEmpresa.fGravaEmpresa: Integer;
var
  wExiste: Boolean;
begin
  Result := 0;
  wExiste:= False;

  if (fDadosEmp.id < 0) then Exit;

  try
    try
      if (fDadosEmp.id > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Empresa '+
                                    'WHERE id = :id');
        fQuery.ParamByName('id').AsInteger := fDadosEmp.id;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof) and (fDadosEmp.id <= fGetGenerator('GEN_EMPRESA', 0));
      end;

      if (fDadosEmp.id > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Empresa '+
                                    'SET NOME        = :NOME, '+
                                    '    APELIDO     = :APELIDO, '+
                                    '    Status      = :Status, '+
                                    '    Endereco    = :Endereco, '+
                                    '    Fone        = :Fone '+
                                    'WHERE id = :id')
      else
      begin
        if (not wExiste) then
          fDadosEmp.id := fGetGenerator('GEN_EMPRESA');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Empresa ( id,  CPFCNPJ,  EMAIL,  SENHA,  NOME,  APELIDO,  STATUS,  ENDERECO,  FONE) '+
                                    '             VALUES (:ID, :CPFCNPJ, :EMAIL, :SENHA, :NOME, :APELIDO, :STATUS, :ENDERECO, :FONE) ');
        fQuery.ParamByName('CPFCNPJ').AsString      := fSomenteNumeros(fDadosEmp.CPFNPJ);
        fQuery.ParamByName('EMAIL').AsString        := fDadosEmp.EMAIL;
        fQuery.ParamByName('SENHA').AsString        := fDadosEmp.SENHA;
      end;
      //
      fQuery.ParamByName('id').AsInteger          := fDadosEmp.id;
      fQuery.ParamByName('NOME').AsString         := fDadosEmp.Nome;
      fQuery.ParamByName('APELIDO').AsString      := fDadosEmp.Apelido;
      fQuery.ParamByName('STATUS').AsInteger      := fDadosEmp.Status;
      fQuery.ParamByName('ENDERECO').AsInteger    := fDadosEmp.Endereco;
      fQuery.ParamByName('FONE').AsInteger        := fDadosEmp.Fone;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosEmp.id := 0;
        MessageDlg('Erro ao gravar a Empresa!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosEmp.id;
  end;
end;

function TEmpresa.fSetStatusEmpresa(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para a Empresa!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Empresa WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'A empresa '+IntToStr(ppID)+' não foi encontrada.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Empresa SET Status = :Status WHERE id = :id');
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
        MessageDlg('Erro ao alterar o status da Empresa '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TEmpresa.fExcluirEmpresa(const prForce: Boolean; var prErro: String): Boolean;
var
  wRotina: Integer;
  wPodeExcluir: Boolean;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;
  wPodeExcluir := False;
  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Empresa WHERE id = :id');
      fQuery.ParamByName('id').AsInteger := ppID;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'A empresa '+IntToStr(ppID)+' não foi encontrada para exclusão.';
        Exit
      end;

      if (not prForce) then
      begin
        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) FROM CartaoDebito WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;
        if (not fQuery.Eof) and (fQuery.Fields[0].AsInteger > 0) then
        begin
          prErro := 'A empresa '+IntToStr(ppID)+' não pode ser excluída.'+Eol+
                    'Possui '+fQuery.Fields[0].AsString+' Cartão de Débito" vinculados e ela!';
          Exit
        end;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) FROM CartaoCredito WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;
        if (not fQuery.Eof) and (fQuery.Fields[0].AsInteger > 0) then
        begin
          prErro := 'A empresa '+IntToStr(ppID)+' não pode ser excluída.'+Eol+
                    'Possui '+fQuery.Fields[0].AsString+' Cartão de Crédito" vinculados e ela!';
          Exit
        end;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) FROM Categoria WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;
        if (not fQuery.Eof) and (fQuery.Fields[0].AsInteger > 0) then
        begin
          prErro := 'A empresa '+IntToStr(ppID)+' não pode ser excluída.'+Eol+
                    'Possui '+fQuery.Fields[0].AsString+' Categorias" vinculadas e ela!';
          Exit
        end;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) FROM Cliente WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;
        if (not fQuery.Eof) and (fQuery.Fields[0].AsInteger > 0) then
        begin
          prErro := 'A empresa '+IntToStr(ppID)+' não pode ser excluída.'+Eol+
                    'Possui '+fQuery.Fields[0].AsString+' Clientes" vinculadas e ela!';
          Exit
        end;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) FROM Fornecedor WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;
        if (not fQuery.Eof) and (fQuery.Fields[0].AsInteger > 0) then
        begin
          prErro := 'A empresa '+IntToStr(ppID)+' não pode ser excluída.'+Eol+
                    'Possui '+fQuery.Fields[0].AsString+' Fornecedores" vinculadas e ela!';
          Exit
        end;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) FROM Lancamento WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;
        if (not fQuery.Eof) and (fQuery.Fields[0].AsInteger > 0) then
        begin
          prErro := 'A empresa '+IntToStr(ppID)+' não pode ser excluída.'+Eol+
                    'Possui '+fQuery.Fields[0].AsString+' Lançamentos vinculados a ela!';
          Exit
        end;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) FROM Usuario WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;
        if (not fQuery.Eof) and (fQuery.Fields[0].AsInteger > 0) then
        begin
          prErro := 'A empresa '+IntToStr(ppID)+' não pode ser excluída.'+Eol+
                    'Possui '+fQuery.Fields[0].AsString+' Usuários vinculados a ela!';
          Exit
        end;

        //
        wPodeExcluir := True;
      end;

      wRotina := 99;
      if (wPodeExcluir) or (prForce) then
      begin
        if (not wPodeExcluir) then
        begin
          if (not Confirmar('Confirma a exclusão da Empresa e TODO os seus Registros e Lançamentos?', clRed, 'Confirme a exclusão')) then
          begin
            prErro := 'Exclusão não foi confirmada!';
            Exit;
          end;
        end;
        
        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM CartaoDebito WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM CartaoCredito WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Categoria WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Cliente WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Fornecedor WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Lancamento WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Usuario WHERE Empre = :Empre');
        fQuery.ParamByName('Empre').AsInteger := ppID;
        fQuery.ExecQuery;

        Inc(wRotina);
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Empresa WHERE Id = :id');
        fQuery.ParamByName('id').AsInteger := ppID;
        fQuery.ExecQuery;
        FIBQueryCommit(fQuery);

        Result := True;
      end;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao excluir a Empresa '+IntToStr(ppID)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

end.
