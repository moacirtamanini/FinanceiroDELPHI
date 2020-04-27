unit uFrame_Historico;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, rtTypes,
  pFIBDatabase, pFIBQuery, ExtCtrls, Mask, 
  rtHistorico, rxToolEdit, rxCurrEdit;

type
  TFrame_Historico = class(TFrame)
    lbCodigo: TLabel;
    edHisto: TCurrencyEdit;
    spBusca: TPanel;
    procedure edHistoExit(Sender: TObject);
    procedure spBuscaClick(Sender: TObject);
  private
    fQuery: TpFIBQuery;
    fTrans: TpFIBTransaction;
    fDadosHis: TDadosHis;
    fDepoisBuscaEvent: TDepoisBuscaEvent;
    function  fGetHisto: Integer;
    procedure pSetHisto(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    OnDepoisBusca: TDepoisBuscaEvent read fDepoisBuscaEvent write fDepoisBuscaEvent;
    property    Histo: Integer read fGetHisto write pSetHisto;
    property    ppDadosHis: TDadosHis read fDadosHis;
  end;

implementation

uses uDataM, FIBQuery, ucBrwHistorico, uUtils;

{$R *.dfm}

constructor TFrame_Historico.Create(AOwner: TComponent);
begin
  inherited;
  FIBQueryCriar(fQuery, fTrans);
end;

destructor TFrame_Historico.Destroy;
begin
  FIBQueryCriar(fQuery, fTrans);
  inherited;
end;

function TFrame_Historico.fGetHisto: Integer;
begin
  Result := fDadosHis.Codigo;
end;

procedure TFrame_Historico.pSetHisto(const Value: Integer);
var
  wEncontrou: Boolean;
begin
  wEncontrou := False;
  FillChar(fDadosHis, SizeOf(fDadosHis), #0);
  edHisto.Clear;
  try
    FIBQueryAtribuirSQL(fQuery, 'SELECT * from Historico '+
                                ' where Empre = :Empre and Codigo = :Codigo ');
    fQuery.ParamByName('Empre').AsInteger  := fDataM.Empresa;
    fQuery.ParamByName('Codigo').AsInteger := Value;
    fQuery.ExecQuery;
    if (not fQuery.Eof) then
    begin
      fDadosHis.id        := fQuery.FieldByName('id').AsInteger;
      fDadosHis.Empre     := fQuery.FieldByName('Empre').AsInteger;
      fDadosHis.Codigo    := fQuery.FieldByName('Codigo').AsInteger;
      fDadosHis.Descricao := fQuery.FieldByName('Descricao').AsString;
      fDadosHis.Status    := fQuery.FieldByName('Status').AsInteger;
      edHisto.Text        := IntToStr(fDadosHis.Codigo);
      wEncontrou          := True;
    end;
  except
    on E: Exception do
    begin
      MessageDlg('Erro ao buscar o Histórico pelo código: '+IntToStr(Value)+eol+e.Message, mtWarning, [mbOk], 0);
    end;
  end;
  if Assigned(OnDepoisBusca) then
    OnDepoisBusca(Self, wEncontrou);
end;

procedure TFrame_Historico.edHistoExit(Sender: TObject);
begin
  Histo := StrToIntDef(Trim(edHisto.Text),0);
end;

procedure TFrame_Historico.spBuscaClick(Sender: TObject);
begin
  fcBrwHistorico := TfcBrwHistorico.Create(Self);
  try
    fcBrwHistorico.ShowModal;
    if fcBrwHistorico.ModalResult = mrOk then
    begin
      Histo := fcBrwHistorico.Codigo;
    end;
  finally
    FreeAndNil(fcBrwHistorico);
  end;
end;

end.
