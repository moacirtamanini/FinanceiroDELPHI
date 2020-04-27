unit uFrame_Fone;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, rtFone;

type
  Tframe_Fone = class(TFrame)
    Label1: TLabel;
    Label2: TLabel;
    edFonCenDDD: TEdit;
    edFonCenNRO: TEdit;
    Label3: TLabel;
    edFonComDDD: TEdit;
    edFonComNRO: TEdit;
    Label4: TLabel;
    edFonCelDDD: TEdit;
    edFonCelNRO: TEdit;
    Label5: TLabel;
    edFonFaxDDD: TEdit;
    edFonFaxNRO: TEdit;
  private
    wFone: TFone;
  public
    procedure Carregar(ID: Integer);
    function  fGravar: Integer;
    procedure Limpar;
  published
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

implementation

uses
  uUtils;

{$R *.dfm}

procedure Tframe_Fone.Carregar(ID: Integer);
begin
  wFone.ppID := ID;
  if (wFone.ppID > 0) then
  begin
    edFonCenDDD.Text   := wFone.ppDados.FoneCenDDD;
    edFonCenNRO.Text   := wFone.ppDados.FoneCenNRO;

    edFonComDDD.Text   := wFone.ppDados.FoneComDDD;
    edFonComNRO.Text   := wFone.ppDados.FoneComNRO;

    edFonCelDDD.Text   := wFone.ppDados.FoneCelDDD;
    edFonCelNRO.Text   := wFone.ppDados.FoneCelNRO;

    edFonFaxDDD.Text   := wFone.ppDados.FoneFaxDDD;
    edFonFaxNRO.Text   := wFone.ppDados.FoneFaxNRO;
  end;
end;

constructor Tframe_Fone.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  wFone := TFone.Create;
end;

destructor Tframe_Fone.Destroy;
begin
  wFone.Free;
  Inherited;
end;

function Tframe_Fone.fGravar: Integer;
var
  wDadosFon: TDadosFon;
begin
  wDadosFon.id              := wFone.ppID;
  wDadosFon.FoneCenDDD      := fSomenteNumeros(edFonCenDDD.Text);
  wDadosFon.FoneCenNRO      := fSomenteNumeros(edFonCenNRO.Text);

  wDadosFon.FoneComDDD      := fSomenteNumeros(edFonComDDD.Text);
  wDadosFon.FoneComNRO      := fSomenteNumeros(edFonComNRO.Text);

  wDadosFon.FoneCelDDD      := fSomenteNumeros(edFonCelDDD.Text);
  wDadosFon.FoneCelNRO      := fSomenteNumeros(edFonCelNRO.Text);

  wDadosFon.FoneFaxDDD      := fSomenteNumeros(edFonFaxDDD.Text);
  wDadosFon.FoneFaxNRO      := fSomenteNumeros(edFonFaxNRO.Text);

  wFone.ppDados := wDadosFon;
  Result := wFone.fGravaFone;
end;

procedure Tframe_Fone.Limpar;
begin
  edFonCenDDD.Clear;
  edFonCenNRO.Clear;

  edFonComDDD.Clear;
  edFonComNRO.Clear;

  edFonCelDDD.Clear;
  edFonCelNRO.Clear;

  edFonFaxDDD.Clear;
  edFonFaxNRO.Clear;
end;

end.
 