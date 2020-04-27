unit uFrame_Categoria;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, rtTypes,
  pFIBDatabase, pFIBQuery, ExtCtrls;

type
  Tframe_Categoria = class(TFrame)
    lbCodigo: TLabel;
    edCodigo: TEdit;
    spBusca: TPanel;
    procedure edCodigoExit(Sender: TObject);
    procedure spBuscaClick(Sender: TObject);
    procedure edCodigoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FContaTIP: Integer;
    FAtiva   : Boolean;
    FCodLon, FApelido, FDescricao: String;
    FHabilitado, FCongelado, F_AceitaNaoCad, F_ACeitaContaSintetica, F_SomenteAnalitica: Boolean;
    F_FiltroClassi: String;

    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;

    procedure pChamaTelaCadastro;

    procedure pSetCodigo(const Value: Integer);
    function  fGetCodigo: Integer;
    procedure pSetCodLon(const Value: String);
    function  fGetCodLon: String;
    procedure pSetApelido(const Value: String);
    function  fGetApelido: String;
    procedure pSetDescricao(const Value: String);
    function  fGetDescricao: String;
    procedure SetHabilitado(const Value: Boolean);
    procedure SetCongelado(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure Clear;
    function  IsValid: Boolean;

    property  Codigo: Integer read fGetCodigo write pSetCodigo;
    property  CodLon: String read fGetCodLon write pSetCodLon;
    property  Apelido: String read fGetApelido write pSetApelido;
    property  Descricao: String read fGetDescricao write pSetDescricao;
    property  ContaTIP: Integer read FContaTIP;
    property  Ativo: Boolean read FAtiva;
    property  Habilitado: Boolean read FHabilitado write SetHabilitado;
    property  Congelado: Boolean read FCongelado write SetCongelado;
    property  AceitaNaoCadastrado: Boolean read F_ACeitaNaoCad write F_AceitaNaoCad;
    property  AceitaContaSintetica: Boolean read F_ACeitaContaSintetica write F_ACeitaContaSintetica;
    property  SomenteAnalitica: Boolean read F_SomenteAnalitica write F_SomenteAnalitica;
    property  FiltroClassi: String read F_FiltroClassi write F_FiltroClassi;
  end;

implementation

uses uDataM, uUtils, ucBrwCategoria, ucCadCategoria;

{$R *.dfm}

constructor Tframe_Categoria.Create(AOwner: TComponent);
begin
  inherited;
  F_AceitaNaoCad         := False;
  F_ACeitaContaSintetica := False;
  F_SomenteAnalitica     := False;
  FIBQueryCriar(fQuery, fTrans);
end;

destructor Tframe_Categoria.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure Tframe_Categoria.Clear;
begin
   edCodigo.Text := '';
   FContaTIP     := -1;
   FCodLon       := '';
   FAtiva        := False;
end;

function  Tframe_Categoria.IsValid: Boolean;
begin
  if (AceitaContaSintetica) and (F_FiltroClassi = '') then
    Result := fEstaCadastrado(Codigo, 'Categoria', 'Codigo', True)
  else
  begin
    if (F_FiltroClassi = '') then
      Result := (FContaTIP = 1) and (fEstaCadastrado(Codigo, 'Categoria', 'Codigo', True))
    else
    begin
      FIBQueryAtribuirSQL(fQuery, 'SELECT * from Categoria '+
                                  ' where (Empre = :Empre) and (Codigo = :Codigo) '+F_FiltroClassi);
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Codigo').AsInteger := Codigo;
      fQuery.ExecQuery;
      Result := (not fQuery.Eof);
    end;
  end;
end;

procedure Tframe_Categoria.pSetCodigo(const Value: Integer);
begin
  edCodigo.Text := '';
  if AceitaNaoCadastrado then
    edCodigo.Text := IntToStr(Value) + '-';

  try
    FIBQueryAtribuirSQL(fQuery, 'SELECT * from Categoria '+
                                ' where (Empre = :Empre) and (Codigo = :Codigo) '+F_FiltroClassi);
    fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
    fQuery.ParamByName('Codigo').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      FContaTIP      := fQuery.FieldByName('ContaTIP').AsInteger;
      FAtiva         := fQuery.FieldByName('Status').AsInteger = 1;
      FCodLon        := fQuery.FieldByName('Classificacao').AsString;
      FApelido       := fQuery.FieldByName('Apelido').AsString;
      FDescricao     := fQuery.FieldByName('Descricao').AsString;
      edCodigo.Text  := IntToStr(fQuery.FieldByName('Codigo').AsInteger) + ' - ' + fQuery.FieldByName('Classificacao').AsString + ' - ' + fQuery.FieldByName('Descricao').AsString;
    end
    else
    begin
      FContaTIP      := -1;
      FAtiva        := False;
      if AceitaNaoCadastrado then
        edCodigo.Text := IntToStr(Value) + ' - - ';
    end;
  except
    on E: Exception do
    begin
      MessageDlg('Erro ao buscar a Categoria pelo código: '+IntToStr(Value)+eol+e.Message, mtWarning, [mbOk], 0);
    end;
  end;
end;

function  Tframe_Categoria.fGetCodigo: Integer;
begin
  Result := StrToIntDef(Trim(StrBefore(edCodigo.Text,'-')),0);
end;

procedure Tframe_Categoria.pSetCodLon(const Value: String);
begin
  edCodigo.Text := '';
  if Length(Trim(Value)) > 0 then
  begin
    try
      FIBQueryAtribuirSQL(fQuery, 'SELECT * from Categoria '+
                                  ' where (Empre = :Empre) and (Classificacao = :Classificacao) '+F_FiltroClassi);
      fQuery.ParamByName('Empre').AsInteger        := fDataM.Empresa;
      fQuery.ParamByName('Classificacao').AsString := Value;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        FContaTIP      := fQuery.FieldByName('ContaTIP').AsInteger;
        FAtiva         := fQuery.FieldByName('Status').AsInteger = 1;
        FCodLon        := fQuery.FieldByName('Classificacao').AsString;
        FApelido       := fQuery.FieldByName('Apelido').AsString;
        FDescricao     := fQuery.FieldByName('Descricao').AsString;
        edCodigo.Text  := IntToStr(fQuery.FieldByName('Codigo').AsInteger) + ' - ' + fQuery.FieldByName('Classificacao').AsString + ' - ' + fQuery.FieldByName('Descricao').AsString;
      end
      else
      begin
        FContaTIP      := -1;
        FAtiva        := False;
      end;
    except
      on E: Exception do
      begin
        MessageDlg('Erro ao buscar a Categoria pela classificação: '+Value+eol+e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  end;
end;

function  Tframe_Categoria.fGetCodLon: String;
begin
  Result := FCodLon;
end;

procedure Tframe_Categoria.pSetApelido(const Value: String);
begin
  edCodigo.Text := '';
  if Length(Trim(Value)) > 0 then
  begin
    try
      FIBQueryAtribuirSQL(fQuery, 'SELECT * from Categoria '+
                                  ' where (Empre = :Empre) and (Apelido = :Apelido) ' + F_FiltroClassi);
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Apelido').AsString := Value;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        FContaTIP      := fQuery.FieldByName('ContaTIP').AsInteger;
        FAtiva         := fQuery.FieldByName('Status').AsInteger = 1;
        FCodLon        := fQuery.FieldByName('Classificacao').AsString;
        FApelido       := fQuery.FieldByName('Apelido').AsString;
        FDescricao     := fQuery.FieldByName('Descricao').AsString;
        edCodigo.Text  := IntToStr(fQuery.FieldByName('Codigo').AsInteger) + ' - ' + fQuery.FieldByName('Classificacao').AsString + ' - ' + fQuery.FieldByName('Descricao').AsString;
      end
      else
      begin
        FContaTIP      := -1;
        FAtiva        := False;
      end;
    except
      on E: Exception do
      begin
        MessageDlg('Erro ao buscar a Categoria pelo apelido: '+Value+eol+e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  end;
end;

function  Tframe_Categoria.fGetApelido: String;
begin
  Result := FApelido;
end;

procedure Tframe_Categoria.pSetDescricao(const Value: String);
begin
  edCodigo.Text := '';
  if Length(Trim(Value)) > 0 then
  begin
    try
      FIBQueryAtribuirSQL(fQuery, 'SELECT * from Categoria '+
                                  ' where (Empre = :Empre) and (Descricao = :Descricao) '+ F_FiltroClassi);
      fQuery.ParamByName('Empre').AsInteger    := fDataM.Empresa;
      fQuery.ParamByName('Descricao').AsString := Value;
      fQuery.ExecQuery;
      if (not fQuery.Eof) then
      begin
        FContaTIP      := fQuery.FieldByName('ContaTIP').AsInteger;
        FAtiva         := fQuery.FieldByName('Status').AsInteger = 1;
        FCodLon        := fQuery.FieldByName('Classificacao').AsString;
        FApelido       := fQuery.FieldByName('Apelido').AsString;
        FDescricao     := fQuery.FieldByName('Descricao').AsString;
        edCodigo.Text  := IntToStr(fQuery.FieldByName('Codigo').AsInteger) + ' - ' + fQuery.FieldByName('Classificacao').AsString + ' - ' + fQuery.FieldByName('Descricao').AsString;
      end
      else
      begin
        FContaTIP      := -1;
        FAtiva        := False;
      end;
    except
      on E: Exception do
      begin
        MessageDlg('Erro ao buscar a Categoria pela descrição: '+Value+eol+e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  end;
end;

function  Tframe_Categoria.fGetDescricao: String;
begin
   Result := FDescricao;
end;

procedure Tframe_Categoria.SetHabilitado(const Value: Boolean);
begin
  FHabilitado         := Value;
  Self.Enabled        := Value;
  edCodigo.Enabled    := Value;
  spBusca.Enabled     := Value;

  if edCodigo.Enabled then
    edCodigo.Color   := clWindow
  else
    edCodigo.Color   := clSilver;
end;

procedure Tframe_Categoria.SetCongelado(const Value: Boolean);
begin
  FCongelado        := Value;
  lbCodigo.Enabled  := not Value;
  edCodigo.Enabled  := not Value;
  spBusca.Enabled   := not Value;
end;

procedure Tframe_Categoria.edCodigoExit(Sender: TObject);
var
  wStr: String;
  NCur: Integer;
  NLon: String;
begin
  wStr := edCodigo.Text;
  NLon := '';
  //
  if Length(Trim(wStr)) > 0 then
  begin
    NCur   := StrToIntDef(Trim(StrBefore(edCodigo.Text,'-')),0);
    Codigo := NCur;
    //
    if Codigo = 0 then
    begin
      if (Pos('.', wStr) > 0) then
      begin
        NLon := wStr;
        CodLon := NLon;
      end;
    end;
    //
    if Codigo = 0 then
      Apelido := wStr;
    //
    if Codigo = 0 then
      Descricao := wStr;
  end;
  //
  if Codigo > 0 then
  begin
    if (not AceitaContaSintetica) and (FContaTIP <> 1) then
    begin
      MessageDlg('Conta sintética - Não pode ser usada em lançamentos', mtInformation, [mbOk], 0);
      Codigo := 0;
      fSetaFoco([edCodigo]);
    end;
  end;
end;

procedure Tframe_Categoria.spBuscaClick(Sender: TObject);
begin
  fcBrwCategoria := TfcBrwCategoria.Create(Self, F_FiltroClassi);
  try
    fcBrwCategoria.ShowModal;
    if fcBrwCategoria.ModalResult = mrOk then
    begin
      Codigo := fcBrwCategoria.Codigo;
    end;
  finally
    FreeAndNil(fcBrwCategoria);
  end;
end;

procedure Tframe_Categoria.edCodigoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F2) then
    spBuscaClick(Sender);
  if (Key = VK_F6) then
    pChamaTelaCadastro;
end;

procedure Tframe_Categoria.pChamaTelaCadastro;
begin
  if fInicializaForm(TForm(fcCadCategoria)) then
    fcCadCategoria := TfcCadCategoria.Create(Self);
  fcCadCategoria.Show;
end;

end.
