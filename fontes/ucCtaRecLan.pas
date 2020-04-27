unit ucCtaRecLan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, uFrame_CtaREC,
  uFrame_ForCli, Mask, Menus, uFrame_Historico,
  uFrame_Categoria, uFrame_Moeda, rtCtaREC, rtFornecedor, rtCartao, DB, Grids,
  DBGrids, uFrame_Cartao, DBClient, pFIBClientDataSet, Provider,
  FIBDataSet, pFIBDataSet, FIBDatabase, pFIBDatabase, 
  rxCurrEdit, rxToolEdit;

type
  TfcCtaRecLan = class(TfcPadrao)
    frame_CtaREC: Tframe_CtaREC;
    pnEdicao: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label10: TLabel;
    Label7: TLabel;
    Label5: TLabel;
    spGerarParcelas: TSpeedButton;
    Label12: TLabel;
    Label8: TLabel;
    Frame_ForCli: TFrame_ForCli;
    edDataEmissao: TDateEdit;
    edDoctoNRO: TEdit;
    pnCombo: TPanel;
    edParcelaQTDE: TCurrencyEdit;
    edPacelaVLR: TCurrencyEdit;
    edVlr1aParce: TCurrencyEdit;
    edVlrPrincipal: TCurrencyEdit;
    edDiaFixo: TCurrencyEdit;
    edData1aParce: TDateEdit;
    Frame_Moeda: TFrame_Moeda;
    Frame_Cartao: TFrame_Cartao;
    frame_CategoriaEnt: Tframe_Categoria;
    edHistoDES: TEdit;
    edDescricao: TEdit;
    Frame_Histo: TFrame_Historico;
    frame_CategoriaRec: Tframe_Categoria;
    lbStatus: TLabel;
    gbParce: TGroupBox;
    DBGridParce: TDBGrid;
    gbBaixas: TGroupBox;
    DBGridBaixa: TDBGrid;
    dsParce: TDataSource;
    pmParcela: TPopupMenu;
    mmParceAlterar: TMenuItem;
    N1: TMenuItem;
    mmParceBaixar: TMenuItem;
    pFIBTrBaixa: TpFIBTransaction;
    qrBaixa: TpFIBDataSet;
    pFIBDSProvBaixa: TpFIBDataSetProvider;
    pFIBCdsBaixa: TpFIBClientDataSet;
    dsBaixa: TDataSource;
    pmParceTIP: TPopupMenu;
    mmParceTipFixo: TMenuItem;
    mmParceTipCont: TMenuItem;
    btnGravar: TBitBtn;
    btnLimpar: TBitBtn;
    btnCancelar: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure pnComboClick(Sender: TObject);
    procedure mmParceTipContClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure frame_CtaRECedFaturaKeyPress(Sender: TObject; var Key: Char);
    procedure edParcelaQTDEChange(Sender: TObject);
    procedure edPacelaVLRExit(Sender: TObject);
    procedure edVlrPrincipalExit(Sender: TObject);
    procedure edHistoDESKeyPress(Sender: TObject; var Key: Char);
    procedure edHistoDESEnter(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure DBGridParceDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnLimparClick(Sender: TObject);
    procedure spGerarParcelasClick(Sender: TObject);
    procedure edData1aParceExit(Sender: TObject);
    procedure Frame_MoedacbMoedaChange(Sender: TObject);
    procedure edDiaFixoExit(Sender: TObject);
    procedure mmParceAlterarClick(Sender: TObject);
    procedure pmParcelaPopup(Sender: TObject);
    procedure mmParceBaixarClick(Sender: TObject);
    procedure DBGridParceDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnCancelarClick(Sender: TObject);
  private
    fTipoTela: Integer;
    wFaturaAtu, wHistoAtu: Integer;
    wCartaoCOD: Integer;
    wCtaRec: TCtaRec;
    wCdsParce: TClientDataSet;
    wGerandoParce: Boolean;
    wGotoParce: Integer;
    procedure pLimpaTela;
    procedure pMostraStatus(prSta: Integer);
    procedure pAtualizaGradeBaixa;
    procedure pCarregaForCli(Sender: TObject; Encontrou: Boolean);
    procedure pCarregaHisto(Sender: TObject; Encontrou: Boolean);
    procedure pCarregaFatura(Sender: TObject; Encontrou: Boolean);
    procedure pCarregaCartao(Sender: TObject; Encontrou: Boolean);

    procedure pCalculaParcelas;
    function  fConsisteDados: Boolean;
    procedure pAlterarParcela;
    procedure pCalculaData1aParcela(prData: TDate);
    procedure OnAfterScroll(DataSet: TDataSet);
  public
    constructor Create(Aowner: TComponent; prTipo: Integer); overload;
  end;

var
  fcCtaRecLan: TfcCtaRecLan;

implementation

uses rtHistorico, uUtils, uDataM, rtTypes, DateUtils, Math,
     ucCtaRecLanParceAlt, ucCtaRecBai;

{$R *.dfm}

{ TfcCtaRecLan }

constructor TfcCtaRecLan.Create(Aowner: TComponent; prTipo: Integer);
begin
  Inherited Create(Aowner);
  fTipoTela := prTipo;
end;

procedure TfcCtaRecLan.FormShow(Sender: TObject);
begin
  inherited;
  if (fTipoTela = 1) then
  begin
    Self.Caption           := 'Contas A RECEBER - Baixa de Pagamentos';
    pnEdicao.Enabled       := False;
    mmParceAlterar.Visible := False;
  end;
end;

procedure TfcCtaRecLan.pnComboClick(Sender: TObject);
begin
  inherited;
  pmParceTIP.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;

procedure TfcCtaRecLan.mmParceTipContClick(Sender: TObject);
begin
  inherited;
  edParcelaQTDE.Color     := clWindow;
  edVlrPrincipal.Color    := clWindow;
  edVlr1aParce.Color      := clWindow;
  edParcelaQTDE.Enabled   := (Sender = mmParceTipFixo);
  edVlrPrincipal.Enabled  := (Sender = mmParceTipFixo);
  edVlr1aParce.Enabled    := (Sender = mmParceTipFixo);

  if (not edParcelaQTDE.Enabled) then
  begin
    edParcelaQTDE.Color  := clSilver;
    edVlrPrincipal.Color := clSilver;
    edVlr1aParce.Color   := clSilver;
  end;
end;

procedure TfcCtaRecLan.FormCreate(Sender: TObject);
begin
  inherited;
  wGerandoParce := False;
  wCtaRec := TCtaRec.Create;
  Frame_ForCli.OnDepoisBusca      := pCarregaForCli;
  Frame_Histo.OnDepoisBusca       := pCarregaHisto;
  frame_CtaREC.OnDepoisBusca      := pCarregaFatura;
  Frame_Cartao.OnDepoisBusca      := pCarregaCartao;
  frame_CategoriaRec.FiltroClassi := 'AND (Classificacao Like ''1.2.2%'')';
  frame_CategoriaEnt.FiltroClassi := 'AND (Classificacao Like ''1.%'')';

  wFaturaAtu := 0;
  wHistoAtu  := 0;
  wCartaoCOD := 0;

  wCdsParce := TClientDataSet.Create(nil);
  wCdsParce.FieldDefs.Clear;
  wCdsParce.FieldDefs.Add('ParceParce',        ftInteger);
  wCdsParce.FieldDefs.Add('ParceVencto',       ftDate);
  wCdsParce.FieldDefs.Add('ParceVlrPri',       ftCurrency);
  wCdsParce.FieldDefs.Add('ParceVlrPag',       ftCurrency);
  wCdsParce.FieldDefs.Add('ParceVlrSal',       ftCurrency);
  wCdsParce.FieldDefs.Add('ParceMoedaTIP',     ftInteger);
  wCdsParce.FieldDefs.Add('ParceMoedaDES',     ftString, 20);
  wCdsParce.FieldDefs.Add('ParceCartaoTIP',    ftInteger);
  wCdsParce.FieldDefs.Add('ParceCartaoCOD',    ftInteger);
  wCdsParce.FieldDefs.Add('ParceCartaoDES',    ftString, 100);
  wCdsParce.FieldDefs.Add('ParceStatusCOD',    ftInteger);
  wCdsParce.FieldDefs.Add('ParceStatusDES',    ftString, 20);
  wCdsParce.CreateDataSet;
  wCdsParce.IndexFieldNames := 'ParceParce';
  TCurrencyField(wCdsParce.FieldByName('ParceVlrPri')).DisplayFormat := cMascaraValor;
  TCurrencyField(wCdsParce.FieldByName('ParceVlrPag')).DisplayFormat := cMascaraValor;
  TCurrencyField(wCdsParce.FieldByName('ParceVlrSal')).DisplayFormat := cMascaraValor;
  TCurrencyField(wCdsParce.FieldByName('ParceVencto')).DisplayFormat := cMascaraData;
  dsParce.DataSet := wCdsParce;

  wCdsParce.AfterOpen   := OnAfterScroll;
  wCdsParce.AfterScroll := OnAfterScroll;
  wCdsParce.AfterClose  := OnAfterScroll;
end;

procedure TfcCtaRecLan.pCarregaForCli(Sender: TObject; Encontrou: Boolean);
begin
  if (Encontrou) then
  begin
    Frame_Moeda.ppMoeda    := Frame_ForCli.MoedaTIP;
  end;
end;

procedure TfcCtaRecLan.pCarregaHisto(Sender: TObject; Encontrou: Boolean);
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

procedure TfcCtaRecLan.pCarregaCartao(Sender: TObject; Encontrou: Boolean);
begin
  if (Encontrou) and (wCartaoCOD <> Frame_Cartao.Codigo)   then
  begin
    wCartaoCOD := Frame_Cartao.Codigo;
//    frame_Categoria Ent.Codigo := Frame_Cartao.CategDeb;
    pCalculaParcelas;
  end;
end;

procedure TfcCtaRecLan.pCarregaFatura(Sender: TObject; Encontrou: Boolean);
var
  wTipForCli: TTipForCli;
  wParce, wGoto: Integer;
begin
  spGerarParcelas.Enabled := False;
  wTipForCli.Tipo := -1;
  wTipForCli.Codi := 0;

  if (wFaturaAtu <> frame_CtaREC.Fatura) or (frame_CtaREC.Fatura = 0) then
  begin
    pLimpaTela;
    fSetaFoco([Frame_ForCli.edNome]);
    if (Encontrou) then
    begin
      wFaturaAtu := frame_CtaREC.Fatura;
      frame_CtaREC.edFatura.AsInteger := frame_CtaREC.Fatura;
      wCtaRec.ppCodigo := frame_CtaREC.Fatura;
      pMostraStatus(wCtaRec.ppDados.StatusCOD);
      wTipForCli.Tipo             := wCtaRec.ppDados.EmitenteTIP;
      wTipForCli.Codi             := wCtaRec.ppDados.EmitenteCOD;
      Frame_ForCli.TipForCli      := wTipForCli;

      edDoctoNRO.Text             := wCtaRec.ppDados.DoctoNRO;
      edDataEmissao.Date          := wCtaRec.ppDados.DataEmissao;
      mmParceTipFixo.Checked      := wCtaRec.ppDados.ParcelaTIPO = 0;
      mmParceTipCont.Checked      := wCtaRec.ppDados.ParcelaTIPO = 1;
      edParcelaQTDE.AsInteger     := wCtaRec.ppDados.ParcelaQTDE;
      edPacelaVLR.Value           := wCtaRec.ppDados.ValorParcela;
      edVlrPrincipal.Value        := wCtaRec.ppDados.ValorPrincipal;
      edData1aParce.Date          := wCtaRec.ppDados.PrimParceData;
      edVlr1aParce.Value          := wCtaRec.ppDados.PrimParceValor;
      edDiaFixo.AsInteger         := wCtaRec.ppDados.DiaFixoVencto;
      Frame_Moeda.ppMoeda         := wCtaRec.ppDados.MoedaTIP;
      Frame_MoedacbMoedaChange(Sender);
      frame_CategoriaRec.Codigo   := wCtaRec.ppDados.CategoriaRec;
      frame_CategoriaEnt.Codigo   := wCtaRec.ppDados.CategoriaEnt;
      Frame_Histo.Histo           := 0;
      edHistoDES.Text             := wCtaRec.ppDados.HistoDES;
      Frame_Histo.edHisto.Enabled := (wCtaRec.ppDados.StatusCOD < 2) and (edHistoDES.Text = '');
      edDescricao.Text            := wCtaRec.ppDados.Descricao;

      wGerandoParce := True;
      DBGridParce.DataSource := nil;
      DBGridBaixa.DataSource := nil;
      wCdsParce.EmptyDataSet;
      wGoto := 0;
      try
        for wParce := Low(wCtaRec.ppDados.Parcelas) to High(wCtaRec.ppDados.Parcelas) do
        begin
          wCdsParce.Append;
          wCdsParce.FieldByName('ParceParce').AsInteger       := wCtaRec.ppDados.Parcelas[wParce].Parcela;
          wCdsParce.FieldByName('ParceVencto').AsDateTime     := wCtaRec.ppDados.Parcelas[wParce].DataVencto;
          wCdsParce.FieldByName('ParceVlrPri').AsCurrency     := wCtaRec.ppDados.Parcelas[wParce].ValorParcela;
          wCdsParce.FieldByName('ParceVlrPag').AsCurrency     := wCtaRec.fGetPagoParcela(wCdsParce.FieldByName('ParceParce').AsInteger);
          wCdsParce.FieldByName('ParceVlrSal').AsCurrency     := wCdsParce.FieldByName('ParceVlrPri').AsCurrency - wCdsParce.FieldByName('ParceVlrPag').AsCurrency;
          wCdsParce.FieldByName('ParceMoedaTIP').AsInteger    := wCtaRec.ppDados.Parcelas[wParce].MoedaTIP;
          wCdsParce.FieldByName('ParceMoedaDES').AsString     := wCtaRec.ppDados.Parcelas[wParce].MoedaDES;
          wCdsParce.FieldByName('ParceCartaoCOD').AsInteger   := wCtaRec.ppDados.Parcelas[wParce].CartaoCOD;
          wCdsParce.FieldByName('ParceCartaoDES').AsString    := wCtaRec.ppDados.Parcelas[wParce].CartaoDES;
          wCdsParce.FieldByName('ParceStatusCOD').AsInteger   := wCtaRec.ppDados.Parcelas[wParce].StatusCOD;
          wCdsParce.FieldByName('ParceStatusDES').AsString    := wCtaRec.ppDados.Parcelas[wParce].StatusDES;
          if (wGoto = 0) and (wCtaRec.ppDados.Parcelas[wParce].StatusCOD < 3) then
            wGoto := wCtaRec.ppDados.Parcelas[wParce].Parcela;
        end;
        if wGotoParce > 0 then
          wCdsParce.FindKey([wGotoParce])
        else
          if wGoto > 0 then
            wCdsParce.FindKey([wGoto]);
      finally
        DBGridParce.DataSource := dsParce;
        DBGridBaixa.DataSource := dsBaixa;
      end;

      wGotoParce := 0;
      wGerandoParce := False;
      pAtualizaGradeBaixa;
      fSetaFoco([Frame_ForCli.edNome]);
    end;
  end;
  edParcelaQTDE.Enabled       := (wCtaRec.ppDados.StatusCOD < 2) or (frame_CtaREC.Fatura = 0);
  edPacelaVLR.Enabled         := (wCtaRec.ppDados.StatusCOD < 2) or (frame_CtaREC.Fatura = 0);
  edVlr1aParce.Enabled        := (wCtaRec.ppDados.StatusCOD < 2) or (frame_CtaREC.Fatura = 0);
  edVlrPrincipal.Enabled      := (wCtaRec.ppDados.StatusCOD < 2) or (frame_CtaREC.Fatura = 0);
  edDiaFixo.Enabled           := (wCtaRec.ppDados.StatusCOD < 2) or (frame_CtaREC.Fatura = 0);
  edData1aParce.Enabled       := (wCtaRec.ppDados.StatusCOD < 2) or (frame_CtaREC.Fatura = 0);
  Frame_Histo.edHisto.Enabled := ((wCtaRec.ppDados.StatusCOD < 2) and (edHistoDES.Text = '')) or (frame_CtaREC.Fatura = 0);
  spGerarParcelas.Enabled     := (wCtaRec.ppDados.StatusCOD < 2) or (frame_CtaREC.Fatura = 0);

  btnGravar.Enabled           := (wCtaRec.ppDados.StatusCOD < 2) or (frame_CtaREC.Fatura = 0);
  btnCancelar.Enabled         := (wCtaRec.ppDados.StatusCOD < 7) and (frame_CtaREC.Fatura > 0);
end;

procedure TfcCtaRecLan.frame_CtaRECedFaturaKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #13 then
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

procedure TfcCtaRecLan.edParcelaQTDEChange(Sender: TObject);
begin
  inherited;
  if edPacelaVLR.Value > 0 then
    edVlrPrincipal.Value := edParcelaQTDE.AsInteger * edPacelaVLR.Value
  else if (edVlrPrincipal.Value > 0) and (edParcelaQTDE.AsInteger > 0) then
    edPacelaVLR.Value := edPacelaVLR.Value / edParcelaQTDE.AsInteger;
end;

procedure TfcCtaRecLan.pCalculaData1aParcela(prData: TDate);
var
  wDia, wMes, wAno: Word;
  wData: TDate;
begin
  edData1aParce.Clear;
  if (prData > cDataMinima) then
  begin
    DecodeDate(prData, wAno, wMes, wDia);
    wData := IncMonth(prData);
    DecodeDate(wData, wAno, wMes, wDia);
    wDia := DayOf(prData);
    if edDiaFixo.AsInteger > 0 then
      wDia := edDiaFixo.AsInteger;
    if wDia > 28 then
      wDia := 28;
    edData1aParce.Date := EncodeDate(wAno, wMes, wDia);
  end;
end;

procedure TfcCtaRecLan.edPacelaVLRExit(Sender: TObject);
begin
  inherited;
  if edPacelaVLR.Value > 0 then
  begin
    edVlrPrincipal.Value := edParcelaQTDE.AsInteger * edPacelaVLR.Value;
    pCalculaData1aParcela(edDataEmissao.Date);
    if edVlr1aParce.Value > edPacelaVLR.Value then
      edVlr1aParce.Clear;
    edDiaFixo.AsInteger  := DayOf(edData1aParce.Date);
  end;
end;

procedure TfcCtaRecLan.edVlrPrincipalExit(Sender: TObject);
begin
  inherited;
  if (edVlrPrincipal.Value > 0) and (edParcelaQTDE.AsInteger > 0) then
    edPacelaVLR.Value := edVlrPrincipal.Value / edParcelaQTDE.AsInteger;
end;

procedure TfcCtaRecLan.edHistoDESKeyPress(Sender: TObject; var Key: Char);
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

procedure TfcCtaRecLan.edHistoDESEnter(Sender: TObject);
begin
  inherited;
  if Pos('*', edHistoDES.Text) > 0 then
  begin
    edHistoDES.SelStart  := Pos('*', edHistoDES.Text) - 1;
    edHistoDES.SelLength := 1;
  end;
end;

function TfcCtaRecLan.fConsisteDados: Boolean;
var
  wSomaParce: Currency;
begin
  Result := False;

  if (frame_CtaREC.Fatura > 0) then
  begin
    if wCtaRec.fFaturaTemBaixas(frame_CtaREC.Fatura) then
    begin
      MessageDlg('A Fatura já tem baixas e não pode ser alterada', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (Frame_ForCli.Tipo < -1) or (Frame_ForCli.Tipo > 1) then
  begin
    MessageDlg('O Tipo de emitente não foi informado corretamente', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (Frame_ForCli.Tipo > -1) then
  begin
    case Frame_ForCli.Tipo of
      0: begin
           if (Frame_ForCli.Codigo < 0) then
           begin
             MessageDlg('O Código do emitente (fornecedor) não foi informado!', mtWarning, [mbOk], 0);
             Exit;
           end;

           if (not fEstaCadastrado(Frame_ForCli.Codigo, 'Fornecedor', 'Codigo', True)) then
           begin
             MessageDlg('O emitente (fornecedor) não está cadastrado', mtWarning, [mbOk], 0);
             Exit;
           end;
         end;
      1: begin
           if (Frame_ForCli.Codigo < 0) then
           begin
             MessageDlg('O Código do emitente (cliente) não foi informado', mtWarning, [mbOk], 0);
             Exit;
           end;

           if (not fEstaCadastrado(Frame_ForCli.Codigo, 'Cliente', 'Codigo', True)) then
           begin
             MessageDlg('O emitente (cliente) não está cadastrado', mtWarning, [mbOk], 0);
             Exit;
           end;
         end;
    end;
  end;

  if Length(Trim(edDoctoNRO.Text)) = 0 then
  begin
    MessageDlg('O número do documento não foi informado', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (edDataEmissao.Date < cDataMinima) or (edDataEmissao.Date > cDataMaxima) then
  begin
    MessageDlg('A data de emissão informada está fora do período de aceitação', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (DateOf(edDataEmissao.Date) > DateOf(fDataM.fDataHoraServidor)) then
  begin
    MessageDlg('A data de emissão informada é maior que a data atual', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (not mmParceTipFixo.Checked) and (not mmParceTipCont.Checked) then
  begin
    MessageDlg('O tipo de parcelamento não foi selecionado', mtWarning, [mbOk], 0);
    Exit;
  end;

  if mmParceTipFixo.Checked then
  begin
    if (edParcelaQTDE.AsInteger < 1) or (edParcelaQTDE.AsInteger > 420) then
    begin
      MessageDlg('A quantidade de parcelas deve estar entre 1 e 420', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (edData1aParce.Date < cDataMinima) or (edData1aParce.Date > cDataMaxima) then
  begin
    MessageDlg('A data da primeira parcela está fora do periodo de aceitação', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (edData1aParce.Date < edDataEmissao.Date) then
  begin
    MessageDlg('A data da primeira parcela é anterior à emissão do documento', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (edPacelaVLR.Value <> 0) then
  begin
    if (edPacelaVLR.Value < 0) then
    begin
      MessageDlg('O valor da primeira parcela deve ser zero ou maior', mtWarning, [mbOk], 0);
      Exit;
    end;

    if (edPacelaVLR.Value > edVlrPrincipal.Value) then
    begin
      MessageDlg('O valor da primeira parcela é maior que o valor principal', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (edDiaFixo.AsInteger <> 0) then
  begin
    if (edDiaFixo.AsInteger < 0) then
    begin
      MessageDlg('O dia fixo de vencimento deve ser zero ou maior', mtWarning, [mbOk], 0);
      Exit;
    end;

    if (edDiaFixo.AsInteger > 28) then
    begin
      MessageDlg('O dia fixo de vencimento deve ser inferior a 29', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (edVlrPrincipal.Value <= 0) then
  begin
    MessageDlg('O valor principal deve ser maior que zero', mtWarning, [mbOk], 0);
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

  if (frame_CategoriaRec.Codigo < 1) then
  begin
    MessageDlg('A categoria de receitas não foi informada', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (frame_CategoriaEnt.Codigo < 1) then
  begin
    MessageDlg('A categoria recebedora não foi informada', mtWarning, [mbOk], 0);
    Exit;
  end;

  wSomaParce := 0;
  wGerandoParce := True;
  wCdsParce.DisableControls;
  try
    wCdsParce.First;
    while (not wCdsParce.Eof) do
    begin
      wSomaParce := wSomaParce + wCdsParce.FieldByName('ParceVlrPri').AsCurrency;
      wCdsParce.Next;
    end;
  finally
    wGerandoParce := False;
    wCdsParce.First;
    wCdsParce.EnableControls;
  end;
  if (wSomaParce < 0.01) or ( RoundTo(wSomaParce, -2) <> RoundTo(edVlrPrincipal.Value, -2) ) then
  begin
    MessageDlg('A soma das parcelas é diferente do Valor Total da Fatura!', mtWarning, [mbOk], 0);
    Exit;
  end;

  Result := True;
end;

procedure TfcCtaRecLan.btnGravarClick(Sender: TObject);
var
  wID, wParce: Integer;
  wDados: TDadosREC;
  wParcelas: TParcelas;
begin
  inherited;
  if (not fConsisteDados) then Exit;

  wCtaRec.Clear;
  wDados.id          := 0;
  wDados.Empre       := fDataM.Empresa;
  wDados.Codigo      := frame_CtaREC.edFatura.AsInteger;
  wDados.EmitenteTIP := Frame_ForCli.Tipo;
  wDados.EmitenteCOD := Frame_ForCli.Codigo;
  wDados.DoctoNRO    := edDoctoNRO.Text;
  wDados.DataEmissao := edDataEmissao.Date;
  if mmParceTipFixo.Checked then
  begin
    wDados.ParcelaTIPO    := 0;
    wDados.ParcelaQTDE    := edParcelaQTDE.AsInteger;
    wDados.ValorParcela   := edPacelaVLR.Value;
    wDados.ValorPrincipal := edVlrPrincipal.Value;
  end
  else
  begin
    wDados.ParcelaTIPO    := 1;
    wDados.ParcelaQTDE    := 0;
    wDados.ValorParcela   := edPacelaVLR.Value;
    wDados.ValorPrincipal := 0;
  end;
  wDados.PrimParceData    := edData1aParce.Date;
  wDados.PrimParceValor   := edVlr1aParce.Value;
  wDados.DiaFixoVencto    := edDiaFixo.AsInteger;
  wDados.MoedaTIP         := Frame_Moeda.ppMoeda;
  wDados.CartaoCOD        := Frame_Cartao.Codigo;
  wDados.CategoriaRec     := frame_CategoriaRec.Codigo;
  wDados.CategoriaEnt     := frame_CategoriaEnt.Codigo;
  wDados.HistoDES         := edHistoDES.Text;
  wDados.Descricao        := edDescricao.Text;
  wDados.StatusCOD        := 1; // Desdobrada - Só no INSERT

  wCtaRec.ppDados := wDados;
  wID := wCtaRec.fGravar;

  if (wID > 0) then
  begin
    wParce := 0;
    SetLength(wParcelas, wParce);
    wGerandoParce := True;
    wCdsParce.DisableControls;
    try
      wCdsParce.First;
      while (not wCdsParce.Eof) do
      begin
        Inc(wParce);
        SetLength(wParcelas, wParce);
        wParcelas[wParce - 1].DoctoID      := wID;
        wParcelas[wParce - 1].Parcela      := wParce;
        wParcelas[wParce - 1].DataVencto   := wCdsParce.FieldByName('ParceVencto').AsDateTime;
        wParcelas[wParce - 1].ValorParcela := wCdsParce.FieldByName('ParceVlrPri').AsCurrency;
        wParcelas[wParce - 1].MoedaTIP     := wCdsParce.FieldByName('ParceMoedaTIP').AsInteger;
        wParcelas[wParce - 1].CartaoCOD    := wCdsParce.FieldByName('ParceCartaoCOD').AsInteger;
        wParcelas[wParce - 1].StatusCOD    := wCdsParce.FieldByName('ParceStatusCOD').AsInteger;
        wCdsParce.Next;
      end;
      wCtaRec.fGravarParcelas(wID, wParcelas, wCtaRec.ppDados.StatusCOD);
      wFaturaAtu := 0;
    finally
      wGerandoParce := False;
      wCdsParce.EnableControls;
      frame_CtaREC.ID := wID;
    end;
  end;
  fSetaFoco([frame_CtaREC.edFatura]);
end;

procedure TfcCtaRecLan.DBGridParceDblClick(Sender: TObject);
begin
  if (wCdsParce.Active) and (not wCdsParce.IsEmpty) and (wCdsParce.FieldByName('ParceParce').AsInteger > 0) and (wCtaRec.ppDados.StatusCOD < 3) then
    pAlterarParcela;
end;

procedure TfcCtaRecLan.pAlterarParcela;
var
  wParcela: TParcela;
begin
  inherited;
  if (fTipoTela = 1) then Exit;

  fcCtaRecLanParceAlt := TfcCtaRecLanParceAlt.Create(Self);
  try
    wParcela.DoctoID      := frame_CtaREC.Fatura;
    wParcela.Parcela      := wCdsParce.FieldByName('ParceParce').AsInteger;
    wParcela.DataVencto   := wCdsParce.FieldByName('ParceVencto').AsDateTime;
    wParcela.ValorParcela := wCdsParce.FieldByName('ParceVlrPri').AsCurrency;
    wParcela.MoedaTIP     := wCdsParce.FieldByName('ParceMoedaTIP').AsInteger;
    //
    fcCtaRecLanParceAlt.edDataVencto.Date      := wCdsParce.FieldByName('ParceVencto').AsDateTime;
    fcCtaRecLanParceAlt.Frame_Moeda.ppMoeda    := wCdsParce.FieldByName('ParceMoedaTIP').AsInteger;
    fcCtaRecLanParceAlt.Frame_Cartao.ppCodigo  := wCdsParce.FieldByName('ParceCartaoCOD').AsInteger;
    fcCtaRecLanParceAlt.ShowModal;
    if fcCtaRecLanParceAlt.ModalResult = mrOk then
    begin
      if (fcCtaRecLanParceAlt.ppDataVencto <> wCdsParce.FieldByName('ParceVencto').AsDateTime) or
         (fcCtaRecLanParceAlt.ppMoeda      <> wCdsParce.FieldByName('ParceMoedaTIP').AsInteger) or
         (fcCtaRecLanParceAlt.ppCartao     <> wCdsParce.FieldByName('ParceCartaoCOD').AsInteger) then
      begin
        wParcela.DataVencto   := fcCtaRecLanParceAlt.ppDataVencto;
        wParcela.MoedaTIP     := fcCtaRecLanParceAlt.ppMoeda;
        wParcela.CartaoCOD    := fcCtaRecLanParceAlt.ppCartao;
        wCtaRec.fAlterarParcela(wParcela);
        frame_CtaREC.Fatura := 0;
        frame_CtaREC.Fatura := wParcela.DoctoID;
      end;
    end;
  finally
    FreeAndNil(fcCtaRecLanParceAlt);
  end;
end;

procedure TfcCtaRecLan.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  wCtaRec.Free;
end;

procedure TfcCtaRecLan.btnLimparClick(Sender: TObject);
begin
  inherited;
  frame_CtaREC.Fatura := 0;
  pLimpaTela;
  fSetaFoco([frame_CtaREC.edFatura]);
end;

procedure TfcCtaRecLan.pMostraStatus(prSta: Integer);
begin
  lbStatus.Caption := 'Pendente';
  lbStatus.Color   := clGreen;
  case prSta of
    0: lbStatus.Caption := 'Pendente';
    1: lbStatus.Caption := 'Desdobrada';
    2: lbStatus.Caption := 'Pagto Parcial';
    3: lbStatus.Caption := 'Quitada';
    7: lbStatus.Caption := 'Cancelada';
  end;

  case prSta of
    0: lbStatus.Color   := clGreen;
    1: lbStatus.Color   := $00FF8000;
    2: lbStatus.Color   := $000080FF;
    3: lbStatus.Color   := clBlue;
    7: lbStatus.Color   := clRed;
  end;
end;

procedure TfcCtaRecLan.pLimpaTela;
begin
  wCtaRec.Clear;

  wFaturaAtu := 0;
  wHistoAtu  := 0;
  wCartaoCOD := 0;

  pMostraStatus(0);
  Frame_ForCli.Clear;
  edDataEmissao.Clear;
  edDoctoNRO.Clear;
  edParcelaQTDE.Clear;
  mmParceTipFixo.Checked := True;
  edPacelaVLR.Clear;
  edVlrPrincipal.Clear;
  edData1aParce.Clear;
  edVlr1aParce.Clear;
  edDiaFixo.Clear;
  Frame_Moeda.cbMoeda.ItemIndex := 1;
  frame_CategoriaRec.Clear;
  frame_CategoriaEnt.Clear;
  Frame_Histo.Histo := 0;
  edHistoDES.Clear;
  edDescricao.Clear;
  wCdsParce.EmptyDataSet;
  pFIBCdsBaixa.Close;
end;

procedure TfcCtaRecLan.spGerarParcelasClick(Sender: TObject);
begin
  inherited;
  pCalculaParcelas;
end;

procedure TfcCtaRecLan.edData1aParceExit(Sender: TObject);
begin
  inherited;
  if wCtaRec.ppDados.StatusCOD < 2 then
    spGerarParcelasClick(Sender);
end;

procedure TfcCtaRecLan.Frame_MoedacbMoedaChange(Sender: TObject);
begin
  inherited;
  Frame_Cartao.Enabled := (Frame_Moeda.ppMoeda = 3) or (Frame_Moeda.ppMoeda = 4);

  Frame_Cartao.Clear;
  Frame_Cartao.Invalidate;
  spGerarParcelasClick(Sender);
end;

procedure TfcCtaRecLan.edDiaFixoExit(Sender: TObject);
begin
  inherited;
  pCalculaData1aParcela(edDataEmissao.Date);
end;

procedure TfcCtaRecLan.pCalculaParcelas;
var
  wParce: Integer;
  wDataVenctoAnt: TDateTime;
  wVlrParce, wSoma, wDiferenca: Currency;
begin
  inherited;
  if (wCtaRec.ppDados.StatusCOD < 2) then
  begin
    wGerandoParce := True;
    DBGridParce.DataSource := nil;
    DBGridBaixa.DataSource := nil;
    try
      wCdsParce.EmptyDataSet;
      if mmParceTipFixo.Checked then
      begin
        wDataVenctoAnt := edData1aParce.Date;
        wVlrParce      := edPacelaVLR.Value;
        if edVlr1aParce.Value > 0 then
          wVlrParce    := RoundTo(((edVlrPrincipal.Value - edVlr1aParce.Value) / (edParcelaQTDE.AsInteger - 1)), -2);

        for wParce := 1 to edParcelaQTDE.AsInteger do
        begin
          wCdsParce.Append;
          wCdsParce.FieldByName('ParceParce').AsInteger       := wParce;
          if (wParce = 1) then
          begin
            wCdsParce.FieldByName('ParceVencto').AsDateTime   := edData1aParce.Date;
            if edVlr1aParce.Value > 0 then
              wCdsParce.FieldByName('ParceVlrPri').AsCurrency := edVlr1aParce.Value
            else
              wCdsParce.FieldByName('ParceVlrPri').AsCurrency := wVlrParce;
          end
          else
          begin
            wCdsParce.FieldByName('ParceVlrPri').AsCurrency   := wVlrParce;
            wDataVenctoAnt := IncMonth(wDataVenctoAnt, 1);
            wCdsParce.FieldByName('ParceVencto').AsDateTime   := wDataVenctoAnt;
          end;
          wCdsParce.FieldByName('ParceVlrPag').AsCurrency     := wCtaRec.fGetPagoParcela(wCdsParce.FieldByName('ParceParce').AsInteger);
          wCdsParce.FieldByName('ParceVlrSal').AsCurrency     := wCdsParce.FieldByName('ParceVlrPri').AsCurrency - wCdsParce.FieldByName('ParceVlrPag').AsCurrency;

          wCdsParce.FieldByName('ParceMoedaTIP').AsInteger    := Frame_Moeda.ppMoeda;
          wCdsParce.FieldByName('ParceMoedaDES').AsString     := fDataM.fBuscaMoeda(wCdsParce.FieldByName('ParceMoedaTIP').AsInteger);
          wCdsParce.FieldByName('ParceCartaoCOD').AsInteger   := Frame_Cartao.ppCodigo;
          wCdsParce.FieldByName('ParceCartaoDES').AsString    := fDataM.fBuscaCartao(wCdsParce.FieldByName('ParceCartaoTIP').AsInteger, wCdsParce.FieldByName('ParceCartaoCOD').AsInteger);
          wCdsParce.FieldByName('ParceStatusCOD').AsInteger   := 0;
          wCdsParce.FieldByName('ParceStatusDES').AsString    := fDataM.fBuscaStatusPARCE(wCdsParce.FieldByName('ParceStatusCOD').AsInteger);
          wCdsParce.Post;
          wDataVenctoAnt := wCdsParce.FieldByName('ParceVencto').AsDateTime;
        end;
      end;
      wSoma      := 0;
      wCdsParce.First;
      while (not wCdsParce.Eof) do
      begin
        wSoma := wSoma + RoundTo(wCdsParce.FieldByName('ParceVlrPri').AsCurrency, -2);
        wCdsParce.Next;
      end;

      wGerandoParce := True;
      wDiferenca := RoundTo(edVlrPrincipal.Value, -2) - wSoma;
      if wDiferenca <> 0 then
      begin
        wCdsParce.Last;
        wCdsParce.Edit;
        wCdsParce.FieldByName('ParceVlrPri').AsCurrency := wCdsParce.FieldByName('ParceVlrPri').AsCurrency + wDiferenca;
        wCdsParce.FieldByName('ParceVlrPag').AsCurrency := 0;
        wCdsParce.FieldByName('ParceVlrSal').AsCurrency := wCdsParce.FieldByName('ParceVlrPri').AsCurrency - wCdsParce.FieldByName('ParceVlrPag').AsCurrency;
        wCdsParce.Post;
      end;
    finally
      DBGridParce.DataSource := dsParce;
      DBGridBaixa.DataSource := dsBaixa;
      wGerandoParce := False;
      wCdsParce.First;
    end;
  end
  else
  begin
    wGerandoParce := True;
    DBGridParce.DataSource := nil;
    DBGridBaixa.DataSource := nil;
    try
      wCdsParce.First;
      while (not wCdsParce.Eof) do
      begin
        wCdsParce.Edit;
        wCdsParce.FieldByName('ParceMoedaTIP').AsInteger    := Frame_Moeda.ppMoeda;
        wCdsParce.FieldByName('ParceMoedaDES').AsString     := fDataM.fBuscaMoeda(wCdsParce.FieldByName('ParceMoedaTIP').AsInteger);
        wCdsParce.FieldByName('ParceCartaoCOD').AsInteger   := Frame_Cartao.ppCodigo;
        wCdsParce.FieldByName('ParceCartaoDES').AsString    := fDataM.fBuscaCartao(wCdsParce.FieldByName('ParceCartaoTIP').AsInteger, wCdsParce.FieldByName('ParceCartaoCOD').AsInteger);
        wCdsParce.FieldByName('ParceStatusDES').AsString    := fDataM.fBuscaStatusPARCE(wCdsParce.FieldByName('ParceStatusCOD').AsInteger);
        wCdsParce.Post;
        wCdsParce.Next;
      end;
    finally
      DBGridParce.DataSource := dsParce;
      DBGridBaixa.DataSource := dsBaixa;
      wGerandoParce := False;
      wCdsParce.First;
    end;
  end;
end;

procedure TfcCtaRecLan.pAtualizaGradeBaixa;
begin
  pFIBCdsBaixa.Close;
  if (wCdsParce.Active) and (not wCdsParce.IsEmpty) then
  begin
    FIBQueryAtribuirSQL(qrBaixa, 'select B.doctoid, B.parcela, B.sequencia, B.moedatip, '+
                                 'case B.moedatip when 0 then '''' when 1 then ''Dinheiro'' '+
                                 'when 2 then ''Cheque'' when 3 then ''Cartão de Crédito'' '+
                                 'when 4 then ''Cartão de Débito'' when 5 then ''Depósito Bancário'' ' +
                                 'when 6 then ''Permuta'' when 7 then ''Outros'' end as MoedaDES, '+
                                 'B.databaixa, B.DataLancto, B.valorprincipal, B.valorjuros, B.valormulta, B.valordesconto, B.valortotal, B.histodes, '+
                                 'case B.status when 0 then ''Baixa'' when 7 then ''Cancelada'' end as StatusDES '+
                                 'from CtaRecParceBaixa B '+
                                 'WHERE DoctoId = :DoctoId and Parcela = :Parcela '+
                                 'order by Sequencia ');
    qrBaixa.ParamByName('DoctoId').AsInteger := frame_CtaREC.Fatura;
    qrBaixa.ParamByName('Parcela').AsInteger := wCdsParce.FieldByName('ParceParce').AsInteger;
    pFIBCdsBaixa.Open;

    TCurrencyField(pFIBCdsBaixa.FieldByName('valorprincipal')).DisplayFormat  := cMascaraValor;
    TCurrencyField(pFIBCdsBaixa.FieldByName('valorjuros')).DisplayFormat      := cMascaraValor;
    TCurrencyField(pFIBCdsBaixa.FieldByName('valormulta')).DisplayFormat      := cMascaraValor;
    TCurrencyField(pFIBCdsBaixa.FieldByName('valordesconto')).DisplayFormat   := cMascaraValor;
    TCurrencyField(pFIBCdsBaixa.FieldByName('valortotal')).DisplayFormat      := cMascaraValor;
    TCurrencyField(pFIBCdsBaixa.FieldByName('databaixa')).DisplayFormat       := cMascaraDataHora;
    TCurrencyField(pFIBCdsBaixa.FieldByName('DataLancto')).DisplayFormat      := cMascaraDataHora;
  end;
end;

procedure TfcCtaRecLan.OnAfterScroll(DataSet: TDataSet);
begin
  if (not wGerandoParce) then
    pAtualizaGradeBaixa;
end;


procedure TfcCtaRecLan.mmParceAlterarClick(Sender: TObject);
begin
  inherited;
  pAlterarParcela;
end;

procedure TfcCtaRecLan.pmParcelaPopup(Sender: TObject);
begin
  inherited;
  mmParceAlterar.Enabled := (wCdsParce.Active) and (not wCdsParce.IsEmpty) and (wCdsParce.FieldByName('ParceParce').AsInteger > 0) and (wCtaRec.ppDados.StatusCOD < 3);
  mmParceBaixar.Enabled  := (wCdsParce.Active) and (not wCdsParce.IsEmpty) and (wCdsParce.FieldByName('ParceParce').AsInteger > 0) and (wCtaRec.ppDados.StatusCOD < 3);
end;

procedure TfcCtaRecLan.mmParceBaixarClick(Sender: TObject);
var
  wFatura, wMoedaTIP: Integer;
  wVlrSaldo: Currency;
begin
  inherited;
  wFatura    := frame_CtaREC.Fatura;
  wGotoParce := wCdsParce.FieldByName('ParceParce').AsInteger;
  wMoedaTIP  := wCdsParce.FieldByName('ParceMoedaTIP').AsInteger;
  wVlrSaldo  := wCtaRec.fGetSaldoParcela(wCdsParce.FieldByName('ParceParce').AsInteger);
  if (wVlrSaldo <= 0) then
  begin
    MessageDlg('Não há saldo na parcela para fazer a baixa!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (wVlrSaldo > 0) then
  begin
    fcCtaRecBai := TfcCtaRecBai.Create(Self, wFatura, wGotoParce, wMoedaTIP, Frame_Histo.Histo, edHistoDES.Text);
    try
      fcCtaRecBai.ShowModal;
    finally
      FreeAndNil(fcCtaRecBai);
      frame_CtaREC.Fatura := 0;
      frame_CtaREC.Fatura := wFatura;
    end;
  end;
end;

procedure TfcCtaRecLan.DBGridParceDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  inherited;
  case DBGridParce.DataSource.DataSet.FieldByName('ParceStatusCOD').AsInteger of
    0,2: begin // Em aberto / Pagto parcial
           if (DateOf(DBGridParce.DataSource.DataSet.FieldByName('ParceVencto').AsDateTime) > 0) and
              (DateOf(DBGridParce.DataSource.DataSet.FieldByName('ParceVencto').AsDateTime) < DateOf(Date)) then
           begin // Vencida
             DBGridParce.Canvas.Font.Color  := CorGradeFonteAtraso;
             DBGridParce.Canvas.Brush.Color := CorGradeFundoNormal;
           end
           else
           begin
             DBGridParce.Canvas.Font.Color  := CorGradeFonteAberto;
             DBGridParce.Canvas.Brush.Color := CorGradeFundoNormal;
           end;
         end;
      3: begin // Quitado
           DBGridParce.Canvas.Font.Color    := CorGradeFonteQuitado;
           DBGridParce.Canvas.Brush.Color   := CorGradeFundoQuitado;
          end;
  end;
  //
  if (gdSelected in State) then
  begin
    case DBGridParce.DataSource.DataSet.FieldByName('ParceStatusCOD').AsInteger of
    0,2: begin // Em aberto / Pagto parcial
           if (DateOf(DBGridParce.DataSource.DataSet.FieldByName('ParceVencto').AsDateTime) > 0) and
              (DateOf(DBGridParce.DataSource.DataSet.FieldByName('ParceVencto').AsDateTime) < DateOf(Date)) then
           begin // Vencida
             DBGridParce.Canvas.Font.Color  := CorGradeFundoNormal;
             DBGridParce.Canvas.Brush.Color := CorGradeFonteAtraso;
           end
           else
           begin
             DBGridParce.Canvas.Font.Color  := CorGradeFundoNormal;
             DBGridParce.Canvas.Brush.Color := CorGradeFonteAberto;
           end;
         end;
    3: begin
         DBGridParce.Canvas.Font.Color      := CorGradeFonteQuitado;
         DBGridParce.Canvas.Brush.Color     := CorGradeFundoQuitadoSele;
       end;
    else
      begin
         DBGridParce.Canvas.Font.Color      := CorGradeFonteRealceSele;
         DBGridParce.Canvas.Brush.Color     := CorGradeFundoRealceSele;
      end;
    end;
  end;
  //
  DBGridParce.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfcCtaRecLan.btnCancelarClick(Sender: TObject);
var
  wFatura: Integer;
  wErro: String;
begin
  inherited;
  wFatura := frame_CtaREC.Fatura;
  if (wCtaRec.ppDados.StatusCOD < 7) and (frame_CtaREC.Fatura > 0) then
  begin
    if Confirmar('Confirma o cancelamento da Fatura?', clRed, 'Confirme') then
    begin
      if (not wCtaRec.fCancelarFatura(wErro)) then
        MessageDlg(wErro, mtWarning, [mbOK], 0)
      else
      begin
        frame_CtaREC.Fatura := 0;
        frame_CtaREC.Fatura := wFatura;
      end;
    end;
  end;
end;

end.
