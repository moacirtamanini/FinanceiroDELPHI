unit ucPadrao;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfcPadrao = class(TForm)
    pnTop: TPanel;
    pnBtns: TPanel;
    btnSair: TBitBtn;
    procedure btnSairClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
  end;

var
  fcPadrao: TfcPadrao;

implementation

uses
  uUtils;

{$R *.dfm}

procedure TfcPadrao.btnSairClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfcPadrao.FormShow(Sender: TObject);
begin
  RestoreFormPos(Self.Handle);
end;

procedure TfcPadrao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormPos(Self.Handle);
end;

end.
