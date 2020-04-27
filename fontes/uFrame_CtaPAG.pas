unit uFrame_CtaPAG;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, rtTypes, rtCtaPAG,
  ExtCtrls, Mask, rxToolEdit, rxCurrEdit;

type
  Tframe_CtaPAG = class(TFrame)
    lbFatura: TLabel;
    spBusca: TPanel;
    edFatura: TCurrencyEdit;
    procedure edFaturaExit(Sender: TObject);
    procedure spBuscaClick(Sender: TObject);
  private
    wCtaPag: TCtaPag;
    fDepoisBuscaEvent: TDepoisBuscaEvent;

    function  fGetFatura: Integer;
    procedure pSetFatura(const Value: Integer);
    function  fGetID: Integer;
    procedure pSetID(const Value: Integer);
    function  fGetDados: TDadosPAG;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   Clear;

    property  OnDepoisBusca: TDepoisBuscaEvent read fDepoisBuscaEvent write fDepoisBuscaEvent;
    property  Fatura: Integer read fGetFatura write pSetFatura;
    property  ID:     Integer read fGetID     write pSetID;
    property  ppDados: TDadosPAG read fGetDados;
  end;

implementation

uses uDataM, FIBQuery, ucBrwFaturaCTAPAG, uUtils;

{$R *.dfm}

constructor Tframe_CtaPAG.Create(AOwner: TComponent);
begin
  inherited;
  wCtaPag := TCtaPag.Create;
end;

destructor Tframe_CtaPAG.Destroy;
begin
  wCtaPag.Free;
  inherited;
end;

procedure Tframe_CtaPAG.Clear;
begin
  FillChar(wCtaPag, SizeOf(wCtaPag), #0);
  edFatura.Clear;
end;

function  Tframe_CtaPAG.fGetDados: TDadosPAG;
begin
  Result := wCtaPag.ppDados;
end;

function  Tframe_CtaPAG.fGetFatura: Integer;
begin
  Result := wCtaPag.ppDados.Codigo;
end;

procedure Tframe_CtaPAG.pSetFatura(const Value: Integer);
var
  wEncontrou: Boolean;
begin
  wCtaPag.ppCodigo := Value;
  wEncontrou := wCtaPag.ppCodigo > 0;
  edFatura.AsInteger := wCtaPag.ppCodigo;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wEncontrou);
end;

function  Tframe_CtaPAG.fGetID: Integer;
begin
  Result := wCtaPag.ppDados.id;
end;

procedure Tframe_CtaPAG.pSetID(const Value: Integer);
var
  wEncontrou: Boolean;
begin
  wCtaPag.ppID := Value;
  wEncontrou := wCtaPag.ppCodigo > 0;
  edFatura.AsInteger := wCtaPag.ppCodigo;

  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wEncontrou);
end;

procedure Tframe_CtaPAG.edFaturaExit(Sender: TObject);
begin
  Fatura := StrToIntDef(Trim(edFatura.Text),0)
end;

procedure Tframe_CtaPAG.spBuscaClick(Sender: TObject);
begin
  fcBrwFaturaCTAPAG := TfcBrwFaturaCTAPAG.Create(Self);
  try
    fcBrwFaturaCTAPAG.ShowModal;
    if fcBrwFaturaCTAPAG.ModalResult = mrOk then
      Fatura := fcBrwFaturaCTAPAG.Codigo;
  finally
    FreeAndNil(fcBrwFaturaCTAPAG);
  end;
end;

end.
