unit rtCategoria;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, Graphics,
  rtTypes;

type
  TDadosCat = packed record
    id            : Integer;
    Empre         : Integer;
    Codigo        : Integer;
    Classificacao : String;
    Apelido       : String;
    Descricao     : String;
    ContaTIP      : Integer;
    DataCadastro  : TDateTime;
    Status        : Integer;
  end;

  TCategoria = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosCat: TDadosCat;
    function  getCodigo: Integer;
    procedure setCodigo(const Value: Integer);
    procedure setClassi(const Value: String);
    function  fMascaraClassi(prClassi: String; var prTpConta: Integer): String;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravar: Integer;
    function    fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
    function    fPodeExcluir: Boolean;
    function    fExcluir: Boolean;
    function    fSaldoCategoria(prCategoria: Integer; prDataSaldo: TDate): Currency;

    property ppDados: TDadosCat read fDadosCat write fDadosCat;
    property ppCodigo: Integer read getCodigo write setCodigo;
    property ppClassi: String  write setClassi;
end;

implementation

uses uDataM, FIBQuery, uUtils;

constructor TCategoria.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TCategoria.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TCategoria.Clear;
begin
  FillChar(fDadosCat, SizeOf(fDadosCat), #0);
end;

function TCategoria.getCodigo: Integer;
begin
  Result := fDadosCat.Codigo;
end;

function TCategoria.fMascaraClassi(prClassi: String; var prTpConta: Integer): String;
var
  wS0, wS1, wS2, wS3, wS4, wS5: String;
       wN1, wN2, wN3, wN4, wN5: Integer;
begin
  Result    := '';
  prTpConta := 0; // 0-Sintetica || 1-Analitica

  wS0 := prClassi;
  wS1 := StrFetchTrim(wS0, '.');
  wS2 := StrFetchTrim(wS0, '.');
  wS3 := StrFetchTrim(wS0, '.');
  wS4 := StrFetchTrim(wS0, '.');
  wS5 := StrFetchTrim(wS0, '.');

  wN1 := StrToIntDef(wS1,0);
  wN2 := StrToIntDef(wS2,0);
  wN3 := StrToIntDef(wS3,0);
  wN4 := StrToIntDef(wS4,0);
  wN5 := StrToIntDef(wS5,0);

  if (wN1 > 0) then
  begin
    Result := Result + IntToStr(wN1);
    if (wN2 > 0) then
    begin
      Result := Result + '.' + FormatCurr('0', wN2);
      if (wN3 > 0) then
      begin
        Result := Result + '.' + FormatCurr('0', wN3);
        if (wN4 > 0) then
        begin
          Result := Result + '.' + FormatCurr('00', wN4);
          if (wN5 > 0) then
          begin
            Result := Result + '.' + FormatCurr('0000', wN5);
          end;
        end;
      end;
    end;
  end;

  if (wN5 > 0) then
    prTpConta := 1;
end;

procedure TCategoria.setCodigo(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Categoria '+
                                'WHERE Empre = :Empre and Codigo = :Codigo');
    fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
    fQuery.ParamByName('Codigo').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosCat.id            := fQuery.FieldByName('id').AsInteger;
      fDadosCat.Empre         := fQuery.FieldByName('Empre').AsInteger;
      fDadosCat.Codigo        := fQuery.FieldByName('Codigo').AsInteger;
      fDadosCat.Classificacao := fQuery.FieldByName('Classificacao').AsString;
      fDadosCat.Apelido       := fQuery.FieldByName('Apelido').AsString;
      fDadosCat.Descricao     := fQuery.FieldByName('Descricao').AsString;
      fDadosCat.ContaTIP      := fQuery.FieldByName('ContaTIP').AsInteger;
      fDadosCat.DataCadastro  := fQuery.FieldByName('DataCadastro').AsDateTime;
      fDadosCat.Status        := fQuery.FieldByName('Status').AsInteger;
    end;
  end;
end;

procedure TCategoria.setClassi(const Value: String);
var
  wClassi: String;
  wTp: Integer;
begin
  Clear;
  wClassi := fMascaraClassi(Value, wTp);
  if (wClassi <> '') then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Categoria '+
                                'WHERE Empre = :Empre and Classificacao = :Classificacao');
    fQuery.ParamByName('Empre').AsInteger        := fDataM.Empresa;
    fQuery.ParamByName('Classificacao').AsString := wClassi;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosCat.id            := fQuery.FieldByName('id').AsInteger;
      fDadosCat.Empre         := fQuery.FieldByName('Empre').AsInteger;
      fDadosCat.Codigo        := fQuery.FieldByName('Codigo').AsInteger;
      fDadosCat.Classificacao := fQuery.FieldByName('Classificacao').AsString;
      fDadosCat.Apelido       := fQuery.FieldByName('Apelido').AsString;
      fDadosCat.Descricao     := fQuery.FieldByName('Descricao').AsString;
      fDadosCat.ContaTIP      := fQuery.FieldByName('ContaTIP').AsInteger;
      fDadosCat.DataCadastro  := fQuery.FieldByName('DataCadastro').AsDateTime;
      fDadosCat.Status        := fQuery.FieldByName('Status').AsInteger;
    end;
  end;
