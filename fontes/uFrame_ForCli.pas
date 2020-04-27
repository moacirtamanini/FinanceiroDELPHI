unit uFrame_ForCli;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Mask, Menus,
  rtFornecedor, rtCliente, rtTypes, rtCartao;

type
  TFrame_ForCli = class(TFrame)
    lbCodigo: TLabel;
    spBusca: TPanel;
    pnCombo: TPanel;
    edNome: TEdit;
    pmForCli: TPopupMenu;
    mmForne: TMenuItem;
    mmClien: TMenuItem;
    mmIndefi: TMenuItem;
    procedure pnComboClick(Sender: TObject);
    procedure mmIndefiClick(Sender: TObject);
    procedure spBuscaClick(Sender: TObject);
    procedure edNomeExit(Sender: TObject);
  private
    wCliente: TCliente;
    wFornece: TFornecedor;
    fCodigo: Integer;
    fDepoisBuscaEvent: TDepoisBuscaEvent;

    procedure pLimparDados;
    procedure pSetCliente(const Value: Integer);
    procedure pSetFornece(const Value: Integer);

    procedure pSetClienteStr(const Value: String);
    procedure pSetForneceStr(const Value: String);

    procedure pSetTipForCli(const Value: TTipForCli);

    function fGetMoedaTIP: Integer;

    function fGetTipo: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   Clear;

    property    OnDepoisBusca: TDepoisBuscaEvent read fDepoisBuscaEvent write fDepoisBuscaEvent;
    property    Fornece: Integer read fCodigo write pSetFornece;
    property    Cliente: Integer read fCodigo write pSetCliente;
    property    FornStr: String  write pSetForneceStr;
    property    ClieStr: String  write pSetClienteStr;
    property    TipForCli: TTipForCli write pSetTipForCli;

    property    Tipo    : Integer read fGetTipo;
    property    Codigo  : Integer read fCodigo;
    property    MoedaTIP: Integer read fGetMoedaTIP;
  end;

implementation

uses
  uDataM, ucBrwForne, ucBrwCliente, uUtils;

{$R *.dfm}

constructor TFrame_ForCli.Create(AOwner: TComponent);
begin
  inherited;
  wCliente := TCliente.Create;
  wFornece := TFornecedor.Create;
end;

destructor TFrame_ForCli.Destroy;
begin
  wCliente.Free;
  wFornece.Free;
  inherited;
end;

procedure TFrame_ForCli.Clear;
begin
  wCliente.Clear;
  wFornece.Clear;
  pLimparDados;
end;

function  TFrame_ForCli.fGetTipo: Integer;
begin
  Result := -1;
  if mmForne.Checked then Result := 0;
  if mmClien.Checked then Result := 1;
end;

procedure TFrame_ForCli.pnComboClick(Sender: TObject);
begin
  pmForCli.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;

procedure TFrame_ForCli.pLimparDados;
begin
  edNome.Clear;
  mmForne.Checked := True;
  fCodigo := 0;
end;

procedure TFrame_ForCli.mmIndefiClick(Sender: TObject);
begin
  pLimparDados;

  lbCodigo.Caption := 'Indefinido';
  edNome.Enabled   := False;
  spBusca.Enabled  := False;

  if (Sender = mmForne) then
  begin
    mmForne.Checked  := True;
    lbCodigo.Caption := 'Fornecedor';
    edNome.Enabled   := True;
    spBusca.Enabled  := True;
  end;

  if (Sender = mmClien) then
  begin
    mmClien.Checked  := True;
    lbCodigo.Caption := 'Cliente';
    edNome.Enabled   := True;
    spBusca.Enabled  := True;
  end;

  if edNome.Enabled then
    edNome.Color := clWindow
  else
    edNome.Color := clSilver;
end;

procedure TFrame_ForCli.spBuscaClick(Sender: TObject);
begin
  if (mmForne.Checked) then
  begin
    fcBrwForne := TfcBrwForne.Create(Self);
    try
      fcBrwForne.ShowModal;
      if fcBrwForne.ModalResult = mrOk then
      begin
        mmForne.Checked := True;
        Fornece := fcBrwForne.Codigo;
      end;
    finally
      FreeAndNil(fcBrwForne);
    end;
  end;

  if (mmClien.Checked) then
  begin
    fcBrwCliente := TfcBrwCliente.Create(Self);
    try
      fcBrwCliente.ShowModal;
      if fcBrwCliente.ModalResult = mrOk then
      begin
        mmClien.Checked := True;
        Cliente := fcBrwCliente.Codigo;
      end;
    finally
      FreeAndNil(fcBrwCliente);
    end;
  end;
end;

procedure TFrame_ForCli.pSetFornece(const Value: Integer);
begin
  wFornece.ppCodigo := Value;
  edNome.Text := wFornece.ppDados.Nome;
  mmForne.Checked := True;
  fCodigo := Value;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, fCodigo > 0);
end;

procedure TFrame_ForCli.pSetForneceStr(const Value: String);
begin
  wFornece.ppBuscar := Value;
  edNome.Text := wFornece.ppDados.Nome;
  mmClien.Checked := True;
  fCodigo := wFornece.ppDados.Codigo;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, fCodigo > 0);
end;

procedure TFrame_ForCli.pSetCliente(const Value: Integer);
begin
  wCliente.ppCodigo := Value;
  edNome.Text := wCliente.ppDados.Nome;
  mmClien.Checked := True;
  fCodigo := Value;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, fCodigo > 0);
end;

procedure TFrame_ForCli.pSetClienteStr(const Value: String);
begin
  wCliente.ppBuscar := Value;
  edNome.Text := wCliente.ppDados.Nome;
  mmClien.Checked := True;
  fCodigo := wCliente.ppDados.Codigo;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, fCodigo > 0);
end;

procedure TFrame_ForCli.pSetTipForCli(const Value: TTipForCli);
begin
  case Value.Tipo of
    0: pSetFornece(Value.Codi);
    1: pSetCliente(Value.Codi);
  end;
end;

procedure TFrame_ForCli.edNomeExit(Sender: TObject);
var
  wStr: String;
  NCod: Integer;
begin
  wStr := edNome.Text;
  if Length(Trim(wStr)) > 0 then
  begin
    NCod := StrToIntDef(Trim(edNome.Text),0);
    if (NCod > 0) then
    begin
      case Tipo of
        0: pSetFornece(NCod);
        1: pSetCliente(NCod);
      end;
    end;

    if Codigo = 0 then
    begin
      if (Length(Trim(wStr)) > 0) then
      begin
        case Tipo of
          0: pSetForneceStr(wStr);
          1: pSetClienteStr(wStr);
        end;
      end;
    end;
  end;
end;

function TFrame_ForCli.fGetMoedaTIP: Integer;
begin
  Result := 0;
  case Tipo of
    0: Result := wFornece.ppDados.MoedaTIP;
    1: Result := wCliente.ppDados.MoedaTIP;
  end;
end;

end.
