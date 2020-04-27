unit uFrame_Endereco;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, Mask, rtEndereco;

type
  Tframe_Endereco = class(TFrame)
    Label2: TLabel;
    edCEP: TEdit;
    Label3: TLabel;
    edLogradouro: TEdit;
    Label4: TLabel;
    edNumero: TEdit;
    edUF: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    edCidade: TEdit;
    Label7: TLabel;
    edBairro: TEdit;
    Label8: TLabel;
    edComplemento: TEdit;
    lbEmail: TLabel;
    edEmail: TEdit;
    Label10: TLabel;
    edSite: TEdit;
    Label1: TLabel;
  private
    wEndereco: TEndereco;
  public
    procedure Carregar(ID: Integer);
    function  fGravar: Integer;
    procedure Limpar;
    procedure pMostrarEmail(const Value: Boolean);
  published
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

implementation

uses
  uUtils;

{$R *.dfm}

{ Tframe_Endereco }

procedure Tframe_Endereco.Carregar(ID: Integer);
begin
  wEndereco.ppID := ID;
  if (wEndereco.ppID > 0) then
  begin
    edCEP.Text         := wEndereco.ppDados.CEP;
    edLogradouro.Text  := wEndereco.ppDados.Logradouro;
    edNumero.Text      := wEndereco.ppDados.Numero;
    edBairro.Text      := wEndereco.ppDados.Bairro;
    edCidade.Text      := wEndereco.ppDados.Cidade;
    edUF.Text          := wEndereco.ppDados.UF;
    edComplemento.Text := wEndereco.ppDados.Complemento;
    edEmail.Text       := wEndereco.ppDados.Email;
    edSite.Text        := wEndereco.ppDados.Site;
  end;
end;

constructor Tframe_Endereco.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  wEndereco := TEndereco.Create;
end;

destructor Tframe_Endereco.Destroy;
begin
  wEndereco.Free;
  Inherited;
end;

function Tframe_Endereco.fGravar: Integer;
var
  wDadosEnd: TDadosEnd;
begin
  wDadosEnd.id          := wEndereco.ppID;
  wDadosEnd.CEP         := fSomenteNumeros(edCEP.Text);
  wDadosEnd.UF          := edUF.Text;
  wDadosEnd.Cidade      := edCidade.Text;
  wDadosEnd.Logradouro  := edLogradouro.Text;
  wDadosEnd.Numero      := edNumero.Text;
  wDadosEnd.Bairro      := edBairro.Text;
  wDadosEnd.Complemento := edComplemento.Text;
  wDadosEnd.Email       := edEmail.Text;
  wDadosEnd.Site        := edSite.Text;
  wEndereco.ppDados     := wDadosEnd;
  Result := wEndereco.fGravaEndereco;
end;

procedure Tframe_Endereco.Limpar;
begin
  edCEP.Clear;
  edLogradouro.Clear;
  edNumero.Clear;
  edBairro.Clear;
  edCidade.Clear;
  edUF.Clear;
  edComplemento.Clear;
  edEmail.Clear;
  edSite.Clear;
end;

procedure Tframe_Endereco.pMostrarEmail(const Value: Boolean);
begin
  lbEmail.Visible := Value;
  edEmail.Visible := Value;
end;

end.
