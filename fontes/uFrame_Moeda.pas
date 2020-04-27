unit uFrame_Moeda;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls;

type
  TFrame_Moeda = class(TFrame)
    cbMoeda: TComboBox;
    lbMoeda: TLabel;
  private
    function  fGetMoeda: Integer;
    procedure pSetMoeda(const Value: Integer);
  public
    property ppMoeda: Integer read fGetMoeda write pSetMoeda;
  end;

implementation

{$R *.dfm}

function TFrame_Moeda.fGetMoeda: Integer;
begin
  Result := cbMoeda.ItemIndex;
end;

procedure TFrame_Moeda.pSetMoeda(const Value: Integer);
begin
  cbMoeda.ItemIndex := Value;
end;

end.
