unit uFrame_CtaREC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, rtTypes, rtCtaREC,
  ExtCtrls, Mask, rxToolEdit, rxCurrEdit;

type
  Tframe_CtaREC = class(TFrame)
    lbFatura: TLabel;
    edFatura: TCurrencyEdit;
    spBusca: TPanel;
    procedure edFaturaExit(Sender: TObject);
    procedure spBuscaClick(Sender: TObject);
  private
    wCtaRec: TCtaRec;
    fDepoisBuscaEvent: TDepoisBuscaEvent;

    function  fGetFatura: Integer;
    procedure pSetFatura(const Value: Integer);
    function  fGetID: Integer;
    procedure pSetID(const Value: Integer);
    function  fGetDados: TDadosREC;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   Clear;

    property  OnDepoisBusca: TDepoisBuscaEvent read fDepoisBuscaEvent write fDepoisBuscaEvent;
    property  Fatura: Integer read fGetFatura write pSetFatura;
    property  ID:     Integer read fGetID     write pSetID;
    property  ppDados: TDadosREC read fGetDados;
  end;

implementation

uses uDataM, FIBQuery, uUtils, ucBrwFaturaCTAREC;

{$R *.dfm}

constructor Tframe_CtaREC.Create(AOwner: TComponent);
begin
  inherited;
  wCtaRec := TCtaRec.Create;
end;

destructor Tframe_CtaREC.Destroy;
begin
  wCtaRec.Free;
  inherited;
end;

procedure Tframe_CtaREC.Clear;
begin
  FillChar(wCtaRec, SizeOf(wCtaRec), #0);
  edFatura.Clear;
end;

function  Tframe_CtaREC.fGetDados: TDadosREC;
begin
  Result := wCtaRec.ppDados;
end;

function  Tframe_CtaREC.fGetFatura: Integer;
begin
  Result := wCtaRec.ppDados.Codigo;
end;

procedure Tframe_CtaREC.pSetFatura(const Value: Integer);
var
  wEncontrou: Boolean;
begin
  wCtaRec.ppCodigo := Value;
  wEncontrou := wCtaRec.ppCodigo > 0;
  edFatura.AsInteger := wCtaRec.ppCodigo;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wEncontrou);
end;

function  Tframe_CtaREC.fGetID: Integer;
begin
  Result := wCtaRec.ppDados.id;
end;

procedure Tframe_CtaREC.pSetID(const Value: Integer);
var
  wEncontrou: Boolean;
begin
  wCtaRec.ppID := Value;
  wEncontrou := wCtaRec.ppCodigo > 0;
  edFatura.AsInteger := wCtaRec.ppCodigo;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wEncontrou);
end;

procedure Tframe_CtaREC.edFaturaExit(Sender: TObject);
begin
  Fatura := StrToIntDef(Trim(edFatura.Text),0)
end;

procedure Tframe_CtaREC.spBuscaClick(Sender: TObject);
begin
  fcBrwFaturaCTAREC := TfcBrwFaturaCTAREC.Create(Self);
  try
    fcBrwFaturaCTAREC.ShowModal;
    if fcBrwFaturaCTAREC.ModalResult = mrOk then
      Fatura := fcBrwFaturaCTAREC.Codigo;
  finally
    FreeAndNil(fcBrwFaturaCTAREC);
  end;
end;

end.
