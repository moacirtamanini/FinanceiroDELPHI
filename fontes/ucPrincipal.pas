unit ucPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, rtTypes, ComCtrls, ExtCtrls, OleCtrls, SHDocVw;

type
  TfrPrincipal = class(TForm)
    MenuPri: TMainMenu;
    mmLancamento: TMenuItem;
    mmCadastros: TMenuItem;
    miCadEmpresaAlterar: TMenuItem;
    miCadCategoria: TMenuItem;
    miCadHistorico: TMenuItem;
    miCadCartao: TMenuItem;
    N1: TMenuItem;
    miCadUsuario: TMenuItem;
    mmCtaRec: TMenuItem;
    mmCtaPag: TMenuItem;
    miCadCartoes: TMenuItem;
    miCadBandeira: TMenuItem;
    miCatPagLancar: TMenuItem;
    miCatPagBaixar: TMenuItem;
    miCtaRecLancar: TMenuItem;
    miCtaRecReceber: TMenuItem;
    mmConsultas: TMenuItem;
    miLancamentosLancar: TMenuItem;
    miConBalancete: TMenuItem;
    N2: TMenuItem;
    miCadClientes: TMenuItem;
    miCadFornecedores: TMenuItem;
    pnBottom: TPanel;
    staEmpresa: TStatusBar;
    mmConFluxoCaixa: TMenuItem;
    wbFundo: TWebBrowser;
    procedure miCadEmpresaAlterarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miCadHistoricoClick(Sender: TObject);
    procedure miCadCategoriaClick(Sender: TObject);
    procedure miCadBandeiraClick(Sender: TObject);
    procedure miCatPagLancarClick(Sender: TObject);
    procedure miCadClientesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure miCadFornecedoresClick(Sender: TObject);
    procedure miCatPagBaixarClick(Sender: TObject);
    procedure mmConFluxoCaixaClick(Sender: TObject);
    procedure miCtaRecLancarClick(Sender: TObject);
    procedure miCtaRecReceberClick(Sender: TObject);
    procedure miCadCartoesClick(Sender: TObject);
  private
  public
  end;

var
  frPrincipal: TfrPrincipal;

implementation

uses rtEndereco, rtFone, rtEmpresa, ucEmpresa, uUtils, uDataM,
  ucCadHistorico, ucCadCategoria, ucCadBandeira, ucCadCartaoDebCre,
  ucCtaPagLan, ucCadCliente, ucCadFornecedor,
  ucConFluxoDeCaixa, ucCtaRecLan;

{$R *.dfm}

procedure TfrPrincipal.OnKeyPress(Sender: TObject; var Key: Char);
begin
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

procedure TfrPrincipal.FormShow(Sender: TObject);
begin
  Self.Caption := 'Financeiro';
  wbFundo.Navigate('file:///'+ExtractFilePath(ParamStr(0))+'index.html');
end;

procedure TfrPrincipal.FormActivate(Sender: TObject);
begin
  staEmpresa.Panels[0].Text := 'Empresa '+IntToStr(fDataM.Empresa);
  staEmpresa.Panels[1].Text := fDataM.EmpresaApel;
  staEmpresa.Panels[2].Text := fDataM.EmpresaCPFC;
  staEmpresa.Panels[3].Text := fDataM.EmpresaNome;
end;

procedure TfrPrincipal.miCadEmpresaAlterarClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcEmpresa)) then
    fcEmpresa := TfcEmpresa.Create(Self);
  fcEmpresa.Show;
end;

procedure TfrPrincipal.FormCreate(Sender: TObject);
begin
  fcEmpresa := nil;
end;

procedure TfrPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TfrPrincipal.miCadHistoricoClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCadHistorico)) then
    fcCadHistorico := TfcCadHistorico.Create(Self);
  fcCadHistorico.Show;
end;

procedure TfrPrincipal.miCadCategoriaClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCadCategoria)) then
    fcCadCategoria := TfcCadCategoria.Create(Self);
  fcCadCategoria.Show;
end;

procedure TfrPrincipal.miCadBandeiraClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCadBandeira)) then
    fcCadBandeira := TfcCadBandeira.Create(Self);
  fcCadBandeira.Show;
end;

procedure TfrPrincipal.miCatPagLancarClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCtaPagLan)) then
    fcCtaPagLan := TfcCtaPagLan.Create(Self, 0);
  fcCtaPagLan.Show;
end;

procedure TfrPrincipal.miCatPagBaixarClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCtaPagLan)) then
    fcCtaPagLan := TfcCtaPagLan.Create(Self, 1);
  fcCtaPagLan.Show;
end;

procedure TfrPrincipal.miCadClientesClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCadCliente)) then
    fcCadCliente := TfcCadCliente.Create(Self);
  fcCadCliente.Show;
end;

procedure TfrPrincipal.miCadFornecedoresClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCadFornecedor)) then
    fcCadFornecedor := TfcCadFornecedor.Create(Self);
  fcCadFornecedor.Show;
end;

procedure TfrPrincipal.mmConFluxoCaixaClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcConFluxoDeCaixa)) then
    fcConFluxoDeCaixa := TfcConFluxoDeCaixa.Create(Self);
  fcConFluxoDeCaixa.Show;
end;

procedure TfrPrincipal.miCtaRecLancarClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCtaRecLan)) then
    fcCtaRecLan := TfcCtaRecLan.Create(Self, 0);
  fcCtaRecLan.Show;
end;

procedure TfrPrincipal.miCtaRecReceberClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCtaRecLan)) then
    fcCtaRecLan := TfcCtaRecLan.Create(Self, 1);
  fcCtaRecLan.Show;
end;

procedure TfrPrincipal.miCadCartoesClick(Sender: TObject);
begin
  if fInicializaForm(TForm(fcCadCartaoDebCre)) then
    fcCadCartaoDebCre := TfcCadCartaoDebCre.Create(Self);
  fcCadCartaoDebCre.Show;
end;

end.
 