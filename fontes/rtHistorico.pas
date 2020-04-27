unit rtHistorico;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, rtTypes;

type
  TDadosHis = packed record
    id         : Integer;
    Empre      : Integer;
    Codigo     : Integer;
    Descricao  : String;
    Status     : Integer;
  end;

  THistorico = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosHis: TDadosHis;
    function  getCodigo: Integer;
    procedure setCodigo(const Value: Integer);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;
    function    fGravar: Integer;
    function    fExcluir(var prErro: String): Boolean;
    function    fDesativar(var prErro: String): Boolean;
    property ppDados: TDadosHis read fDadosHis write fDadosHis;
    property ppCodigo: Integer read getCodigo write setCodigo;
end;

implementation

uses uDataM, FIBQuery;

constructor THistorico.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor THistorico.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure THistorico.Clear;
begin
  FillChar(fDadosHis, SizeOf(fDadosHis), #0);
end;

function THistorico.getCodigo: Integer;
begin
  Result := fDadosHis.Codigo;
end;

procedure THistorico.setCodigo(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM Historico '+
                                'WHERE Empre = :Empre and Codigo = :Codigo');
    fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
    fQuery.ParamByName('Codigo').AsInteger  := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosHis.id            := fQuery.FieldByName('id').AsInteger;
      fDadosHis.Empre         := fQuery.FieldByName('Empre').AsInteger;
      fDadosHis.Codigo        := fQuery.FieldByName('Codigo').AsInteger;
      fDadosHis.Descricao     := fQuery.FieldByName('Descricao').AsString;
      fDadosHis.Status        := fQuery.FieldByName('Status').AsInteger;
    end;
  end;
end;

function THistorico.fGravar: Integer;

  function fGeraCodigo: Integer;
  var
    wQueryLoc: TpFIBQuery;
    wTransLoc: TpFIBTransaction;
  begin
    FIBQueryCriar(wQueryLoc, wTransLoc);
    try
      FIBQueryAtribuirSQL(wQueryLoc, 'SELECT coalesce(max(Codigo),0)+1 from Historico where '+
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
  Result := 0;
  wExiste:= False;

  if fDataM.Empresa < 1 then
  begin
    MessageDlg('A empresa deve ser maior que zero!', mtWarning, [mbOk], 0);
    Exit;
  end;

  try
    try
      if (fDadosHis.Codigo > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from Historico '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre');
        fQuery.ParamByName('Codigo').AsInteger  := fDadosHis.Codigo;
        fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof);
        fDadosHis.id := fQuery.FieldByName('id').AsInteger;
      end;

      if (fDadosHis.Codigo > 0) and (wExiste) then
        FIBQueryAtribuirSQL(fQuery, 'UPDATE Historico '+
                                    'SET Descricao = :Descricao, '+
                                    '    Status = :Status  '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre')
      else
      begin
        if (not wExiste) and ((fDadosHis.Codigo = 0) or (fDadosHis.Codigo > fGetMax('historico','Codigo',True))) then
          fDadosHis.Codigo := fGeraCodigo;

        if (not wExiste) then
          fDadosHis.id := fGetGenerator('GEN_HISTORICO');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Historico ( id,  Empre,  Codigo,  Descricao,  Status) '+
                                    '               VALUES (:ID, :Empre, :Codigo, :Descricao, :Status) ');
        fQuery.ParamByName('id').AsInteger       := fDadosHis.id;
      end;
      //
      fQuery.ParamByName('Empre').AsInteger      := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger     := fDadosHis.Codigo;
      fQuery.ParamByName('Descricao').AsString   := fDadosHis.Descricao;
      fQuery.ParamByName('Status').AsInteger     := fDadosHis.Status;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosHis.id := 0;
        MessageDlg('Erro ao gravar o Histórico!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosHis.id;
  end;
end;

function THistorico.fDesativar(var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  wRotina := 0;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Historico WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger    := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger   := fDadosHis.Codigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O histórico '+IntToStr(fDadosHis.Codigo)+' não foi encontrado para desativação.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE Historico SET Status = :Status '+
                                  '       WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger  := fDadosHis.Codigo;
      fQuery.ParamByName('Status').AsInteger  := 0;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao desativar o Histórico '+IntToStr(fDadosHis.Codigo)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function THistorico.fExcluir(var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  wRotina := 0;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM Historico WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := fDadosHis.Codigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O histórico '+IntToStr(fDadosHis.Codigo)+' não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT Count(*) AS QTDE FROM Lancamento WHERE Empre = :Empre and HistoCod = :HistoCod');
      fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger  := fDadosHis.Codigo;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        prErro := 'O histórico '+IntToStr(fDadosHis.Codigo)+' não pode ser excluído.'+Eol+
                  'Está sendo usado em '+fQuery.FieldByName('QTDE').AsString+' Lançamentos';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'DELETE FROM Historico WHERE Empre = :Empre and Codigo = :Codigo');
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := fDadosHis.Codigo;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao excluir o Histórico '+IntToStr(fDadosHis.Codigo)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

end.