end;

function TCategoria.fGravar: Integer;

  function fGeraCodigo: Integer;
  var
    wQueryLoc: TpFIBQuery;
    wTransLoc: TpFIBTransaction;
  begin
    FIBQueryCriar(wQueryLoc, wTransLoc);
    try
      FIBQueryAtribuirSQL(wQueryLoc, 'SELECT coalesce(max(Codigo),0)+1 from Categoria where '+
                                     '  Empre = :Empre');
      wQueryLoc.ParamByName('Empre').AsInteger := fDataM.Empresa;
      wQueryLoc.ExecQuery;
      Result := wQueryLoc.Fields[0].AsInteger;
    finally
      FIBQueryDestruir(wQueryLoc);
    end;
  end;

  function fApelidoOK(prCodigo: Integer): Boolean;
  var
    wQueryLoc: TpFIBQuery;
    wTransLoc: TpFIBTransaction;
  begin
    Result := True;
    if (fDadosCat.Apelido <> '') then
    begin
      FIBQueryCriar(wQueryLoc, wTransLoc);
      try
        FIBQueryAtribuirSQL(wQueryLoc, 'SELECT Codigo from Categoria where '+
                                       '  Empre = :Empre and Apelido = :Apelido and Codigo <> :Codigo');
        wQueryLoc.ParamByName('Empre').AsInteger  := fDataM.Empresa;
        wQueryLoc.ParamByName('Apelido').AsString := fDadosCat.Apelido;
        wQueryLoc.ParamByName('Codigo').AsInteger := prCodigo;
        wQueryLoc.ExecQuery;
        Result := wQueryLoc.Eof;
        if (not Result) then
          MessageDlg('O Apelido já foi usado na categoria '+IntToStr(wQueryLoc.FieldByName('Codigo').AsInteger), mtWarning, [mbOk], 0);
      finally
        FIBQueryDestruir(wQueryLoc);
      end;
    end;
  end;

var
  wExiste: Boolean;
  wClassi: String;
