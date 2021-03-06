unit ucCtaPagLan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ucPadrao, StdCtrls, Buttons, ExtCtrls, uFrame_CtaPAG,
  uFrame_ForCli, Mask, Menus, uFrame_Historico,
  uFrame_Categoria, uFrame_Moeda, rtCtaPAG, rtFornecedor, rtCartao, DB, Grids,
  DBGrids, uFrame_Cartao, DBClient, pFIBClientDataSet, Provider,
  FIBDataSet, pFIBDataSet, FIBDatabase, pFIBDatabase, 
  rxCurrEdit, rxToolEdit;

type
  TfcCtaPagLan = class(TfcPadrao)
    frame_CtaPAG: Tframe_CtaPAG;
    pmParceTIP: TPopupMenu;
    mmParceTipFixo: TMenuItem;
    mmParceTipCont: TMenuItem;
    pnParce: TPanel;
    gbParce: TGroupBox;
    gbBaixas: TGroupBox;
    btnGravar: TBitBtn;
    btnLimpar: TBitBtn;
    btnCancelar: TBitBtn;
    DBGridParce: TDBGrid;
    dsParce: TDataSource;
    pFIBTrBaixa: TpFIBTransaction;
    qrBaixa: TpFIBDataSet;
    pFIBDSProvBaixa: TpFIBDataSetProvider;
    pFIBCdsBaixa: TpFIBClientDataSet;
    dsBaixa: TDataSource;
    DBGridBaixa: TDBGrid;
    lbStatus: TLabel;
    pmParcela: TPopupMenu;
    mmParceAlterar: TMenuItem;
    mmParceBaixar: TMenuItem;
    N1: TMenuItem;
    pnEdicao: TPanel;
    Frame_ForCli: TFrame_ForCli;
    Label1: TLabel;
    edDataEmissao: TDateEdit;
    Label2: TLabel;
    edDoctoNRO: TEdit;
    Label3: TLabel;
    pnCombo: TPanel;
    edParcelaQTDE: TCurrencyEdit;
    Label4: TLabel;
    edPacelaVLR: TCurrencyEdit;
    Label6: TLabel;
    edVlr1aParce: TCurrencyEdit;
    Label10: TLabel;
    edVlrPrincipal: TCurrencyEdit;
    Label7: TLabel;
    edDiaFixo: TCurrencyEdit;
    Label5: TLabel;
    edData1aParce: TDateEdit;
    Frame_Moeda: TFrame_Moeda;
    Frame_Cartao: TFrame_Cartao;
    spGerarParcelas: TSpeedButton;
    frame_CategoriaSai: Tframe_Categoria;
    Label12: TLabel;
    edHistoDES: TEdit;
    Label8: TLabel;
    edDescricao: TEdit;
    Frame_Histo: TFrame_Historico;
    frame_CategoriaDes: Tframe_Categoria;
    N2: TMenuItem;
    mmGerarParcela: TMenuItem;
    procedure pnComboClick(Sender: TObject);
    procedure mmParceTipContClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure frame_CtaPAGedFaturaKeyPress(Sender: TObject; var Key: Char);
    procedure edParcelaQTDEChange(Sender: TObject);
    procedure edPacelaVLRExit(Sender: TObject);
    procedure edVlrPrincipalExit(Sender: TObject);
    procedure edHistoDESKeyPress(Sender: TObject; var Key: Char);
    procedure edHistoDESEnter(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnLimparClick(Sender: TObject);
    procedure spGerarParcelasClick(Sender: TObject);
    procedure edData1aParceExit(Sender: TObject);
    procedure Frame_MoedacbMoedaChange(Sender: TObject);
    procedure edDiaFixoExit(Sender: TObject);
    procedure DBGridParceDblClick(Sender: TObject);
    procedure mmParceAlterarClick(Sender: TObject);
    procedure pmParcelaPopup(Sender: TObject);
    procedure mmParceBaixarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGridParceDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnCancelarClick(Sender: TObject);
    procedure mmGerarParcelaClick(Sender: TObject);
  private
    fTipoTela: Integer;
    wFaturaAtu, wHistoAtu: Integer;
    wCartaoCOD: Integer;
    wCtaPag: TCtaPag;
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
  fcCtaPagLan: TfcCtaPagLan;

implementation

uses rtHistorico, uUtils, uDataM, rtTypes, DateUtils, Math,
     ucCtaPagLanParceAlt, ucCtaPagBai;

{$R *.dfm}

constructor TfcCtaPagLan.Create(Aowner: TComponent; prTipo: Integer);
begin
  Inherited Create(Aowner);
  fTipoTela := prTipo;
end;

procedure TfcCtaPagLan.FormShow(Sender: TObject);
begin
  inherited;
  if (fTipoTela = 1) then
  begin
    Self.Caption           := 'Contas A PAGAR - Baixa de Pagamentos';
    pnEdicao.Enabled       := False;
    mmParceAlterar.Visible := False;
  end;
end;

procedure TfcCtaPagLan.pnComboClick(Sender: TObject);
begin
  inherited;
  pmParceTIP.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;

procedure TfcCtaPagLan.mmParceTipContClick(Sender: TObject);
begin
  inherited;
  mmParceTipFixo.Checked := (Sender = mmParceTipFixo);
  mmParceTipCont.Checked := (Sender = mmParceTipCont);

  edParcelaQTDE.Color     := clWindow;
  edVlrPrincipal.Color    := clWindow;
  edVlr1aParce.Color      := clWindow;
  edParcelaQTDE.Enabled   := mmParceTipFixo.Checked;
  edVlrPrincipal.Enabled  := mmParceTipFixo.Checked;
  edVlr1aParce.Enabled    := mmParceTipFixo.Checked;

  if (not edParcelaQTDE.Enabled) then
  begin
    edParcelaQTDE.Clear;
    edVlrPrincipal.Clear;
    edVlr1aParce.Clear;
    edParcelaQTDE.Color  := clSilver;
    edVlrPrincipal.Color := clSilver;
    edVlr1aParce.Color   := clSilver;
  end;
end;

procedure TfcCtaPagLan.FormCreate(Sender: TObject);
begin
  inherited;
  wGerandoParce := False;
  wCtaPag := TCtaPag.Create;
  Frame_ForCli.OnDepoisBusca      := pCarregaForCli;
  Frame_Histo.OnDepoisBusca       := pCarregaHisto;
  frame_CtaPAG.OnDepoisBusca      := pCarregaFatura;
  Frame_Cartao.OnDepoisBusca      := pCarregaCartao;
  frame_CategoriaDes.FiltroClassi := 'AND (Classificacao Like ''2.1.1.02%'')';
  frame_CategoriaSai.FiltroClassi := 'AND (Classificacao Like ''1.%'')';

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

procedure TfcCtaPagLan.pCarregaForCli(Sender: TObject; Encontrou: Boolean);
begin
  if (Encontrou) then
    Frame_Moeda.ppMoeda    := Frame_ForCli.MoedaTIP;
end;

procedure TfcCtaPagLan.pCarregaHisto(Sender: TObject; Encontrou: Boolean);
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

procedure TfcCtaPagLan.pCarregaCartao(Sender: TObject; Encontrou: Boolean);
begin
  if (Encontrou) and (wCartaoCOD <> Frame_Cartao.Codigo) then
  begin
    wCartaoCOD := Frame_Cartao.Codigo;
    if (Frame_Cartao.TpDebCre = 0) and (Frame_Cartao.CategDeb > 0) then
      frame_CategoriaSai.Codigo := Frame_Cartao.CategDeb
    else if (Frame_Cartao.TpDebCre = 1) and (Frame_Cartao.CategCre > 0) then
      frame_CategoriaSai.Codigo := Frame_Cartao.CategCre
    else if (Frame_Cartao.TpDebCre = 2) then
    begin
      if (Frame_Cartao.CategDeb > 0) and (Frame_Cartao.CategCre = 0) then
        frame_CategoriaSai.Codigo := Frame_Cartao.CategDeb
      else
        if (Frame_Cartao.CategDeb = 0) and (Frame_Cartao.CategCre > 0) then
        frame_CategoriaSai.Codigo := Frame_Cartao.CategCre;
    end;
    pCalculaParcelas;
  end;
end;

procedure TfcCtaPagLan.pCarregaFatura(Sender: TObject; Encontrou: Boolean);
var
  wTipForCli: TTipForCli;
  wParce, wGoto: Integer;
begin
  spGerarParcelas.Enabled := False;
  wTipForCli.Tipo := -1;
  wTipForCli.Codi := 0;

  if (wFaturaAtu <> frame_CtaPAG.Fatura) or (frame_CtaPAG.Fatura = 0) then
  begin
    pLimpaTela;
    fSetaFoco([Frame_ForCli.edNome]);
    if (Encontrou) then
    begin
      wFaturaAtu := frame_CtaPAG.Fatura;
      frame_CtaPAG.edFatura.AsInteger := frame_CtaPAG.Fatura;
      wCtaPag.ppCodigo := frame_CtaPAG.Fatura;
      pMostraStatus(wCtaPag.ppDados.StatusCOD);
      wTipForCli.Tipo             := wCtaPag.ppDados.EmitenteTIP;
      wTipForCli.Codi             := wCtaPag.ppDados.EmitenteCOD;
      Frame_ForCli.TipForCli      := wTipForCli;

      edDoctoNRO.Text             := wCtaPag.ppDados.DoctoNRO;
      edDataEmissao.Date          := wCtaPag.ppDados.DataEmissao;
      mmParceTipFixo.Checked      := wCtaPag.ppDados.ParcelaTIPO = 0;
      mmParceTipCont.Checked      := wCtaPag.ppDados.ParcelaTIPO = 1;
      edParcelaQTDE.AsInteger     := wCtaPag.ppDados.ParcelaQTDE;
      edPacelaVLR.Value           := wCtaPag.ppDados.ValorParcela;
      edVlrPrincipal.Value        := wCtaPag.ppDados.ValorPrincipal;
      edData1aParce.Date          := wCtaPag.ppDados.PrimParceData;
      edVlr1aParce.Value          := wCtaPag.ppDados.PrimParceValor;
      edDiaFixo.AsInteger         := wCtaPag.ppDados.DiaFixoVencto;
      Frame_Moeda.ppMoeda         := wCtaPag.ppDados.MoedaTIP;
      Frame_MoedacbMoedaChange(Sender);
      Frame_Cartao.ppCodigo       := wCtaPag.ppDados.Codigo;
      frame_CategoriaDes.Codigo   := wCtaPag.ppDados.CategoriaDes;
      frame_CategoriaSai.Codigo   := wCtaPag.ppDados.CategoriaSai;
      Frame_Histo.Histo           := 0;
      edHistoDES.Text             := wCtaPag.ppDados.HistoDES;
      Frame_Histo.edHisto.Enabled := (wCtaPag.ppDados.StatusCOD < 2) and (edHistoDES.Text = '');
      edDescricao.Text            := wCtaPag.ppDados.Descricao;

      wGerandoParce := True;
      DBGridParce.DataSource := nil;
      DBGridBaixa.DataSource := nil;
      wCdsParce.EmptyDataSet;
      wGoto := 0;
      try
        for wParce := Low(wCtaPag.ppDados.Parcelas) to High(wCtaPag.ppDados.Parcelas) do
        begin
          wCdsParce.Append;
          wCdsParce.FieldByName('ParceParce').AsInteger       := wCtaPag.ppDados.Parcelas[wParce].Parcela;
          wCdsParce.FieldByName('ParceVencto').AsDateTime     := wCtaPag.ppDados.Parcelas[wParce].DataVencto;
          wCdsParce.FieldByName('ParceVlrPri').AsCurrency     := wCtaPag.ppDados.Parcelas[wParce].ValorParcela;
          wCdsParce.FieldByName('ParceVlrPag').AsCurrency     := wCtaPag.fGetPagoParcela(wCdsParce.FieldByName('ParceParce').AsInteger);
          wCdsParce.FieldByName('ParceVlrSal').AsCurrency     := wCdsParce.FieldByName('ParceVlrPri').AsCurrency - wCdsParce.FieldByName('ParceVlrPag').AsCurrency;
          wCdsParce.FieldByName('ParceMoedaTIP').AsInteger    := wCtaPag.ppDados.Parcelas[wParce].MoedaTIP;
          wCdsParce.FieldByName('ParceMoedaDES').AsString     := wCtaPag.ppDados.Parcelas[wParce].MoedaDES;
          wCdsParce.FieldByName('ParceCartaoTIP').AsInteger   := wCtaPag.ppDados.Parcelas[wParce].CartaoTIP;
          wCdsParce.FieldByName('ParceCartaoCOD').AsInteger   := wCtaPag.ppDados.Parcelas[wParce].CartaoCOD;
          wCdsParce.FieldByName('ParceCartaoDES').AsString    := wCtaPag.ppDados.Parcelas[wParce].CartaoDES;
          wCdsParce.FieldByName('ParceStatusCOD').AsInteger   := wCtaPag.ppDados.Parcelas[wParce].StatusCOD;
          wCdsParce.FieldByName('ParceStatusDES').AsString    := wCtaPag.ppDados.Parcelas[wParce].StatusDES;
          if (wGoto = 0) and (wCtaPag.ppDados.Parcelas[wParce].StatusCOD < 3) then
            wGoto := wCtaPag.ppDados.Parcelas[wParce].Parcela;
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
  edParcelaQTDE.Enabled       := (wCtaPag.ppDados.StatusCOD < 2) or (frame_CtaPAG.Fatura = 0);
  edPacelaVLR.Enabled         := (wCtaPag.ppDados.StatusCOD < 2) or (frame_CtaPAG.Fatura = 0);
  edVlr1aParce.Enabled        := (wCtaPag.ppDados.StatusCOD < 2) or (frame_CtaPAG.Fatura = 0);
  edVlrPrincipal.Enabled      := (wCtaPag.ppDados.StatusCOD < 2) or (frame_CtaPAG.Fatura = 0);
  edDiaFixo.Enabled           := (wCtaPag.ppDados.StatusCOD < 2) or (frame_CtaPAG.Fatura = 0);
  edData1aParce.Enabled       := (wCtaPag.ppDados.StatusCOD < 2) or (frame_CtaPAG.Fatura = 0);
  Frame_Histo.edHisto.Enabled := ((wCtaPag.ppDados.StatusCOD < 2) and (edHistoDES.Text = '')) or (frame_CtaPAG.Fatura = 0);
  spGerarParcelas.Enabled     := (wCtaPag.ppDados.StatusCOD < 2) or (frame_CtaPAG.Fatura = 0);

  btnGravar.Enabled           := (wCtaPag.ppDados.StatusCOD < 2) or (frame_CtaPAG.Fatura = 0);
  btnCancelar.Enabled         := (wCtaPag.ppDados.StatusCOD < 7) and (frame_CtaPAG.Fatura > 0);
end;

procedure TfcCtaPagLan.frame_CtaPAGedFaturaKeyPress(Sender: TObject; var Key: Char);
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

procedure TfcCtaPagLan.edParcelaQTDEChange(Sender: TObject);
begin
  inherited;
  if edPacelaVLR.Value > 0 then
    edVlrPrincipal.Value := edParcelaQTDE.AsInteger * edPacelaVLR.Value
  else if (edVlrPrincipal.Value > 0) and (edParcelaQTDE.AsInteger > 0) then
    edPacelaVLR.Value := edPacelaVLR.Value / edParcelaQTDE.AsInteger;
end;

procedure TfcCtaPagLan.pCalculaData1aParcela(prData: TDate);
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

procedure TfcCtaPagLan.edPacelaVLRExit(Sender: TObject);
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

procedure TfcCtaPagLan.edVlrPrincipalExit(Sender: TObject);
begin
  inherited;
  if (edVlrPrincipal.Value > 0) and (edParcelaQTDE.AsInteger > 0) then
    edPacelaVLR.Value := edVlrPrincipal.Value / edParcelaQTDE.AsInteger;
end;

procedure TfcCtaPagLan.edHistoDESKeyPress(Sender: TObject; var Key: Char);
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

    try
      if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
        SelectNext(Sender as TWinControl, False, True)
      else
        SelectNext(Sender as TWinControl, True, True);
    except
    end;
    Key := #0
  end;

  if Key = #27 then
  begin
    try
      if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
        SelectNext(Sender as TWinControl, True, True)
      else
        SelectNext(Sender as TWinControl, False, True);
    except
    end;
    Key := #0
  end;
end;

procedure TfcCtaPagLan.edHistoDESEnter(Sender: TObject);
begin
  inherited;
  if Pos('*', edHistoDES.Text) > 0 then
  begin
    edHistoDES.SelStart  := Pos('*', edHistoDES.Text) - 1;
    edHistoDES.SelLength := 1;
  end;
end;

function  TfcCtaPagLan.fConsisteDados: Boolean;
var
  wSomaParce: Currency;
begin
  Result := False;

  if (frame_CtaPAG.Fatura > 0) then
  begin
    if wCtaPag.fFaturaTemBaixas(frame_CtaPAG.Fatura) then
    begin
      MessageDlg('A Fatura j� tem baixas e n�o pode ser alterada', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (Frame_ForCli.Tipo < -1) or (Frame_ForCli.Tipo > 1) then
  begin
    MessageDlg('O Tipo de emitente n�o foi informado corretamente', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (Frame_ForCli.Tipo > -1) then
  begin
    case Frame_ForCli.Tipo of
      0: begin
           if (Frame_ForCli.Codigo < 0) then
           begin
             MessageDlg('O C�digo do emitente (fornecedor) n�o foi informado!', mtWarning, [mbOk], 0);
             Exit;
           end;

           if (not fEstaCadastrado(Frame_ForCli.Codigo, 'Fornecedor', 'Codigo', True)) then
           begin
             MessageDlg('O emitente (fornecedor) n�o est� cadastrado', mtWarning, [mbOk], 0);
             Exit;
           end;
         end;
      1: begin
           if (Frame_ForCli.Codigo < 0) then
           begin
             MessageDlg('O C�digo do emitente (cliente) n�o foi informado', mtWarning, [mbOk], 0);
             Exit;
           end;

           if (not fEstaCadastrado(Frame_ForCli.Codigo, 'Cliente', 'Codigo', True)) then
           begin
             MessageDlg('O emitente (cliente) n�o est� cadastrado', mtWarning, [mbOk], 0);
             Exit;
           end;
         end;
    end;
  end;

  if Length(Trim(edDoctoNRO.Text)) = 0 then
  begin
    MessageDlg('O n�mero do documento n�o foi informado', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (edDataEmissao.Date < cDataMinima) or (edDataEmissao.Date > cDataMaxima) then
  begin
    MessageDlg('A data de emiss�o informada est� fora do per�odo de aceita��o', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (DateOf(edDataEmissao.Date) > DateOf(fDataM.fDataHoraServidor)) then
  begin
    MessageDlg('A data de emiss�o informada � maior que a data atual', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (not mmParceTipFixo.Checked) and (not mmParceTipCont.Checked) then
  begin
    MessageDlg('O tipo de parcelamento n�o foi selecionado', mtWarning, [mbOk], 0);
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
    MessageDlg('A data da primeira parcela est� fora do periodo de aceita��o', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (edData1aParce.Date < edDataEmissao.Date) then
  begin
    MessageDlg('A data da primeira parcela � anterior � emiss�o do documento', mtWarning, [mbOk], 0);
    Exit;
  end;

  if mmParceTipFixo.Checked then
  begin
    if (edPacelaVLR.Value <> 0) then
    begin
      if (edPacelaVLR.Value < 0) then
      begin
        MessageDlg('O valor da primeira parcela deve ser zero ou maior', mtWarning, [mbOk], 0);
        Exit;
      end;

      if (edPacelaVLR.Value > edVlrPrincipal.Value) then
      begin
        MessageDlg('O valor da primeira parcela � maior que o valor total', mtWarning, [mbOk], 0);
        Exit;
      end;
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

  if mmParceTipFixo.Checked then
  begin
    if (edVlrPrincipal.Value <= 0) then
    begin
      MessageDlg('O valor total deve ser maior que zero', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if Frame_Moeda.ppMoeda < 0 then
  begin
    MessageDlg('O tipo de moeda n�o foi informado', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (Frame_Moeda.ppMoeda = 3) or (Frame_Moeda.ppMoeda = 4) then
  begin
    if (Frame_Cartao.Codigo < 1) then
    begin
      MessageDlg('O cart�o de cr�dito / d�bito n�o foi informado', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (frame_CategoriaDes.Codigo < 1) then
  begin
    MessageDlg('A categoria de despesas n�o foi informada', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (frame_CategoriaSai.Codigo < 1) then
  begin
    MessageDlg('A categoria pagadora n�o foi informada', mtWarning, [mbOk], 0);
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

  if (mmParceTipFixo.Checked) and (wSomaParce < 0.01) or ( RoundTo(wSomaParce, -2) <> RoundTo(edVlrPrincipal.Value, -2) ) then
  begin
    MessageDlg('A soma das parcelas � diferente do Valor Total da Fatura!', mtWarning, [mbOk], 0);
    Exit;
  end;

  Result := True;
end;

procedure TfcCtaPagLan.btnGravarClick(Sender: TObject);
var
  wID, wParce: Integer;
  wDados: TDadosPAG;
  wParcelas: TParcelas;
begin
  inherited;
  if (not fConsisteDados) then Exit;

  wCtaPag.Clear;
  wDados.id          := 0;
  wDados.Empre       := fDataM.Empresa;
  wDados.Codigo      := frame_CtaPAG.edFatura.AsInteger;
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
  wDados.CartaoTIP        := Frame_Cartao.TpDebCre;
  wDados.CartaoCOD        := Frame_Cartao.Codigo;
  wDados.CategoriaDes     := frame_CategoriaDes.Codigo;
  wDados.CategoriaSai     := frame_CategoriaSai.Codigo;
  wDados.HistoDES         := edHistoDES.Text;
  wDados.Descricao        := edDescricao.Text;
  wDados.StatusCOD        := 1; // Desdobrada - S� no INSERT

  wCtaPag.ppDados := wDados;
  wID := wCtaPag.fGravar;

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
        wParcelas[wParce - 1].CartaoTIP    := wCdsParce.FieldByName('ParceCartaoTIP').AsInteger;
        wParcelas[wParce - 1].CartaoCOD    := wCdsParce.FieldByName('ParceCartaoCOD').AsInteger;
        wParcelas[wParce - 1].StatusCOD    := wCdsParce.FieldByName('ParceStatusCOD').AsInteger;
        wCdsParce.Next;
      end;
      wCtaPag.fGravarParcelas(wID, wParcelas, wCtaPag.ppDados.StatusCOD, wCtaPag.ppDados.EmitenteTIP);
      wFaturaAtu := 0;
      fSetaFoco([frame_CtaPAG.edFatura]);
    finally
      wGerandoParce := False;
      wCdsParce.EnableControls;
      frame_CtaPAG.ID := wID;
    end;
  end
  else
  begin
    fSetaFoco([Frame_ForCli.edNome]);
  end;
end;

procedure TfcCtaPagLan.DBGridParceDblClick(Sender: TObject);
begin
  if (wCdsParce.Active) and (not wCdsParce.IsEmpty) and (wCdsParce.FieldByName('ParceParce').AsInteger > 0) and (wCtaPag.ppDados.StatusCOD < 3) then
    pAlterarParcela;
end;

procedure TfcCtaPagLan.pAlterarParcela;
var
  wParcela: TParcela;
begin
  inherited;
  if (fTipoTela = 1) then Exit;

  fcCtaPagLanParceAlt := TfcCtaPagLanParceAlt.Create(Self);
  try
    wParcela.DoctoID      := frame_CtaPAG.Fatura;
    wParcela.Parcela      := wCdsParce.FieldByName('ParceParce').AsInteger;
    wParcela.DataVencto   := wCdsParce.FieldByName('ParceVencto').AsDateTime;
    wParcela.ValorParcela := wCdsParce.FieldByName('ParceVlrPri').AsCurrency;
    wParcela.MoedaTIP     := wCdsParce.FieldByName('ParceMoedaTIP').AsInteger;
    wParcela.CartaoTIP    := wCdsParce.FieldByName('ParceCartaoTIP').AsInteger;
    wParcela.CartaoCOD    := wCdsParce.FieldByName('ParceCartaoCOD').AsInteger;
    //
    fcCtaPagLanParceAlt.edDataVencto.Date      := wCdsParce.FieldByName('ParceVencto').AsDateTime;
    fcCtaPagLanParceAlt.Frame_Moeda.ppMoeda    := wCdsParce.FieldByName('ParceMoedaTIP').AsInteger;
    fcCtaPagLanParceAlt.Frame_Cartao.ppCodigo  := wCdsParce.FieldByName('ParceCartaoCOD').AsInteger;

    fcCtaPagLanParceAlt.ShowModal;
    if fcCtaPagLanParceAlt.ModalResult = mrOk then
    begin
      if (fcCtaPagLanParceAlt.ppDataVencto <> wCdsParce.FieldByName('ParceVencto').AsDateTime) or
         (fcCtaPagLanParceAlt.ppMoeda      <> wCdsParce.FieldByName('ParceMoedaTIP').AsInteger) or
         (fcCtaPagLanParceAlt.Frame_Cartao.ppCodigo <> wCdsParce.FieldByName('ParceCartaoCOD').AsInteger) then
      begin
        wParcela.DataVencto   := fcCtaPagLanParceAlt.ppDataVencto;
        wParcela.MoedaTIP     := fcCtaPagLanParceAlt.ppMoeda;
        wParcela.CartaoCOD    := fcCtaPagLanParceAlt.Frame_Cartao.ppCodigo;
        wCtaPag.fAlterarParcela(wParcela);
        frame_CtaPAG.Fatura := 0;
        frame_CtaPAG.Fatura := wParcela.DoctoID;
      end;
    end;
  finally
    FreeAndNil(fcCtaPagLanParceAlt);
  end;
end;

procedure TfcCtaPagLan.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  wCtaPag.Free;
end;

procedure TfcCtaPagLan.btnLimparClick(Sender: TObject);
begin
  inherited;
  frame_CtaPAG.Fatura := 0;
  pLimpaTela;
  fSetaFoco([frame_CtaPAG.edFatura]);
end;

procedure TfcCtaPagLan.pMostraStatus(prSta: Integer);
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

procedure TfcCtaPagLan.pLimpaTela;
begin
  wCtaPag.Clear;

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
  frame_CategoriaDes.Clear;
  frame_CategoriaSai.Clear;
  Frame_Histo.Histo := 0;
  edHistoDES.Clear;
  edDescricao.Clear;
  wCdsParce.EmptyDataSet;
  pFIBCdsBaixa.Close;
end;

procedure TfcCtaPagLan.spGerarParcelasClick(Sender: TObject);
begin
  pCalculaParcelas;
end;

procedure TfcCtaPagLan.edData1aParceExit(Sender: TObject);
begin
  inherited;
  if wCtaPag.ppDados.StatusCOD < 2 then
    spGerarParcelasClick(Sender);
end;

procedure TfcCtaPagLan.Frame_MoedacbMoedaChange(Sender: TObject);
begin
  inherited;
  Frame_Cartao.Enabled := (Frame_Moeda.ppMoeda = 3) or (Frame_Moeda.ppMoeda = 4);

  Frame_Cartao.Clear;
  Frame_Cartao.Invalidate;
  spGerarParcelasClick(Sender);
end;

procedure TfcCtaPagLan.edDiaFixoExit(Sender: TObject);
begin
  inherited;
  pCalculaData1aParcela(edDataEmissao.Date);
end;

procedure TfcCtaPagLan.pCalculaParcelas;
var
  wParce: Integer;
  wDataVenctoAnt: TDateTime;
  wVlrParce, wSoma, wDiferenca: Currency;
begin
  inherited;
  if (wCtaPag.ppDados.StatusCOD < 2) then
  begin
    wGerandoParce := True;
    DBGridParce.DataSource := nil;
    DBGridBaixa.DataSource := nil;
    try
      wCdsParce.EmptyDataSet;
      if (mmParceTipFixo.Checked) then
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
          wCdsParce.FieldByName('ParceVlrPag').AsCurrency     := wCtaPag.fGetPagoParcela(wCdsParce.FieldByName('ParceParce').AsInteger);
          wCdsParce.FieldByName('ParceVlrSal').AsCurrency     := wCdsParce.FieldByName('ParceVlrPri').AsCurrency - wCdsParce.FieldByName('ParceVlrPag').AsCurrency;

          wCdsParce.FieldByName('ParceMoedaTIP').AsInteger    := Frame_Moeda.ppMoeda;
          wCdsParce.FieldByName('ParceMoedaDES').AsString     := fDataM.fBuscaMoeda(wCdsParce.FieldByName('ParceMoedaTIP').AsInteger);
          wCdsParce.FieldByName('ParceCartaoCOD').AsInteger   := Frame_Cartao.Codigo;
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
        wCdsParce.FieldByName('ParceCartaoCOD').AsInteger   := Frame_Cartao.Codigo;
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

procedure TfcCtaPagLan.pAtualizaGradeBaixa;
begin
  pFIBCdsBaixa.Close;
  if (wCdsParce.Active) and (not wCdsParce.IsEmpty) then
  begin
    FIBQueryAtribuirSQL(qrBaixa, 'select B.doctoid, B.parcela, B.sequencia, B.moedatip, '+
                                 'case B.moedatip when 0 then '''' when 1 then ''Dinheiro'' '+
                                 'when 2 then ''Cheque'' when 3 then ''Cart�o de Cr�dito'' '+
                                 'when 4 then ''Cart�o de D�bito'' when 5 then ''Dep�sito Banc�rio'' ' +
                                 'when 6 then ''Permuta'' when 7 then ''Outros'' end as MoedaDES, '+
                                 'B.databaixa, B.DataLancto, B.valorprincipal, B.valorjuros, B.valormulta, B.valordesconto, B.valortotal, B.histodes, '+
                                 'case B.status when 0 then ''Baixa'' when 7 then ''Cancelada'' end as StatusDES '+
                                 'from CtaPagParceBaixa B '+
                                 'WHERE DoctoId = :DoctoId and Parcela = :Parcela '+
                                 'order by Sequencia ');
    qrBaixa.ParamByName('DoctoId').AsInteger := frame_CtaPAG.Fatura;
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

procedure TfcCtaPagLan.OnAfterScroll(DataSet: TDataSet);
begin
  if (not wGerandoParce) then
    pAtualizaGradeBaixa;
end;

procedure TfcCtaPagLan.mmParceAlterarClick(Sender: TObject);
begin
  inherited;
  pAlterarParcela;
end;

procedure TfcCtaPagLan.pmParcelaPopup(Sender: TObject);
begin
  inherited;
  mmParceAlterar.Enabled := (wCdsParce.Active) and (not wCdsParce.IsEmpty) and (wCdsParce.FieldByName('ParceParce').AsInteger > 0) and (wCtaPag.ppDados.StatusCOD < 3);
  mmParceBaixar.Enabled  := (wCdsParce.Active) and (not wCdsParce.IsEmpty) and (wCdsParce.FieldByName('ParceParce').AsInteger > 0) and (wCtaPag.ppDados.StatusCOD < 3);
end;

procedure TfcCtaPagLan.mmParceBaixarClick(Sender: TObject);
var
  wFatura, wMoedaTIP: Integer;
  wVlrSaldo: Currency;
begin
  inherited;
  wFatura    := frame_CtaPAG.Fatura;
  wGotoParce := wCdsParce.FieldByName('ParceParce').AsInteger;
  wMoedaTIP  := wCdsParce.FieldByName('ParceMoedaTIP').AsInteger;
  wVlrSaldo  := wCtaPag.fGetSaldoParcela(wCdsParce.FieldByName('ParceParce').AsInteger);
  if (wVlrSaldo <= 0) then
  begin
    MessageDlg('N�o h� saldo na parcela para fazer a baixa!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (wVlrSaldo > 0) then
  begin
    fcCtaPagBai := TfcCtaPagBai.Create(Self, wFatura, wGotoParce, wMoedaTIP, Frame_Histo.Histo, edHistoDES.Text);
    try
      fcCtaPagBai.ShowModal;
    finally
      FreeAndNil(fcCtaPagBai);
      frame_CtaPAG.Fatura := 0;
      frame_CtaPAG.Fatura := wFatura;
    end;
  end;
end;

procedure TfcCtaPagLan.DBGridParceDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
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

procedure TfcCtaPagLan.btnCancelarClick(Sender: TObject);
var
  wFatura: Integer;
  wErro: String;
begin
  inherited;
  wFatura := frame_CtaPAG.Fatura;
  if (wCtaPag.ppDados.StatusCOD < 7) and (frame_CtaPAG.Fatura > 0) then
  begin
    if Confirmar('Confirma o cancelamento da Fatura?', clRed, 'Confirme') then
    begin
      if (not wCtaPag.fCancelarFatura(wErro)) then
        MessageDlg(wErro, mtWarning, [mbOK], 0)
      else
      begin
        frame_CtaPAG.Fatura := 0;
        frame_CtaPAG.Fatura := wFatura;
      end;
    end;
  end;
end;

procedure TfcCtaPagLan.mmGerarParcelaClick(Sender: TObject);
var
  wParceUlt, wParcelas: TParcelas;
  wParce: Integer;
begin
  inherited;
  wParceUlt := wCtaPag.fGetMaxParcela(frame_CtaPAG.ID);
  wParce    := wParceUlt[0].Parcela + 1;
  SetLength(wParcelas, wParce);
  wParcelas[wParce - 1].DoctoID      := frame_CtaPAG.ID;
  wParcelas[wParce - 1].Parcela      := wParce;
  wParcelas[wParce - 1].DataVencto   := IncMonth(wParceUlt[0].DataVencto, 1);
  wParcelas[wParce - 1].ValorParcela := edPacelaVLR.Value;
  wParcelas[wParce - 1].MoedaTIP     := Frame_Moeda.ppMoeda;
  wParcelas[wParce - 1].CartaoCOD    := Frame_Cartao.Codigo;
  wParcelas[wParce - 1].StatusCOD    := 0;
  wCtaPag.fGravarParcelas(frame_CtaPAG.ID, wParcelas, wCtaPag.ppDados.StatusCOD, wCtaPag.ppDados.EmitenteTIP);
end;

end.
