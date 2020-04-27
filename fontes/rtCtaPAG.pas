unit rtCtaPAG;

interface

uses
  pFIBDatabase, pFIBQuery, SysUtils, Dialogs, Controls, DB, DBClient, Classes, Graphics,
  rtTypes;

type
  TParcela = packed record
    DoctoID        : Integer;
    Parcela        : Integer;
    DataVencto     : TDate;
    ValorParcela   : Currency;
    MoedaTIP       : Integer;
    MoedaDES       : String;
    CartaoTIP      : Integer;
    CartaoCOD      : Integer;
    CartaoDES      : String;
    StatusCOD      : Integer;
    StatusDES      : String;
  end;
  TParcelas = array of TParcela;

  TDadosPAG = packed record
    id             : Integer;
    Empre          : Integer;
    Codigo         : Integer;
    EmitenteTIP    : Integer;
    EmitenteCOD    : Integer;
    DoctoNRO       : String;
    DataEmissao    : TDate;
    ParcelaQTDE    : Integer;
    ParcelaTIPO    : Integer;
    PrimParceData  : TDate;
    PrimParceValor : Currency;
    DiaFixoVencto  : Integer;
    ValorParcela   : Currency;
    ValorPrincipal : Currency;
    ValorPago      : Currency;
    HistoDES       : String;
    Descricao      : String;
    MoedaTIP       : Integer;
    CartaoTIP      : Integer;
    CartaoCOD      : Integer;
    CategoriaDes   : Integer; // Despesa
    CategoriaSai   : Integer; // Saida
    StatusCOD      : Integer;
    StatusDES      : String;
    Parcelas       : TParcelas;
  end;

  TCtaPag = class
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosPAG: TDadosPAG;
    function  getCodigo: Integer;
    procedure setCodigo(const Value: Integer);
    function  getID: Integer;
    procedure setID(const Value: Integer);
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Clear;

    function fFaturaTemBaixas(prDoctoID: Integer): Boolean;
    function fGravar: Integer;
    function fGravarParcelas(prDoctoID: Integer; prParcelas: TParcelas; prStaFat, prParcelamento: Integer): Boolean;
    function fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
    function fCancelarFatura(var prErro: String): Boolean;
    function fAlterarParcela(prParcela: TParcela): Boolean;
    function fEstornarPagto(prParcela, Sequencia: Integer): Boolean;

    function fGetSaldoParcela(prParcela: Integer): Currency;
    function fBaixarParcela(prParcela, prMoedaTIP, prHistoCOD: Integer; prDataBaixa: TDateTime; prVlrPri, prVlrJur, prVlrMul, prVlrDes: Currency; prHistoDES: String): Boolean;

    function fGetPagoParcela(prParcela: Integer): Currency;
    function fGetMaxParcela(prDoctoID: Integer): TParcelas;

    property ppDados: TDadosPAG read fDadosPAG write fDadosPAG;
    property ppCodigo: Integer read getCodigo write setCodigo;
    property ppID    : Integer read getID     write setID;
end;

implementation

uses uDataM, FIBQuery, uUtils, DateUtils;

constructor TCtaPag.Create;
begin
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TCtaPag.Destroy;
begin
  FIBQueryDestruir(fQuery);
  inherited;
end;

procedure TCtaPag.Clear;
begin
  FillChar(fDadosPAG, SizeOf(fDadosPAG), #0);
end;

function TCtaPag.getCodigo: Integer;
begin
  Result := fDadosPAG.Codigo;
end;

procedure TCtaPag.setCodigo(const Value: Integer);

  procedure pBuscaParcelas;
  var
    wParce: Integer;
  begin
    wParce := 0;
    SetLength(fDadosPAG.Parcelas, wParce);
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM CtaPagParce '+
                                'WHERE DoctoID = :DoctoID');
    fQuery.ParamByName('DoctoID').AsInteger := fDadosPAG.id;
    fQuery.ExecQuery;
    while (not fQuery.Eof) do
    begin
      Inc(wParce);
      SetLength(fDadosPAG.Parcelas, wParce);
      fDadosPAG.Parcelas[wParce - 1].DoctoID      := fDadosPAG.id;
      fDadosPAG.Parcelas[wParce - 1].Parcela      := fQuery.FieldByName('Parcela').AsInteger;
      fDadosPAG.Parcelas[wParce - 1].DataVencto   := fQuery.FieldByName('DataVencto').AsDateTime;
      fDadosPAG.Parcelas[wParce - 1].ValorParcela := fQuery.FieldByName('ValorParcela').AsCurrency;
      fDadosPAG.Parcelas[wParce - 1].MoedaTIP     := fQuery.FieldByName('MoedaTIP').AsInteger;
      fDadosPAG.Parcelas[wParce - 1].MoedaDES     := fDataM.fBuscaMoeda(fQuery.FieldByName('MoedaTIP').AsInteger);
      fDadosPAG.Parcelas[wParce - 1].CartaoTIP    := fQuery.FieldByName('CartaoTIP').AsInteger;
      fDadosPAG.Parcelas[wParce - 1].CartaoCOD    := fQuery.FieldByName('CartaoCOD').AsInteger;
      fDadosPAG.Parcelas[wParce - 1].CartaoDES    := fDataM.fBuscaCartao(fQuery.FieldByName('CartaoTIP').AsInteger, fQuery.FieldByName('CartaoCOD').AsInteger);
      fDadosPAG.Parcelas[wParce - 1].StatusCOD    := fQuery.FieldByName('Status').AsInteger;
      fDadosPAG.Parcelas[wParce - 1].StatusDES    := fDataM.fBuscaStatusPARCE(fQuery.FieldByName('Status').AsInteger);
      fQuery.Next;
    end;
  end;

begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM CtaPagDocto '+
                                'WHERE Codigo = :Codigo and Empre = :Empre');
    fQuery.ParamByName('Codigo').AsInteger  := Value;
    fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosPAG.id             := fQuery.FieldByName('id').AsInteger;
      fDadosPAG.Empre          := fQuery.FieldByName('Empre').AsInteger;
      fDadosPAG.Codigo         := fQuery.FieldByName('Codigo').AsInteger;
      fDadosPAG.EmitenteTIP    := fQuery.FieldByName('EmitenteTIP').AsInteger;
      fDadosPAG.EmitenteCOD    := fQuery.FieldByName('EmitenteCOD').AsInteger;
      fDadosPAG.DoctoNRO       := fQuery.FieldByName('DoctoNRO').AsString;
      fDadosPAG.DataEmissao    := fQuery.FieldByName('DataEmissao').AsDateTime;
      fDadosPAG.ParcelaQTDE    := fQuery.FieldByName('ParcelaQTDE').AsInteger;
      fDadosPAG.ParcelaTIPO    := fQuery.FieldByName('ParcelaTIPO').AsInteger;
      fDadosPAG.PrimParceData  := fQuery.FieldByName('PrimParceData').AsDateTime;
      fDadosPAG.PrimParceValor := fQuery.FieldByName('PrimParceValor').AsCurrency;
      fDadosPAG.DiaFixoVencto  := fQuery.FieldByName('DiaFixoVencto').AsInteger;
      fDadosPAG.ValorParcela   := fQuery.FieldByName('ValorParcela').AsCurrency;
      fDadosPAG.ValorPrincipal := fQuery.FieldByName('ValorPrincipal').AsCurrency;
      fDadosPAG.ValorPago      := fQuery.FieldByName('ValorPago').AsCurrency;
      fDadosPAG.HistoDES       := fQuery.FieldByName('HistoDES').AsString;
      fDadosPAG.Descricao      := fQuery.FieldByName('Descricao').AsString;
      fDadosPAG.MoedaTIP       := fQuery.FieldByName('MoedaTIP').AsInteger;
      fDadosPAG.CartaoTIP      := fQuery.FieldByName('CartaoTIP').AsInteger;
      fDadosPAG.CartaoCOD      := fQuery.FieldByName('CartaoCOD').AsInteger;
      fDadosPAG.CategoriaDes   := fQuery.FieldByName('CategoriaDes').AsInteger;
      fDadosPAG.CategoriaSai   := fQuery.FieldByName('CategoriaSai').AsInteger;
      fDadosPAG.StatusCOD      := fQuery.FieldByName('Status').AsInteger;
      fDadosPAG.StatusDES      := fDataM.fBuscaStatusFATURA(fQuery.FieldByName('Status').AsInteger);
      pBuscaParcelas;
    end;
  end;
end;

function TCtaPag.getID: Integer;
begin
  Result := fDadosPAG.id;
end;

procedure TCtaPag.setID(const Value: Integer);
begin
  Clear;
  if (Value > 0) then
  begin
    FIBQueryAtribuirSQL(fQuery, 'SELECT * FROM CtaPagDocto '+
                                'WHERE ID = :ID and Empre = :Empre');
    fQuery.ParamByName('ID').AsInteger     := Value;
    fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
      ppCodigo := fQuery.FieldByName('Codigo').AsInteger;
  end;
end;

function TCtaPag.fGravar: Integer;

  function fGeraCodigo: Integer;
  var
    wQueryLoc: TpFIBQuery;
    wTransLoc: TpFIBTransaction;
  begin
    FIBQueryCriar(wQueryLoc, wTransLoc);
    try
      FIBQueryAtribuirSQL(wQueryLoc, 'SELECT coalesce(max(Codigo),0)+1 from CtaPagDocto where '+
                                     '  Empre = :Empre');
      wQueryLoc.ParamByName('Empre').AsInteger := fDataM.Empresa;
      wQueryLoc.ExecQuery;
      Result := wQueryLoc.Fields[0].AsInteger;
    finally
      FIBQueryDestruir(wQueryLoc);
    end;
  end;

var
  wExiste: Boolean;