begin
  Result := 0;
  wExiste:= False;

  if fDataM.Empresa < 1 then
  begin
    MessageDlg('A empresa deve ser maior que zero!', mtWarning, [mbOk], 0);
    Exit;
  end;

  wClassi := fMascaraClassi(fDadosCat.Classificacao, fDadosCat.ContaTIP);
  if Length(wClassi) = 0 then
  begin
    MessageDlg('A classificação da categoria não foi informada corretamente!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if Length(Trim(fDadosCat.Descricao)) = 0 then
  begin
    MessageDlg('O nome da categoria não foi informado!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosCat.ContaTIP = 0) then
    fDadosCat.Apelido := ''
  else
  begin
    if (fDadosCat.Apelido <> '') then
      if fDadosCat.Apelido = fSomenteNumeros(fDadosCat.Apelido) then
      begin
        MessageDlg('O apelido da categoria não pode conter apenas números!'+eol+'Informe letras e números.', mtWarning, [mbOk], 0);
        Exit;
      end;
  end;

  try
    try
      if (fDadosCat.Codigo > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Categoria where '+
                                    ' Codigo = :Codigo and Empre = :Empre');
        fQuery.ParamByName('Codigo').AsInteger := fDadosCat.Codigo;
        fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof);
        fDadosCat.id := fQuery.FieldByName('id').AsInteger;
      end;

      if (fDadosCat.Codigo > 0) and (wExiste) then
      begin
        if (not fApelidoOK(fDadosCat.Codigo)) then
          Exit;
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Categoria '+
                                    'SET Codigo        = :Codigo, '+
                                    '    Classificacao = :Classificacao, '+
                                    '    Apelido       = :Apelido, '+
                                    '    Descricao     = :Descricao, '+
                                    '    ContaTIP      = :ContaTIP, '+
                                    '    Status        = :Status '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre');
      end
      else
      begin
        if (not wExiste) then
        begin
          if (not fApelidoOK(0)) then Exit;
          if (not wExiste) and ((fDadosCat.Codigo = 0) or (fDadosCat.Codigo > fGetMax('Categoria','Codigo',True))) then
            fDadosCat.Codigo := fGeraCodigo;
          fDadosCat.id := fGetGenerator('GEN_CATEGORIA');
        end;
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Categoria ( id,  Empre,  Codigo,  Classificacao,  Apelido,  Descricao,  ContaTIP,  DataCadastro,  STATUS) '+
                                    '               VALUES (:ID, :Empre, :Codigo, :Classificacao, :Apelido, :Descricao, :ContaTIP, :DataCadastro, :STATUS) ');
        fQuery.ParamByName('id').AsInteger            := fDadosCat.id;
        fQuery.ParamByName('DataCadastro').AsDateTime := Now;
      end;
      //
      fQuery.ParamByName('Empre').AsInteger           := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger          := fDadosCat.Codigo;
      fQuery.ParamByName('Classificacao').AsString    := wClassi;
      fQuery.ParamByName('Apelido').AsString          := fDadosCat.Apelido;
      fQuery.ParamByName('Descricao').AsString        := fDadosCat.Descricao;
      fQuery.ParamByName('ContaTIP').AsInteger        := fDadosCat.ContaTIP;
      fQuery.ParamByName('STATUS').AsInteger          := fDadosCat.Status;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
      Result := fDadosCat.id;
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosCat.id := 0;
        MessageDlg('Erro ao gravar a Categoria!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCategoria.fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para a Categoria!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Categoria '+
                                  'WHERE Codigo = :Codigo and Empre = :Empre');
      fQuery.ParamByName('Codigo').AsInteger := fDadosCat.Codigo;
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'A Categoria '+IntToStr(fDadosCat.Codigo)+' não foi encontrada.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Categoria SET Status = :Status '+
                                  'WHERE Codigo = :Codigo and Empre = :Empre');
      fQuery.ParamByName('Codigo').AsInteger    := fDadosCat.Codigo;
      fQuery.ParamByName('Empre').AsInteger     := fDataM.Empresa;
      fQuery.ParamByName('Status').AsInteger    := prStatus;
      fQuery.ExecQuery;

      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao alterar o status da Categoria '+IntToStr(fDadosCat.Codigo)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCategoria.fPodeExcluir: Boolean;
var
  wRotina: Integer;
