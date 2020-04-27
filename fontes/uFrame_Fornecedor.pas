unit uFrame_Fornecedor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, rtTypes,
  ExtCtrls, Mask, rtFornecedor, rxToolEdit, rxCurrEdit;

type
  TFrame_Fornecedor = class(TFrame)
    lbCodigo: TLabel;
    edCodigo: TCurrencyEdit;
    spBusca: TPanel;
    procedure edCodigoExit(Sender: TObject);
    procedure spBuscaClick(Sender: TObject);
  private
    wForne: TFornecedor;
    fDepoisBuscaEvent: TDepoisBuscaEvent;
    function  fGetFornecedor: Integer;
    procedure pSetFornecedor(const Value: Integer);
    function  fGetDados: TDadosFor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    OnDepoisBusca: TDepoisBuscaEvent read fDepoisBuscaEvent write fDepoisBuscaEvent;
    property    Fornecedor: Integer read fGetFornecedor write pSetFornecedor;
    property    ppDadosFor: TDadosFor read fGetDados;
  end;

implementation

uses uDataM, FIBQuery, ucBrwForne;

{$R *.dfm}

constructor TFrame_Fornecedor.Create(AOwner: TComponent);
begin
  inherited;
  wForne := TFornecedor.Create;
end;

destructor TFrame_Fornecedor.Destroy;
begin
  wForne.Free;
  inherited;
end;

function TFrame_Fornecedor.fGetFornecedor: Integer;
begin
  Result := wForne.ppCodigo;
end;

function  TFrame_Fornecedor.fGetDados: TDadosFor;
begin
  Result := wForne.ppDados;
end;

procedure TFrame_Fornecedor.pSetFornecedor(const Value: Integer);
var
  wEncontrou: Boolean;
begin
  edCodigo.Clear;
  wForne.ppCodigo := Value;
  wEncontrou := wForne.ppCodigo > 0;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wEncontrou);
end;

procedure TFrame_Fornecedor.edCodigoExit(Sender: TObject);
begin
  Fornecedor := StrToIntDef(Trim(edCodigo.Text),0);
end;

procedure TFrame_Fornecedor.spBuscaClick(Sender: TObject);
begin
  fcBrwForne := TfcBrwForne.Create(Self);
  try
    fcBrwForne.ShowModal;
    if fcBrwForne.ModalResult = mrOk then
    begin
      Fornecedor := fcBrwForne.Codigo;
    end;
  finally
    FreeAndNil(fcBrwForne);
  end;
end;

end.