begin
  Result := 0;
  wExiste:= False;

  if fDataM.Empresa < 1 then
  begin
    MessageDlg('A empresa deve ser maior que zero!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosPAG.EmitenteTIP < -1) or (fDadosPAG.EmitenteTIP > 1) then
  begin
    MessageDlg('O Tipo de emitente não foi informado corretamente!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosPAG.EmitenteTIP > -1) then
  begin
    case fDadosPAG.EmitenteTIP of
      0: begin
           if (fDadosPAG.EmitenteCOD < 0) then
           begin
             MessageDlg('O Código do emitente (fornecedor) não foi informado!', mtWarning, [mbOk], 0);
             Exit;
           end;

           if (not fEstaCadastrado(fDadosPAG.EmitenteCOD, 'Fornecedor', 'Codigo', True)) then
           begin
             MessageDlg('O emitente (fornecedor) não está cadastrado!', mtWarning, [mbOk], 0);
             Exit;
           end;
         end;
      1: begin
           if (fDadosPAG.EmitenteCOD < 0) then
           begin
             MessageDlg('O Código do emitente (cliente) não foi informado!', mtWarning, [mbOk], 0);
             Exit;
           end;

           if (not fEstaCadastrado(fDadosPAG.EmitenteCOD, 'Cliente', 'Codigo', True)) then
           begin
             MessageDlg('O emitente (cliente) não está cadastrado!', mtWarning, [mbOk], 0);
             Exit;
           end;
         end;
    end;
  end;

  if Length(Trim(fDadosPAG.DoctoNRO)) = 0 then
  begin
    MessageDlg('O número do documento não foi informado!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosPAG.DataEmissao < cDataMinima) or (fDadosPAG.DataEmissao > cDataMaxima) then
  begin
    MessageDlg('A data de emissão informada está fora do período de aceitação!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (DateOf(fDadosPAG.DataEmissao) > DateOf(fDataM.fDataHoraServidor)) then
  begin
    MessageDlg('A data de emissão informada é maior que a data atual!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosPAG.ParcelaQTDE < 0) or (fDadosPAG.ParcelaQTDE > 420) then
  begin
    MessageDlg('A quantidade de parcelas deve estar entre 0 e 420', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosPAG.ParcelaTIPO < 0) or (fDadosPAG.ParcelaTIPO > 1) then
  begin
    MessageDlg('O tipo de parcelamento é inválido!', mtWarning, [mbOk], 0);
    Exit;
  end;

  if (fDadosPAG.PrimParceData > 0) then
  begin
    if (fDadosPAG.PrimParceData < fDadosPAG.DataEmissao) then
    begin
      MessageDlg('A data da primeira parcela é anterior à emissão do documento!', mtWarning, [mbOk], 0);
      Exit;
    end;

    if (fDadosPAG.PrimParceData > cDataMaxima) then
    begin
      MessageDlg('A data da primeira parcela é muito distante!', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (fDadosPAG.PrimParceValor <> 0) then
  begin
    if (fDadosPAG.PrimParceValor < 0) then
    begin
      MessageDlg('O valor da primeira parcela deve ser zero ou maior!', mtWarning, [mbOk], 0);
      Exit;
    end;

    if (fDadosPAG.PrimParceValor > fDadosPAG.ValorPrincipal) then
    begin
      MessageDlg('O valor da primeira parcela é maior que o valor principal!', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (fDadosPAG.DiaFixoVencto <> 0) then
  begin
    if (fDadosPAG.DiaFixoVencto < 0) then
    begin
      MessageDlg('O dia fixo de vencimento deve ser zero ou maior!', mtWarning, [mbOk], 0);
      Exit;
    end;

    if (fDadosPAG.DiaFixoVencto > 28) then
    begin
      MessageDlg('O dia fixo de vencimento deve ser inferior a 29!', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (fDadosPAG.ParcelaTIPO = 1) then
  begin
    if (fDadosPAG.ValorPrincipal < 0) then
    begin
      MessageDlg('O valor total a parcelar deve ser zero!', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  if (fDadosPAG.ParcelaTIPO = 0) then
  begin
    if (fDadosPAG.ValorPrincipal <= 0) then
    begin
      MessageDlg('O valor total a parcelar deve ser maior que zero!', mtWarning, [mbOk], 0);
      Exit;
    end;
  end;

  try
    try
      if (fDadosPAG.Codigo > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'SELECT id from CtaPagDocto '+
                                    'WHERE Codigo = :Codigo and Empre = :Empre');
        fQuery.ParamByName('Codigo').AsInteger  := fDadosPAG.Codigo;
        fQuery.ParamByName('Empre').AsInteger   := fDataM.Empresa;
        fQuery.ExecQuery;
        wExiste := (not fQuery.Eof);
        fDadosPAG.id := fQuery.FieldByName('id').AsInteger;
      end;

      if (fDadosPAG.Codigo > 0) and (wExiste) then
      begin
        if (fDadosPAG.StatusCOD < 2) then
        begin
          FIBQueryAtribuirSQL(fQuery, 'UPDATE CtaPagDocto '+
                                      'SET EmitenteTIP    = :EmitenteTIP, '+
                                      '    EmitenteCOD    = :EmitenteCOD, '+
                                      '    DoctoNRO       = :DoctoNRO, '+
                                      '    DataEmissao    = :DataEmissao, '+
                                      '    ParcelaQTDE    = :ParcelaQTDE, '+
                                      '    ParcelaTIPO    = :ParcelaTIPO, '+
                                      '    PrimParceData  = :PrimParceData, '+
                                      '    PrimParceValor = :PrimParceValor, '+
                                      '    DiaFixoVencto  = :DiaFixoVencto, '+
                                      '    ValorParcela   = :ValorParcela, '+
                                      '    ValorPrincipal = :ValorPrincipal, '+
                                      '    HistoDES       = :HistoDES, '+
                                      '    Descricao      = :Descricao, '+
                                      '    MoedaTIP       = :MoedaTIP, '+
                                      '    CartaoTIP      = :CartaoTIP, '+
                                      '    CartaoCOD      = :CartaoCOD, '+
                                      '    CategoriaDes   = :CategoriaDes, '+
                                      '    CategoriaSai   = :CategoriaSai '+
                                      'WHERE Codigo = :Codigo and Empre = :Empre');
          fQuery.ParamByName('Empre').AsInteger           := fDataM.Empresa;
          fQuery.ParamByName('Codigo').AsInteger          := fDadosPAG.Codigo;
          fQuery.ParamByName('EmitenteTIP').AsInteger     := fDadosPAG.EmitenteTIP;
          fQuery.ParamByName('EmitenteCOD').AsInteger     := fDadosPAG.EmitenteCOD;
          fQuery.ParamByName('DoctoNRO').AsString         := fDadosPAG.DoctoNRO;
          fQuery.ParamByName('DataEmissao').AsDate        := fDadosPAG.DataEmissao;
          fQuery.ParamByName('ParcelaQTDE').AsInteger     := fDadosPAG.ParcelaQTDE;
          fQuery.ParamByName('ParcelaTIPO').AsInteger     := fDadosPAG.ParcelaTIPO;
          fQuery.ParamByName('PrimParceData').AsDate      := fDadosPAG.PrimParceData;
          fQuery.ParamByName('PrimParceValor').AsCurrency := fDadosPAG.PrimParceValor;
          fQuery.ParamByName('DiaFixoVencto').AsInteger   := fDadosPAG.DiaFixoVencto;
          fQuery.ParamByName('ValorParcela').AsCurrency   := fDadosPAG.ValorParcela;
          fQuery.ParamByName('ValorPrincipal').AsCurrency := fDadosPAG.ValorPrincipal;
          fQuery.ParamByName('HistoDES').AsString         := fDadosPAG.HistoDES;
          fQuery.ParamByName('Descricao').AsString        := fDadosPAG.Descricao;
          fQuery.ParamByName('MoedaTIP').AsInteger        := fDadosPAG.MoedaTIP;
          fQuery.ParamByName('CartaoTIP').AsInteger       := fDadosPAG.CartaoTIP;
          fQuery.ParamByName('CartaoCOD').AsInteger       := fDadosPAG.CartaoCOD;
          fQuery.ParamByName('CategoriaDes').AsInteger    := fDadosPAG.CategoriaDes;          
          fQuery.ParamByName('CategoriaSai').AsInteger    := fDadosPAG.CategoriaSai;
          fQuery.ExecQuery;
          FIBQueryCommit(fQuery);
        end
        else
        begin
          FIBQueryAtribuirSQL(fQuery, 'UPDATE CtaPagDocto '+
                                      'SET EmitenteTIP    = :EmitenteTIP, '+
                                      '    EmitenteCOD    = :EmitenteCOD, '+
                                      '    DoctoNRO       = :DoctoNRO, '+
                                      '    DataEmissao    = :DataEmissao, '+
                                      '    HistoDES       = :HistoDES, '+
                                      '    Descricao      = :Descricao, '+
                                      '    MoedaTIP       = :MoedaTIP, '+
                                      '    CartaoTIP      = :CartaoTIP, '+
                                      '    CartaoCOD      = :CartaoCOD, '+
                                      '    CategoriaDes   = :CategoriaDes, '+
                                      '    CategoriaSai   = :CategoriaSai '+
                                      'WHERE Codigo = :Codigo and Empre = :Empre');
          fQuery.ParamByName('Empre').AsInteger           := fDataM.Empresa;
          fQuery.ParamByName('Codigo').AsInteger          := fDadosPAG.Codigo;
          fQuery.ParamByName('EmitenteTIP').AsInteger     := fDadosPAG.EmitenteTIP;
          fQuery.ParamByName('EmitenteCOD').AsInteger     := fDadosPAG.EmitenteCOD;
          fQuery.ParamByName('DoctoNRO').AsString         := fDadosPAG.DoctoNRO;
          fQuery.ParamByName('DataEmissao').AsDate        := fDadosPAG.DataEmissao;
          fQuery.ParamByName('HistoDES').AsString         := fDadosPAG.HistoDES;
          fQuery.ParamByName('Descricao').AsString        := fDadosPAG.Descricao;
          fQuery.ParamByName('MoedaTIP').AsInteger        := fDadosPAG.MoedaTIP;
          fQuery.ParamByName('CartaoTIP').AsInteger       := fDadosPAG.CartaoTIP;
          fQuery.ParamByName('CartaoCOD').AsInteger       := fDadosPAG.CartaoCOD;
          fQuery.ParamByName('CategoriaDes').AsInteger    := fDadosPAG.CategoriaDes;          
          fQuery.ParamByName('CategoriaSai').AsInteger    := fDadosPAG.CategoriaSai;
          fQuery.ExecQuery;
          FIBQueryCommit(fQuery);
        end;
      end
      else
      begin
        if (not wExiste) and ((fDadosPAG.Codigo = 0) or (fDadosPAG.Codigo > fGetMax('CtaPagDocto','Codigo',True))) then
          fDadosPAG.Codigo := fGeraCodigo;
        if (not wExiste) then
          fDadosPAG.id := fGetGenerator('GEN_CTAPAG');
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO CtaPagDocto ( id,  Empre,  Codigo,  EmitenteTIP,  EmitenteCOD,  DoctoNRO,  DataEmissao,  ParcelaQTDE,  ParcelaTIPO,  PrimParceData, '+
                                    '                          PrimParceValor,  DiaFixoVencto,  ValorParcela,  ValorPrincipal, '+
                                    '                          HistoDES,  Descricao,  MoedaTIP,  CartaoTIP,  CartaoCOD,  CategoriaDes,  CategoriaSai,  Status) '+
                                    '                 VALUES (:ID, :Empre, :Codigo, :EmitenteTIP, :EmitenteCOD, :DoctoNRO, :DataEmissao, :ParcelaQTDE, :ParcelaTIPO, :PrimParceData, '+
                                    '                         :PrimParceValor, :DiaFixoVencto, :ValorParcela, :ValorPrincipal, '+
                                    '                         :HistoDES, :Descricao, :MoedaTIP, :CartaoTIP, :CartaoCOD, :CategoriaDes, :CategoriaSai, :Status) ');
        fQuery.ParamByName('id').AsInteger              := fDadosPAG.id;
        fQuery.ParamByName('Empre').AsInteger           := fDataM.Empresa;
        fQuery.ParamByName('Codigo').AsInteger          := fDadosPAG.Codigo;
        fQuery.ParamByName('EmitenteTIP').AsInteger     := fDadosPAG.EmitenteTIP;
        fQuery.ParamByName('EmitenteCOD').AsInteger     := fDadosPAG.EmitenteCOD;
        fQuery.ParamByName('DoctoNRO').AsString         := fDadosPAG.DoctoNRO;
        fQuery.ParamByName('DataEmissao').AsDate        := fDadosPAG.DataEmissao;
        fQuery.ParamByName('ParcelaQTDE').AsInteger     := fDadosPAG.ParcelaQTDE;
        fQuery.ParamByName('ParcelaTIPO').AsInteger     := fDadosPAG.ParcelaTIPO;
        fQuery.ParamByName('PrimParceData').AsDate      := fDadosPAG.PrimParceData;
        fQuery.ParamByName('PrimParceValor').AsCurrency := fDadosPAG.PrimParceValor;
        fQuery.ParamByName('DiaFixoVencto').AsInteger   := fDadosPAG.DiaFixoVencto;
        fQuery.ParamByName('ValorParcela').AsCurrency   := fDadosPAG.ValorParcela;
        fQuery.ParamByName('ValorPrincipal').AsCurrency := fDadosPAG.ValorPrincipal;
        fQuery.ParamByName('HistoDES').AsString         := fDadosPAG.HistoDES;
        fQuery.ParamByName('Descricao').AsString        := fDadosPAG.Descricao;
        fQuery.ParamByName('MoedaTIP').AsInteger        := fDadosPAG.MoedaTIP;
        fQuery.ParamByName('CartaoTIP').AsInteger       := fDadosPAG.CartaoTIP;
        fQuery.ParamByName('CartaoCOD').AsInteger       := fDadosPAG.CartaoCOD;
        fQuery.ParamByName('CategoriaDes').AsInteger    := fDadosPAG.CategoriaDes;        
        fQuery.ParamByName('CategoriaSai').AsInteger    := fDadosPAG.CategoriaSai;
        fQuery.ParamByName('Status').AsInteger          := fDadosPAG.StatusCOD;
        fQuery.ExecQuery;
        FIBQueryCommit(fQuery);
      end;
    except
      on e: exception do
      begin
        FIBQueryRollback(fQuery);
        fDadosPAG.id := 0;
        MessageDlg('Erro ao gravar a fatura do Contas A PAGAR!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    Result := fDadosPAG.id;
  end;
end;

function TCtaPag.fFaturaTemBaixas(prDoctoID: Integer): Boolean;
begin
  FIBQueryAtribuirSQL(fQuery, 'SELECT count(*) from CtaPagParceBaixa '+
                              'WHERE DoctoID = :DoctoID');
  fQuery.ParamByName('DoctoID').AsInteger   := prDoctoID;
  fQuery.ExecQuery;
  Result := fQuery.Fields[0].AsInteger > 0;
end;

function TCtaPag.fGravarParcelas(prDoctoID: Integer; prParcelas: TParcelas; prStaFat, prParcelamento: Integer): Boolean;
var
  wInd: Integer;
  wTemBaixas: Boolean;
begin
  Result := False;
  try
    try
      if (prParcelamento = 0) then
      begin





      end
      else
      begin
        wTemBaixas := fFaturaTemBaixas(prDoctoID);
        if (prStaFat < 2) and (not wTemBaixas) then
        begin
          FIBQueryAtribuirSQL(fQuery, 'DELETE from CtaPagParce '+
                                      'WHERE DoctoID = :DoctoID');
          fQuery.ParamByName('DoctoID').AsInteger   := prDoctoID;
          fQuery.ExecQuery;
          FIBQueryCommit(fQuery);

          // Insere as parcelas
          for wInd := Low(prParcelas) to High(prParcelas) do
          begin
            FIBQueryAtribuirSQL(fQuery, 'INSERT INTO CtaPagParce ( DOCTOID,  PARCELA, '+
                                        '                          DATAVENCTO,  VALORPARCELA,  MOEDATIP,  CARTAOTIP,  CARTAOCOD,  STATUS) '+
                                        '                 VALUES (:DOCTOID, :PARCELA, '+
                                        '                         :DATAVENCTO, :VALORPARCELA, :MOEDATIP, :CARTAOTIP, :CARTAOCOD, :STATUS) ');
            fQuery.ParamByName('DoctoID').AsInteger        := prParcelas[wInd].DoctoID;
            fQuery.ParamByName('Parcela').AsInteger        := prParcelas[wInd].Parcela;
            fQuery.ParamByName('DATAVENCTO').AsDateTime    := prParcelas[wInd].DataVencto;
            fQuery.ParamByName('VALORPARCELA').AsCurrency  := prParcelas[wInd].ValorParcela;
            fQuery.ParamByName('MOEDATIP').AsInteger       := prParcelas[wInd].MoedaTIP;
            fQuery.ParamByName('CARTAOTIP').AsInteger      := prParcelas[wInd].CartaoTIP;
            fQuery.ParamByName('CARTAOCOD').AsInteger      := prParcelas[wInd].CartaoCOD;
            fQuery.ParamByName('STATUS').AsInteger         := prParcelas[wInd].StatusCOD;
            fQuery.ExecQuery;
          end;
          FIBQueryCommit(fQuery);
          Result := True;
        end
        else
        begin
          for wInd := Low(prParcelas) to High(prParcelas) do
          begin
            FIBQueryAtribuirSQL(fQuery, 'UPDATE CtaPagParce SET '+
                                        ' DATAVENCTO = :DATAVENCTO, '+
                                        ' MOEDATIP   = :MOEDATIP, '+
                                        ' CARTAOTIP  = :CARTAOTIP, '+
                                        ' CARTAOCOD  = :CARTAOCOD '+
                                        ' WHERE DOCTOID = :DOCTOID AND PARCELA = :PARCELA ');
            fQuery.ParamByName('DoctoID').AsInteger        := prParcelas[wInd].DoctoID;
            fQuery.ParamByName('Parcela').AsInteger        := prParcelas[wInd].Parcela;
            fQuery.ParamByName('DATAVENCTO').AsDateTime    := prParcelas[wInd].DataVencto;
            fQuery.ParamByName('MOEDATIP').AsInteger       := prParcelas[wInd].MoedaTIP;
            fQuery.ParamByName('CARTAOTIP').AsInteger      := prParcelas[wInd].CartaoTIP;
            fQuery.ParamByName('CARTAOCOD').AsInteger      := prParcelas[wInd].CartaoCOD;
            fQuery.ExecQuery;
          end;
          FIBQueryCommit(fQuery);
          Result := True;
        end;
      end;
    except
      on e: exception do
      begin
        MessageDlg('Erro ao gravar as parcelas da fatura do Contas A PAGAR!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCtaPag.fAlterarParcela(prParcela: TParcela): Boolean;
begin
  try
    try
      if (prParcela.DoctoID > 0) and (prParcela.Parcela > 0) then
      begin
        FIBQueryAtribuirSQL(fQuery, 'UPDATE CtaPagParce SET '+
                                    ' DATAVENCTO = :DATAVENCTO, '+
                                    ' MOEDATIP   = :MOEDATIP, '+
                                    ' CARTAOTIP  = :CARTAOTIP, '+
                                    ' CARTAOCOD  = :CARTAOCOD '+
                                    ' WHERE DOCTOID = :DOCTOID AND PARCELA = :PARCELA ');
        fQuery.ParamByName('DoctoID').AsInteger        := prParcela.DoctoID;
        fQuery.ParamByName('Parcela').AsInteger        := prParcela.Parcela;
        fQuery.ParamByName('DATAVENCTO').AsDateTime    := prParcela.DataVencto;
        fQuery.ParamByName('MOEDATIP').AsInteger       := prParcela.MoedaTIP;
        fQuery.ParamByName('CARTAOTIP').AsInteger      := prParcela.CartaoTIP;
        fQuery.ParamByName('CARTAOCOD').AsInteger      := prParcela.CartaoCOD;
        fQuery.ExecQuery;
        FIBQueryCommit(fQuery);
        Result := True;
      end;
    except
      on e: exception do
      begin
        MessageDlg('Erro ao alterar a parcela da fatura do Contas A PAGAR!' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCtaPag.fSetStatus(const prStatus: Integer; var prErro: String): Boolean;
var
  wRotina: Integer;
begin
  Result  := False;
  prErro  := '';
  wRotina := 0;

  if (prStatus <> 0) and (prStatus <> 1) then
  begin
    prErro := 'Status inválido para o Contas A PAGAR!';
    Exit;
  end;

  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CtaPagDocto WHERE Codigo = :Codigo and Empre = :Empre ');
      fQuery.ParamByName('Codigo').AsInteger   := ppCodigo;
      fQuery.ParamByName('Empre').AsInteger    := fDataM.Empresa;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'A fatura do Contas a PAGAR '+IntToStr(ppCodigo)+' não foi encontrado.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE CtaPagDocto SET Status = :Status Codigo = :Codigo and Empre = :Empre ');
      fQuery.ParamByName('Codigo').AsInteger := ppCodigo;
      fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
      fQuery.ParamByName('Status').AsInteger := prStatus;
      fQuery.ExecQuery;

      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao alterar o status da fatura do Contas A PAGAR '+IntToStr(ppCodigo)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCtaPag.fCancelarFatura(var prErro: String): Boolean;
var
  wRotina: Integer;
  wEstornar: Boolean;

  function fEstornarPagtos: Boolean;
  var
    fQueryLoc: TpFIBQuery;
    fTransLoc: TpFIBTransaction;
  begin
    FIBQueryCriar(fQueryLoc, fTransLoc);
    try
      try
        FIBQueryAtribuirSQL(fQueryLoc, 'SELECT * FROM Lancamento '+
                                       'WHERE (EMPRE = :EMPRE) AND (FATURAID = :FATURAID) AND (FATURACOD = :FATURACOD) AND (STATUS = 0) AND (CATEGORIASAI > 0) AND (CATEGORIAENT = 0) '+
                                       'ORDER BY FATURAID, FATURACOD, FATURAPAR ');
        fQueryLoc.ParamByName('EMPRE').AsInteger     := fDataM.Empresa;
        fQueryLoc.ParamByName('FATURAID').AsInteger  := ppDados.id;
        fQueryLoc.ParamByName('FATURACOD').AsInteger := ppDados.Codigo;
        fQueryLoc.ExecQuery;
        while (not fQueryLoc.Eof) do
        begin
          FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Lancamento ( ID,  Empre,  DataLancto,  DtHrLancto,  CategoriaEnt,  CategoriaSai,  ValorLancto,  CliForTIP,  CliForCOD,  DoctoNRO,  FaturaID,  FaturaCOD,  FaturaPAR,  HistoCOD,  HistoDES,  Status) '+
                                      '                VALUES (:ID, :Empre, :DataLancto, :DtHrLancto, :CategoriaEnt, :CategoriaSai, :ValorLancto, :CliForTIP, :CliForCOD, :DoctoNRO, :FaturaID, :FaturaCOD, :FaturaPAR, :HistoCOD, :HistoDES, :Status) ');
          fQuery.ParamByName('ID').AsInteger                := fGetGenerator('GEN_LANCAMENTO');
          fQuery.ParamByName('Empre').AsInteger             := fDataM.Empresa;
          fQuery.ParamByName('DataLancto').AsDateTime       := fDataM.fDataHoraServidor;
          fQuery.ParamByName('DtHrLancto').AsDateTime       := fDataM.fDataHoraServidor;
          fQuery.ParamByName('CategoriaEnt').AsInteger      := fQueryLoc.FieldByName('CategoriaSAI').AsInteger;
          fQuery.ParamByName('CategoriaSai').AsInteger      := 0;
          fQuery.ParamByName('ValorLancto').AsCurrency      := fQueryLoc.FieldByName('ValorLancto').AsCurrency;
          fQuery.ParamByName('CliForTIP').AsInteger         := fQueryLoc.FieldByName('CliForTIP').AsInteger;
          fQuery.ParamByName('CliForCOD').AsInteger         := fQueryLoc.FieldByName('CliForCOD').AsInteger;
          fQuery.ParamByName('DoctoNRO').AsString           := fQueryLoc.FieldByName('DoctoNRO').AsString;
          fQuery.ParamByName('FaturaID').AsInteger          := fQueryLoc.FieldByName('FaturaID').AsInteger;
          fQuery.ParamByName('FaturaCOD').AsInteger         := fQueryLoc.FieldByName('FaturaCOD').AsInteger;
          fQuery.ParamByName('FaturaPAR').AsInteger         := fQueryLoc.FieldByName('FaturaPAR').AsInteger;
          fQuery.ParamByName('HistoCOD').AsInteger          := fQueryLoc.FieldByName('HistoCOD').AsInteger;
          fQuery.ParamByName('HISTODES').AsString           := 'CANCELAMENTO DA FATURA';
          fQuery.ParamByName('STATUS').AsInteger            := 0;
          fQuery.ExecQuery;
          fQueryLoc.Next;
        end;
        FIBQueryCommit(fQuery);
        FIBQueryCommit(fQueryLoc);
        Result := True;
      except
        on e: Exception do
        begin
          Result := False;
          FIBQueryRollback(fQuery);
          FIBQueryRollback(fQueryLoc);
          MessageDlg('Erro ao estornar as baixas de pagamentos da Fatura A PAGAR '+IntToStr(ppDados.id)+eol+e.Message,mtWarning,[mbOk], 0);
        end;
      end;
    finally
      FIBQueryRollback(fQuery);
      FIBQueryRollback(fQueryLoc);
      FIBQueryDestruir(fQueryLoc);
    end;
  end;

begin
  Result    := False;
  wEstornar := False;
  prErro    := '';
  wRotina   := 0;
  try
    try
      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CtaPagDocto WHERE ID = :ID ');
      fQuery.ParamByName('ID').AsInteger  := ppDados.id;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger < 1) then
      begin
        prErro := 'O documento do Contas A PAGAR não foi encontrado para exclusão.';
        Exit
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'SELECT COUNT(*) AS QTDE FROM CtaPagParceBaixa WHERE DoctoID = :ID');
      fQuery.ParamByName('ID').AsInteger := ppDados.id;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('QTDE').AsInteger > 0) then
      begin
        wEstornar := True;
        if (not Confirmar('Atenção: A fatura já possui baixas.'+eol+
                          'Todos os lançamentos dos pagamentos serão estornados.'+eol+
                          'Confirma o cancelamento da Fatura?', clRed, 'Confirme')) then
        begin
          prErro := 'A fatura já possui baixas e não foi confirmado o cancelamento!';
          Exit
        end;
      end
      else
      begin
        if (not Confirmar('Atenção: Cancelamento da fatura.'+eol+
                          'Confirma o cancelamento da Fatura?', clRed, 'Confirme')) then
        begin
          prErro := 'Não foi confirmado o cancelamento!';
          Exit
        end;
      end;

      if (wEstornar) then
      begin
        if (not fEstornarPagtos) then
          Exit;
      end;

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE CtaPagParceBaixa SET STATUS = 7 WHERE DoctoID = :ID ');
      fQuery.ParamByName('ID').AsInteger  := ppDados.id;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE CtaPagParce SET STATUS = 7 WHERE DoctoID = :ID ');
      fQuery.ParamByName('ID').AsInteger  := ppDados.id;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Inc(wRotina);
      FIBQueryAtribuirSQL(fQuery, 'UPDATE CtaPagDocto SET STATUS = 7 WHERE ID = :ID');
      fQuery.ParamByName('ID').AsInteger  := ppDados.id;
      fQuery.ExecQuery;
      FIBQueryCommit(fQuery);

      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao cancelar a fatura do Contas A PAGAR '+IntToStr(ppDados.id)+eol+
                   'Rotina: '+IntToStr(wRotina)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

function TCtaPag.fEstornarPagto(prParcela, Sequencia: Integer): Boolean;
var
  fQueryLoc: TpFIBQuery;
  fTransLoc: TpFIBTransaction;
begin
  FIBQueryCriar(fQueryLoc, fTransLoc);
  try
    try
      FIBQueryAtribuirSQL(fQueryLoc, 'SELECT * FROM Lancamento '+
                                     'WHERE (EMPRE = :EMPRE) AND (FATURAID = :FATURAID) AND (FATURACOD = :FATURACOD) AND (STATUS = 0) AND (CATEGORIASAI > 0) AND (CATEGORIAENT = 0) '+
                                     'ORDER BY FATURAID, FATURACOD, FATURAPAR ');
      fQueryLoc.ParamByName('EMPRE').AsInteger     := fDataM.Empresa;
      fQueryLoc.ParamByName('FATURAID').AsInteger  := ppDados.id;
      fQueryLoc.ParamByName('FATURACOD').AsInteger := ppDados.Codigo;
      fQueryLoc.ExecQuery;
      while (not fQueryLoc.Eof) do
      begin
        FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Lancamento ( ID,  Empre,  DataLancto,  DtHrLancto,  CategoriaEnt,  CategoriaSai,  ValorLancto,  CliForTIP,  CliForCOD,  DoctoNRO,  FaturaID,  FaturaCOD,  FaturaPAR,  HistoCOD,  HistoDES,  Status) '+
                                    '                VALUES (:ID, :Empre, :DataLancto, :DtHrLancto, :CategoriaEnt, :CategoriaSai, :ValorLancto, :CliForTIP, :CliForCOD, :DoctoNRO, :FaturaID, :FaturaCOD, :FaturaPAR, :HistoCOD, :HistoDES, :Status) ');
        fQuery.ParamByName('ID').AsInteger                := fGetGenerator('GEN_LANCAMENTO');
        fQuery.ParamByName('Empre').AsInteger             := fDataM.Empresa;
        fQuery.ParamByName('DataLancto').AsDateTime       := fDataM.fDataHoraServidor;
        fQuery.ParamByName('DtHrLancto').AsDateTime       := fDataM.fDataHoraServidor;
        fQuery.ParamByName('CategoriaEnt').AsInteger      := fQueryLoc.FieldByName('CategoriaSAI').AsInteger;
        fQuery.ParamByName('CategoriaSai').AsInteger      := 0;
        fQuery.ParamByName('ValorLancto').AsCurrency      := fQueryLoc.FieldByName('ValorLancto').AsCurrency;
        fQuery.ParamByName('CliForTIP').AsInteger         := fQueryLoc.FieldByName('CliForTIP').AsInteger;
        fQuery.ParamByName('CliForCOD').AsInteger         := fQueryLoc.FieldByName('CliForCOD').AsInteger;
        fQuery.ParamByName('DoctoNRO').AsString           := fQueryLoc.FieldByName('DoctoNRO').AsString;
        fQuery.ParamByName('FaturaID').AsInteger          := fQueryLoc.FieldByName('FaturaID').AsInteger;
        fQuery.ParamByName('FaturaCOD').AsInteger         := fQueryLoc.FieldByName('FaturaCOD').AsInteger;
        fQuery.ParamByName('FaturaPAR').AsInteger         := fQueryLoc.FieldByName('FaturaPAR').AsInteger;
        fQuery.ParamByName('HistoCOD').AsInteger          := fQueryLoc.FieldByName('HistoCOD').AsInteger;
        fQuery.ParamByName('HISTODES').AsString           := 'CANCELAMENTO DA FATURA';
        fQuery.ParamByName('STATUS').AsInteger            := 0;
        fQuery.ExecQuery;
        fQueryLoc.Next;
      end;
      FIBQueryCommit(fQuery);
      FIBQueryCommit(fQueryLoc);
      Result := True;
    except
      on e: Exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        FIBQueryRollback(fQueryLoc);
        MessageDlg('Erro ao estornar as baixas de pagamentos da Fatura A PAGAR '+IntToStr(ppDados.id)+eol+e.Message,mtWarning,[mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
    FIBQueryRollback(fQueryLoc);
    FIBQueryDestruir(fQueryLoc);
  end;
end;

function TCtaPag.fGetPagoParcela(prParcela: Integer): Currency;
var
  wVlrBaixa, wVlrEstor: Currency;
begin
  Result := 0;
  try
    FIBQueryAtribuirSQL(fQuery, 'select coalesce(sum(VALORPRINCIPAL),0) as VLR from ctapagparcebaixa where (doctoid = :doctoid) and (Parcela = :parcela) and (Status = 0)');
    fQuery.ParamByName('doctoid').AsInteger := ppDados.id;
    fQuery.ParamByName('parcela').AsInteger := prParcela;
    fQuery.ExecQuery;
    wVlrBaixa := fQuery.FieldByName('VLR').AsCurrency;
    //
    FIBQueryAtribuirSQL(fQuery, 'select coalesce(sum(VALORPRINCIPAL),0) as VLR from ctapagparcebaixa where (doctoid = :doctoid) and (Parcela = :parcela) and (Status = 1)');
    fQuery.ParamByName('doctoid').AsInteger := ppDados.id;
    fQuery.ParamByName('parcela').AsInteger := prParcela;
    fQuery.ExecQuery;
    wVlrEstor := fQuery.FieldByName('VLR').AsCurrency;
    //
    Result := wVlrBaixa - wVlrEstor;
  except
    on e: exception do
    begin
      FIBQueryRollback(fQuery);
      MessageDlg('Erro ao buscar o valor pago da parcela '+IntToStr(prParcela)+' e ID='+IntToStr(ppDados.id)+eol+
                 e.Message, mtWarning, [mbOk], 0);
    end;
  end;
end;

function TCtaPag.fGetMaxParcela(prDoctoID: Integer): TParcelas;
var
  wParce: TParcelas;
begin
  SetLength(wParce, 1);
  FillChar(wParce, SizeOf(wParce), #0);
  //
  try
    FIBQueryAtribuirSQL(fQuery, 'select * from ctapagparce where (doctoid = :doctoID) and (parcela = (select coalesce(max(parcela),0) from ctapagparce where doctoid = :doctoID))');
    fQuery.ParamByName('doctoID').AsInteger := prDoctoID;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      wParce[0].DoctoID      := fQuery.FieldByName('doctoID').AsInteger;
      wParce[0].Parcela      := fQuery.FieldByName('parcela').AsInteger;
      wParce[0].DataVencto   := fQuery.FieldByName('datavencto').AsDateTime;
      wParce[0].ValorParcela := fQuery.FieldByName('valorparcela').AsCurrency;
      wParce[0].MoedaTIP     := fQuery.FieldByName('moedaTip').AsInteger;
      wParce[0].CartaoTIP    := fQuery.FieldByName('cartaoTip').AsInteger;
      wParce[0].CartaoCOD    := fQuery.FieldByName('cartaoCod').AsInteger;
      wParce[0].StatusCOD    := fQuery.FieldByName('status').AsInteger;
    end;
    FIBQueryCommit(fQuery);
    Result := wParce;
  except
    on e: exception do
    begin
      FIBQueryRollback(fQuery);
      MessageDlg('fGetMaxParcela: Erro ao buscar a última parcela do ID='+IntToStr(prDoctoID)+eol+
                 e.Message, mtWarning, [mbOk], 0);
    end;
  end;
end;

function TCtaPag.fGetSaldoParcela(prParcela: Integer): Currency;
var
  wVlrParce, wVlrBaixa, wVlrEstor: Currency;
begin
  Result := 0;
  try
    FIBQueryAtribuirSQL(fQuery, 'select coalesce(sum(VALORPARCELA),0) as VLR from ctapagparce where (doctoid = :Doctoid) and (Parcela = :Parcela)');
    fQuery.ParamByName('doctoid').AsInteger := ppDados.id;
    fQuery.ParamByName('parcela').AsInteger := prParcela;
    fQuery.ExecQuery;
    wVlrParce := fQuery.FieldByName('VLR').AsCurrency;
    //
    FIBQueryAtribuirSQL(fQuery, 'select coalesce(sum(VALORPRINCIPAL),0) as VLR from ctapagparcebaixa where (doctoid = :doctoid) and (Parcela = :parcela) and (Status = 0)');
    fQuery.ParamByName('doctoid').AsInteger := ppDados.id;
    fQuery.ParamByName('parcela').AsInteger := prParcela;
    fQuery.ExecQuery;
    wVlrBaixa := fQuery.FieldByName('VLR').AsCurrency;
    //
    FIBQueryAtribuirSQL(fQuery, 'select coalesce(sum(VALORPRINCIPAL),0) as VLR from ctapagparcebaixa where (doctoid = :doctoid) and (Parcela = :parcela) and (Status = 1)');
    fQuery.ParamByName('doctoid').AsInteger := ppDados.id;
    fQuery.ParamByName('parcela').AsInteger := prParcela;
    fQuery.ExecQuery;
    wVlrEstor := fQuery.FieldByName('VLR').AsCurrency;
    //
    Result := wVlrParce - wVlrBaixa + wVlrEstor;
  except
    on e: exception do
    begin
      FIBQueryRollback(fQuery);
      MessageDlg('Erro ao buscar o saldo da parcela '+IntToStr(prParcela)+' e ID='+IntToStr(ppDados.id)+eol+
                 e.Message, mtWarning, [mbOk], 0);
    end;
  end;
end;

function TCtaPag.fBaixarParcela(prParcela, prMoedaTIP, prHistoCOD: Integer; prDataBaixa: TDateTime; prVlrPri, prVlrJur, prVlrMul, prVlrDes: Currency; prHistoDES: String): Boolean;

  function fGeraSeq: Integer;
  begin
    Result := 0;
    FIBQueryAtribuirSQL(fQuery, 'select max(SEQUENCIA) AS SEQ from CTAPAGPARCEBAIXA '+
                                'where DOCTOID = :DOCTOID and PARCELA = :PARCELA ');
    fQuery.ParamByName('doctoid').AsInteger  := ppDados.id;
    fQuery.ParamByName('parcela').AsInteger  := prParcela;
    fQuery.ExecQuery;
    if (not fQuery.FieldByName('SEQ').IsNull) then
      Result := fQuery.FieldByName('SEQ').AsInteger + 1;
  end;

var
  wSeque: Integer;
  wVlrTot: Currency;
begin
  Result  := False;

  if (ppDados.id < 1) then
  begin
    MessageDlg('O ID da fatura deve ser informado.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prParcela < 1) then
  begin
    MessageDlg('A parcela deve ser informada.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prDataBaixa < cDataMinima) or (prDataBaixa > cDataMaxima) then
  begin
    MessageDlg('A data da baixa está fora do período de aceitação.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prDataBaixa < ppDados.DataEmissao) then
  begin
    MessageDlg('A data da baixa é anterior a emissão da fatura.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prMoedaTIP < 1) then
  begin
    MessageDlg('O tipo de moeda deve ser informado.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prVlrPri < 0) then
  begin
    MessageDlg('O valor principal deve ser zero ou maior.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prVlrJur < 0) then
  begin
    MessageDlg('O valor do juro deve ser zero ou maior.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prVlrMul < 0) then
  begin
    MessageDlg('O valor da multa deve ser zero ou maior.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prVlrDes < 0) then
  begin
    MessageDlg('O valor do desconto deve ser zero ou maior.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (prVlrPri = 0) and (prVlrJur = 0) and (prVlrMul = 0) and (prVlrDes = 0) then
  begin
    MessageDlg('Nenhum valor informado.', mtWarning, [mbOk], 0);
    Exit
  end;

  wVlrTot := prVlrPri + prVlrJur + prVlrMul - prVlrDes;
  if (wVlrTot < 0) then
  begin
    MessageDlg('O valor total deve ser zero ou maior.', mtWarning, [mbOk], 0);
    Exit
  end;

  if (Length(Trim(prHistoDES)) = 0) then
  begin
    MessageDlg('O histórico da baixa deve ser informado.', mtWarning, [mbOk], 0);
    Exit
  end;

  try
    try
      FIBQueryAtribuirSQL(fQuery, 'SELECT coalesce(VALORPARCELA,0) - '+
                                  '(SELECT coalesce(SUM(valorprincipal),0) FROM ctapagparcebaixa WHERE (doctoid = :doctoid) AND (parcela = :parcela) AND STATUS = 0) AS SALDO '+
                                  'FROM CTAPAGPARCE '+
                                  'WHERE (doctoid = :doctoid) AND (parcela = :parcela) ');
      fQuery.ParamByName('doctoid').AsInteger  := ppDados.id;
      fQuery.ParamByName('parcela').AsInteger  := prParcela;
      fQuery.ExecQuery;
      if (fQuery.FieldByName('SALDO').AsCurrency < prVlrPri) then
      begin
        MessageDlg('O saldo A PAGAR da parcela '+IntToStr(prParcela)+' é menor que o valor principal informado.', mtWarning, [mbOk], 0);
        Exit
      end;

      wSeque := fGeraSeq;
      FIBQueryAtribuirSQL(fQuery, 'INSERT INTO CTAPAGPARCEBAIXA ( DOCTOID,  PARCELA,  SEQUENCIA,  MOEDATIP,  DATABAIXA,  DataLancto,  VALORPRINCIPAL,  VALORJUROS,  VALORMULTA,  VALORDESCONTO,  VALORTOTAL,  HISTODES,  STATUS) '+
                                  '                      VALUES (:DOCTOID, :PARCELA, :SEQUENCIA, :MOEDATIP, :DATABAIXA, :DataLancto, :VALORPRINCIPAL, :VALORJUROS, :VALORMULTA, :VALORDESCONTO, :VALORTOTAL, :HISTODES, :STATUS) ');
      fQuery.ParamByName('doctoid').AsInteger           := ppDados.id;
      fQuery.ParamByName('parcela').AsInteger           := prParcela;
      fQuery.ParamByName('sequencia').AsInteger         := wSeque;
      fQuery.ParamByName('moedaTIP').AsInteger          := prMoedaTIP;
      fQuery.ParamByName('databaixa').AsDateTime        := prDataBaixa;
      fQuery.ParamByName('DataLancto').AsDateTime       := fDataM.fDataHoraServidor;
      fQuery.ParamByName('VALORPRINCIPAL').AsCurrency   := prVlrPri;
      fQuery.ParamByName('VALORJUROS').AsCurrency       := prVlrJur;
      fQuery.ParamByName('VALORMULTA').AsCurrency       := prVlrMul;
      fQuery.ParamByName('VALORDESCONTO').AsCurrency    := prVlrDes;
      fQuery.ParamByName('VALORTOTAL').AsCurrency       := wVlrTot;
      fQuery.ParamByName('HISTODES').AsString           := prHistoDES;
      fQuery.ParamByName('STATUS').AsInteger            := 0;
      fQuery.ExecQuery;
      //
      FIBQueryAtribuirSQL(fQuery, 'INSERT INTO Lancamento ( ID,  Empre,  DataLancto,  DtHrLancto,  CategoriaEnt,  CategoriaSai,  ValorLancto,  CliForTIP,  CliForCOD,  DoctoNRO,  FaturaID,  FaturaCOD,  FaturaPAR,  HistoCOD,  HistoDES,  Status) '+
                                  '                VALUES (:ID, :Empre, :DataLancto, :DtHrLancto, :CategoriaEnt, :CategoriaSai, :ValorLancto, :CliForTIP, :CliForCOD, :DoctoNRO, :FaturaID, :FaturaCOD, :FaturaPAR, :HistoCOD, :HistoDES, :Status) ');
      fQuery.ParamByName('ID').AsInteger                := fGetGenerator('GEN_LANCAMENTO');
      fQuery.ParamByName('Empre').AsInteger             := fDataM.Empresa;
      fQuery.ParamByName('DataLancto').AsDateTime       := prDataBaixa;
      fQuery.ParamByName('DtHrLancto').AsDateTime       := fDataM.fDataHoraServidor;
      fQuery.ParamByName('CategoriaEnt').AsInteger      := 0;
      fQuery.ParamByName('CategoriaSai').AsInteger      := ppDados.CategoriaSai;
      fQuery.ParamByName('ValorLancto').AsCurrency      := wVlrTot;
      fQuery.ParamByName('CliForTIP').AsInteger         := ppDados.EmitenteTIP;
      fQuery.ParamByName('CliForCOD').AsInteger         := ppDados.EmitenteCOD;
      fQuery.ParamByName('DoctoNRO').AsString           := ppDados.DoctoNRO;
      fQuery.ParamByName('FaturaID').AsInteger          := ppDados.id;
      fQuery.ParamByName('FaturaCOD').AsInteger         := ppDados.Codigo;
      fQuery.ParamByName('FaturaPAR').AsInteger         := prParcela;
      fQuery.ParamByName('HistoCOD').AsInteger          := prHistoCOD;
      fQuery.ParamByName('HISTODES').AsString           := prHistoDES;
      fQuery.ParamByName('STATUS').AsInteger            := 0;
      fQuery.ExecQuery;
      //
      FIBQueryCommit(fQuery);
      Result := True;
    except
      on e: exception do
      begin
        Result := False;
        FIBQueryRollback(fQuery);
        MessageDlg('Erro ao baixar o valor A PAGAR da fatura '+IntToStr(ppDados.Codigo) +' e parcela '+IntToStr(prParcela)+' e ID='+IntToStr(ppDados.id)+eol+
                   e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryRollback(fQuery);
  end;
end;

end.
