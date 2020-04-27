unit uFrame_Cliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, rtTypes,
  ExtCtrls, Mask, rtCliente, rxToolEdit, rxCurrEdit;

type
  TFrame_Cliente = class(TFrame)
    lbCodigo: TLabel;
    edCodigo: TCurrencyEdit;
    spBusca: TPanel;
    procedure edCodigoExit(Sender: TObject);
    procedure spBuscaClick(Sender: TObject);
  private
    wCliente: TCliente;
    fDepoisBuscaEvent: TDepoisBuscaEvent;
    function  fGetCliente: Integer;
    procedure pSetCliente(const Value: Integer);
    function  fGetDados: TDadosCli;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    OnDepoisBusca: TDepoisBuscaEvent read fDepoisBuscaEvent write fDepoisBuscaEvent;
    property    Cliente: Integer read fGetCliente write pSetCliente;
    property    ppDadosCli: TDadosCli read fGetDados;
  end;

implementation

uses uDataM, FIBQuery, ucBrwCliente, uUtils;

{$R *.dfm}

constructor TFrame_Cliente.Create(AOwner: TComponent);
begin
  inherited;
  wCliente := TCliente.Create;
end;

destructor TFrame_Cliente.Destroy;
begin
  wCliente.Free;
  inherited;
end;

function TFrame_Cliente.fGetCliente: Integer;
begin
  Result := wCliente.ppCodigo;
end;

function  TFrame_Cliente.fGetDados: TDadosCli;
begin
  Result := wCliente.ppDados;
end;

procedure TFrame_Cliente.pSetCliente(const Value: Integer);
var
  wEncontrou: Boolean;
begin
  edCodigo.Clear;
  wCliente.ppCodigo := Value;
  wEncontrou := wCliente.ppCodigo > 0;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wEncontrou);
end;

procedure TFrame_Cliente.edCodigoExit(Sender: TObject);
begin
  Cliente := StrToIntDef(Trim(edCodigo.Text),0);
end;

procedure TFrame_Cliente.spBuscaClick(Sender: TObject);
begin
  fcBrwCliente := TfcBrwCliente.Create(Self);
  try
    fcBrwCliente.ShowModal;
    if fcBrwCliente.ModalResult = mrOk then
    begin
      Cliente := fcBrwCliente.Codigo;
    end;
  finally
    FreeAndNil(fcBrwCliente);
  end;
end;

end.