begin
  Result := False;
  wRotina := 0;
  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Categoria '+
                                  'WHERE Codigo = :Codigo and Empre = :Empre');
      fQuery.ParamByName('Codigo').AsInteger := fDadosCat.Codigo;
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        MessageDlg('A Categoria '+IntToStr(fDadosCat.Codigo)+' não foi encontrada para exclusão.', mtWarning, [mbOk], 0);
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Categoria '+
                                  'WHERE Codigo <> :Codigo and Empre = :Empre and Classificacao LIKE :Classificacao');
      fQuery.ParamByName('Codigo').AsInteger       := fDadosCat.Codigo;
      fQuery.ParamByName('Empre').AsInteger        := fDataM.Empresa;
      fQuery.ParamByName('Classificacao').AsString := fDadosCat.Classificacao +'%';
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        if (fQuery.FieldByName('QTDE').AsInteger > 1) then
          MessageDlg('A Categoria '+fDadosCat.Classificacao+' possui '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' contas sobordinadas.', mtWarning, [mbOk], 0)
        else
          MessageDlg('A Categoria '+fDadosCat.Classificacao+' possui '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' conta sobordinada.', mtWarning, [mbOk], 0);
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CartaoDebCre '+
                                  'WHERE CategoriaDeb = :Codigo and Empre = :Empre');
      fQuery.ParamByName('Codigo').AsInteger  := fDadosCat.Codigo;
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        MessageDlg('A Categoria '+IntToStr(fDadosCat.Codigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' Cartões de Débito ou Crédito.', mtWarning, [mbOk], 0);
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CartaoDebCre '+
                                  'WHERE CategoriaCre = :Codigo and Empre = :Empre');
      fQuery.ParamByName('Codigo').AsInteger  := fDadosCat.Codigo;
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        MessageDlg('A Categoria '+IntToStr(fDadosCat.Codigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' Cartões de Débito ou Crédito.', mtWarning, [mbOk], 0);
        Exit
      end;
      
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Lancamento '+
                                  'WHERE (Empre = :Empre) and ((CategoriaEnt = :Ent) or (CategoriaSai = :Sai))');
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ParamByName('Ent').AsInteger     := fDadosCat.Codigo;
      fQuery.ParamByName('Sai').AsInteger     := fDadosCat.Codigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        MessageDlg('A Categoria '+IntToStr(fDadosCat.Codigo)+' está vinculado a '+IntToStr(fQuery.FieldByName('QTDE').AsInteger)+' Lançamentos.', mtWarning, [mbOk], 0);
        Exit
      end;

      Result := True;
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao verificar se a Categoria '+IntToStr(fDadosCat.Codigo)+' pode ser excluída.'+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCategoria.fExcluir: Boolean;
begin
  Result  := False;
  if fPodeExcluir then
  begin
    try
      try
        FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Categoria '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre');
        fQuery.ParamByName('Codigo').AsInteger  := fDadosCat.Codigo;
        fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
        fQuery.ExecQuery;
        FIBQueryCommit(fQuery);
        Result := True;
      except
        on e: exception do
        begin
          Result := False;
          FIBQueryRollback(fQuery);
          MessageDlg('Erro ao excluir a Categoria '+IntToStr(fDadosCat.Codigo)+eol+
                     e.Message, mtWarning, [mbOk], 0);
        end;
      end;
    finally
      FIBQueryRollback(fQuery);
    end;
  end;
end;

function TCategoria.fSaldoCategoria(prCategoria: Integer; prDataSaldo: TDate): Currency;
var
  wClass: String;
  wVlrDeb, wVlrCre: Currency;
begin
  Result  := 0.00;
  wClass  := '';
  wVlrDeb := 0.00;
  wVlrCre := 0.00;

  try
    try
      FIBQueryAtribuirSQL(fQuery, 'SELECT CLASSIFICACAO FROM CATEGORIA WHERE EMPRE = :EMPRE AND CODIGO = :CODIGO ');
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger  := prCategoria;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        wClass := fQuery.FieldByName('Classificacao').AsString;
        // Débito
        FIBQueryAtribuirSQL(fQuery, 'SELECT COALESCE(SUM(LAN.valorlancto),0) VLR FROM LANCAMENTO LAN, '+
                                    'categoria CAT '+
                                    'WHERE (LAN.Empre = :Empre) and (LAN.categoriaENT = CAT.codigo) and (LAN.empre = CAT.empre) and (LAN.datalancto <= :DataSaldo) '+
                                    'and (CAT.classificacao LIKE :Class) ');
        fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
        fQuery.ParamByName('Class').AsString    := wClass+'%';
        fQuery.ParamByName('DataSaldo').AsDate  := prDataSaldo;
        fQuery.ExecQuery;
        wVlrDeb := fQuery.FieldByName('VLR').AsCurrency;

        // Crédito
        FIBQueryAtribuirSQL(fQuery, 'SELECT COALESCE(SUM(LAN.valorlancto),0) VLR FROM LANCAMENTO LAN, '+
                                    'categoria CAT '+
                                    'WHERE (LAN.Empre = :Empre) and (LAN.categoriaSAI = CAT.codigo) and (LAN.empre = CAT.empre) and (LAN.datalancto <= :DataSaldo) '+
                                    'and (CAT.classificacao LIKE :Class) ');
        fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
        fQuery.ParamByName('Class').AsString    := wClass+'%';
        fQuery.ParamByName('DataSaldo').AsDate  := prDataSaldo;
        fQuery.ExecQuery;
        wVlrCre := fQuery.FieldByName('VLR').AsCurrency;
        //
        Result := wVlrDeb - wVlrCre;
      end;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao buscar o saldo da Categoria '+IntToStr(prCategoria)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

end.
