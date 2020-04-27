unit uFrame_Bandeira;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls;

type
  Tframe_Bandeira = class(TFrame)
    cbBandeira: TComboBox;
    Label1: TLabel;
  private
    function  fGetCodigo: Integer;
    procedure pSetCodigo(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
    property ppCodigo: Integer read fGetCodigo write pSetCodigo;
  end;

implementation

{$R *.dfm}

uses uDataM, uUtils;

{ Tframe_Bandeira }

constructor Tframe_Bandeira.Create(AOwner: TComponent);
begin
  inherited;
  pPreencheCombo(cbBandeira, 'Bandeira', 'Id', 'Descricao', False);
end;

procedure Tframe_Bandeira.Clear;
begin
  cbBandeira.ItemIndex := -1;
end;

function Tframe_Bandeira.fGetCodigo: Integer;
begin
  Result := fGetCodigoCombo(cbBandeira);
end;

procedure Tframe_Bandeira.pSetCodigo(const Value: Integer);
begin
  pSetCodigoCombo(cbBandeira, Value);
end;

end.
