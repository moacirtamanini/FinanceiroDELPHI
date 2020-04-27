unit ucCtaPagLanParceAlt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, uFrame_Cartao,
  uFrame_Moeda, Mask, rtCartao, rtTypes, rxToolEdit;

type
  TfcCtaPagLanParceAlt = class(TfcPadrao)
    Frame_Moeda: TFrame_Moeda;
    Frame_Cartao: TFrame_Cartao;
    Label5: TLabel;
    edDataVencto: TDateEdit;
    btnOK: TBitBtn;
    procedure btnSairClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure Frame_MoedacbMoedaChange(Sender: TObject);
    procedure edDataVenctoKeyPress(Sender: TObject; var Key: Char);
  private
    wDataVencto: TDateTime;
    wTpDebCre, wMoeda: Integer;
  public
    property ppDataVencto: TDateTime  read wDataVencto;
    property ppMoeda     : Integer    read wMoeda;
    property ppTpDebCre  : Integer    read wTpDebCre;
  end;

var
  fcCtaPagLanParceAlt: TfcCtaPagLanParceAlt;

implementation

{$R *.dfm}

procedure TfcCtaPagLanParceAlt.btnSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  inherited;
end;

procedure TfcCtaPagLanParceAlt.btnOKClick(Sender: TObject);
begin
  if (edDataVencto.Date < cDataMinima) or (edDataVencto.Date > cDataMaxima) then
  begin
    MessageDlg('A data de vencimento informada está fora do período de aceitação', mtWarning, [mbOk], 0);
    Exit;
  end;

  if Frame_Moeda.ppMoeda < 0 then
  begin
    MessageDlg('O tipo de moeda não foi informado', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (Frame_Moeda.ppMoeda = 3) or (Frame_Moeda.ppMoeda = 4) then
  begin
    if (Frame_Cartao.Codigo < 1) then
    begin
      MessageDlg('O cartão de crédito / débito não foi informado', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  wDataVencto     := edDataVencto.Date;
  wMoeda          := Frame_Moeda.ppMoeda;
  wTpDebCre       := Frame_Cartao.TpDebCre;
  ModalResult     := mrOk;
  inherited;
end;

procedure TfcCtaPagLanParceAlt.Frame_MoedacbMoedaChange(Sender: TObject);
begin
  inherited;
  Frame_Cartao.Enabled := (Frame_Moeda.ppMoeda = 3) or (Frame_Moeda.ppMoeda = 4);
end;

procedure TfcCtaPagLanParceAlt.edDataVenctoKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #13 Then
  begin
    if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
      SelectNext(Sender as TWinControl, False, True)
    else
      SelectNext(Sender as TWinControl, True, True);
    Key := #0
  end;

  if Key = #27 Then
  begin
    if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
      SelectNext(Sender as TWinControl, True, True)
    else
      SelectNext(Sender as TWinControl, False, True);
    Key := #0
  end;
end;

end.
 