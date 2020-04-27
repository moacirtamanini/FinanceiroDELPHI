unit ucCtaRecBai;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, rtCtaRec, Mask,
  uFrame_Historico, rtTypes, rxCurrEdit, rxToolEdit;

type
  TfcCtaRecBai = class(TfcPadrao)
    Label1: TLabel;
    edDataBaixa: TDateEdit;
    Label2: TLabel;
    edVlrPri: TCurrencyEdit;
    Label3: TLabel;
    edVlrJur: TCurrencyEdit;
    Label4: TLabel;
    edVlrMul: TCurrencyEdit;
    Label5: TLabel;
    edVlrDes: TCurrencyEdit;
    Label10: TLabel;
    edVlrTot: TCurrencyEdit;
    Frame_Histo: TFrame_Historico;
    Label12: TLabel;
    edHistoDES: TEdit;
    btnOK: TBitBtn;
    procedure btnSairClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edDataBaixaKeyPress(Sender: TObject; var Key: Char);
    procedure edHistoDESEnter(Sender: TObject);
    procedure edHistoDESKeyPress(Sender: TObject; var Key: Char);
    procedure edVlrPriChange(Sender: TObject);
  private
    fID, fParcela, fMoedaTIP, fHistoCOD: Integer;
    fHistoDES: String;
    wCtaRec: TCtaRec;
    wHistoAtu: Integer;
    procedure pCarregaHisto(Sender: TObject; Encontrou: Boolean);
  public
    constructor Create(Aowner: TComponent; prID, prParcela, prMoedaTIP, prHistoCOD: Integer; prHistoDES: String); overload;
  end;

var
  fcCtaRecBai: TfcCtaRecBai;

implementation

uses
  uUtils, uDataM;

{$R *.dfm}

procedure TfcCtaRecBai.btnSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  inherited;
end;

constructor TfcCtaRecBai.Create(Aowner: TComponent; prID, prParcela, prMoedaTIP, prHistoCOD: Integer; prHistoDES: String);
begin
  Inherited Create(Aowner);
  wHistoAtu  := 0;
  fID        := prID;
  fParcela   := prParcela;
  fMoedaTIP  := prMoedaTIP;
  fHistoCOD  := prHistoCOD;
  fHistoDES  := prHistoDES;
  wCtaRec    := TCtaRec.Create;
  Frame_Histo.OnDepoisBusca := pCarregaHisto;
end;

procedure TfcCtaRecBai.FormDestroy(Sender: TObject);
begin
  wCtaRec.Free;
  inherited;
end;

procedure TfcCtaRecBai.btnOKClick(Sender: TObject);
var
  wVlrSaldo: Currency;
begin
  inherited;

  wVlrSaldo  := wCtaRec.fGetSaldoParcela(fParcela);
  if (wVlrSaldo <= 0) then
  begin
    MessageDlg('Não há saldo na parcela para fazer a baixa!', mtWarning, [mbOk], 0);
    fSetaFoco([edDataBaixa]);
    Exit;
  end;

  if (edDataBaixa.Date < cDataMinima) or (edDataBaixa.Date > cDataMaxima) then
  begin
    MessageDlg('A data da baixa está fora do período de aceitação!', mtWarning, [mbOk], 0);
    fSetaFoco([edDataBaixa]);
    Exit;
  end;

  if (edVlrPri.Value = 0) and (edVlrJur.Value = 0) and (edVlrMul.Value = 0) and (edVlrDes.Value = 0) then
  begin
    MessageDlg('Não foi informadonenhun valor para a baixa!', mtWarning, [mbOk], 0);
    fSetaFoco([edVlrPri]);
    Exit;
  end;

  if Length(Trim(edHistoDES.Text)) = 0 then
  begin
    MessageDlg('Favor informar um histórico para a baixa!', mtWarning, [mbOk], 0);
    fSetaFoco([edHistoDES]);
    Exit;
  end;

  if Confirmar('Confirma a baixa da parcela?') then
  begin
    if wCtaRec.fBaixarParcela(fParcela, fMoedaTIP, Frame_Histo.Histo, edDataBaixa.Date, edVlrPri.Value, edVlrJur.Value, edVlrMul.Value, edVlrDes.Value, edHistoDES.Text) then
    begin
      ModalResult := mrOk;
      Self.Close;
    end;
  end;
end;

procedure TfcCtaRecBai.FormShow(Sender: TObject);
begin
  inherited;
  wCtaRec.ppID      := fID;
  edDataBaixa.Date  := fDataM.fDataHoraServidor;
  edVlrPri.Value    := wCtaRec.fGetSaldoParcela(fParcela);
  Frame_Histo.Histo := fHistoCOD;
  edHistoDES.Text   := fHistoDES;
end;

procedure TfcCtaRecBai.edDataBaixaKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if (Key = #13) then
  begin
    if (Sender = edHistoDES) then
    begin
      if Pos('*', edHistoDES.Text) > 0 then
      begin
        edHistoDES.SelStart  := Pos('*', edHistoDES.Text) - 1;
        edHistoDES.SelLength := 1;
        fSetaFoco([edHistoDES]);
        Exit;
      end;
    end;

    if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
      SelectNext(Sender as TWinControl, False, True)
    else
      SelectNext(Sender as TWinControl, True, True);
    Key := #0
  end;

  if Key = #27 then
  begin
    if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
      SelectNext(Sender as TWinControl, True, True)
    else
      SelectNext(Sender as TWinControl, False, True);
    Key := #0
  end;
end;

procedure TfcCtaRecBai.pCarregaHisto(Sender: TObject; Encontrou: Boolean);
begin
  if (wHistoAtu <> Frame_Histo.ppDadosHis.Codigo) then
  begin
    if (Encontrou) then
      edHistoDES.Text := Frame_Histo.ppDadosHis.Descricao
    else
      if Frame_Histo.ppDadosHis.Codigo > 0 then
        edHistoDES.Text := '';
  end;
  wHistoAtu := Frame_Histo.ppDadosHis.Codigo;
end;

procedure TfcCtaRecBai.edHistoDESEnter(Sender: TObject);
begin
  inherited;
  if Pos('*', edHistoDES.Text) > 0 then
  begin
    edHistoDES.SelStart  := Pos('*', edHistoDES.Text) - 1;
    edHistoDES.SelLength := 1;
  end;
end;

procedure TfcCtaRecBai.edHistoDESKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;

  if (Key = #13) then
  begin
    if (Sender = edHistoDES) then
    begin
      if Pos('*', edHistoDES.Text) > 0 then
      begin
        fSetaFoco([edHistoDES]);
        edHistoDES.SelStart  := Pos('*', edHistoDES.Text) - 1;
        edHistoDES.SelLength := 1;
        Exit;
      end;
    end;

    if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
      SelectNext(Sender as TWinControl, False, True)
    else
      SelectNext(Sender as TWinControl, True, True);
    Key := #0
  end;

  if Key = #27 then
  begin
    if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
      SelectNext(Sender as TWinControl, True, True)
    else
      SelectNext(Sender as TWinControl, False, True);
    Key := #0
  end;
end;

procedure TfcCtaRecBai.edVlrPriChange(Sender: TObject);
begin
  inherited;
  edVlrTot.Value := edVlrPri.Value + edVlrJur.Value + edVlrMul.Value - edVlrDes.Value;
end;

end.
