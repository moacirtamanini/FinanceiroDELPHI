unit uFrame_Cartao;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Mask, Menus,
  rtCartao, rtTypes;

type
  TFrame_Cartao = class(TFrame)
    lbCodigo: TLabel;
    edCartao: TEdit;
    spBusca: TPanel;
    procedure spBuscaClick(Sender: TObject);
    procedure edCartaoExit(Sender: TObject);
  private
    wCartao : TCartao;
    fTpDebCre, fCodigo: Integer;
    fDepoisBuscaEvent: TDepoisBuscaEvent;

    procedure pLimparDados;

    function  fGetCodigo: Integer;
    procedure pSetCodigo(const Value: Integer);

    function  fGetDescri: String;
    procedure pSetDescri(const Value: String);

    function  getCategDeb: Integer;
    function  getCategCre: Integer;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   Clear;
    procedure   pRepaint;
    property    OnDepoisBusca: TDepoisBuscaEvent read fDepoisBuscaEvent write fDepoisBuscaEvent;

    property ppCodigo:  Integer read fGetCodigo write pSetCodigo;
    property ppDescri:  string read fGetDescri  write pSetDescri;

    property TpDebCre: Integer read fTpDebCre;
    property Codigo  : Integer read fCodigo;
    property CategDeb: Integer read getCategDeb;
    property CategCre: Integer read getCategCre;
  end;

implementation

uses
  uDataM, ucBrwCartaoDebCre, uUtils;

{$R *.dfm}

constructor TFrame_Cartao.Create(AOwner: TComponent);
begin
  inherited;
  wCartao  := TCartao.Create;
end;

destructor TFrame_Cartao.Destroy;
begin
  wCartao.Free;
  inherited;
end;

procedure TFrame_Cartao.Clear;
begin
  pLimparDados;
end;

procedure TFrame_Cartao.pLimparDados;
begin
  wCartao.Clear;
  edCartao.Clear;
  fTpDebCre := -1;
  fCodigo   := -1;
  edCartao.Enabled  := False;
  edCartao.Color    := clSilver;
  spBusca.Color     := clSilver;
end;

procedure TFrame_Cartao.spBuscaClick(Sender: TObject);
begin
  fSetaFoco([edCartao]);
  fcBrwCartaoDebCre := TfcBrwCartaoDebCre.Create(Self);
  try
    fcBrwCartaoDebCre.ShowModal;
    if fcBrwCartaoDebCre.ModalResult = mrOk then
      pSetCodigo(fcBrwCartaoDebCre.Codigo);
  finally
    FreeAndNil(fcBrwCartaoDebCre);
    fSetaFoco([edCartao]);
  end;
end;

function  TFrame_Cartao.fGetCodigo: Integer;
begin
  Result := wCartao.ppCodigo;
end;

procedure TFrame_Cartao.pSetCodigo(const Value: Integer);
begin
  wCartao.ppCodigo := Value;
  edCartao.Text := wCartao.ppDados.Descricao;
  fTpDebCre := 1;
  fCodigo   := wCartao.ppCodigo;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wCartao.ppCodigo > 0);
end;

procedure TFrame_Cartao.pSetDescri(const Value: String);
begin
  wCartao.ppDescri := Value;
  edCartao.Text := wCartao.ppDados.Descricao;
  fTpDebCre := 0;
  fCodigo   := wCartao.ppCodigo;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wCartao.ppCodigo > 0);
end;

function  TFrame_Cartao.fGetDescri: String;
begin
  Result := wCartao.ppDados.Descricao;
end;

procedure TFrame_Cartao.edCartaoExit(Sender: TObject);
var
  wStr: String;
  NCod: Integer;
begin
  wStr := edCartao.Text;
  pLimparDados;

  if Length(Trim(wStr)) > 0 then
  begin
    NCod := StrToIntDef(Trim(wStr),0);
    if (NCod > 0) then
       pSetCodigo(NCod)
    else
      if (Length(Trim(wStr)) > 0) then
        pSetDescri(wStr);
  end;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, Codigo > 0);
end;

function  TFrame_Cartao.getCategDeb: Integer;
begin
  Result := wCartao.ppDados.CategoriaDeb;
end;

function  TFrame_Cartao.getCategCre: Integer;
begin
  Result := wCartao.ppDados.CategoriaCre;
end;

procedure TFrame_Cartao.pRepaint;
begin
  if Self.Enabled then
  begin
    edCartao.Color := clWindow;
    spBusca.Color  := $00C08000;
  end
  else
  begin
    edCartao.Color := clSilver;
    spBusca.Color  := clSilver;
  end;
  edCartao.Invalidate;
end;

end.
