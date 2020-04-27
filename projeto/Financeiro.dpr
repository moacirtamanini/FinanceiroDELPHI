program Financeiro;

uses
  Forms,
  Dialogs,
  MidasLib,
  SysUtils,
  Classes,
  Messages,
  Controls,
  StdCtrls,
  Graphics,
  Windows,
  ucPrincipal in '..\fontes\ucPrincipal.pas' {frPrincipal},
  uDataM in '..\fontes\uDataM.pas' {fDataM: TDataModule},
  rtEndereco in '..\fontes\rtEndereco.pas',
  rtTypes in '..\fontes\rtTypes.pas',
  rtFone in '..\fontes\rtFone.pas',
  rtEmpresa in '..\fontes\rtEmpresa.pas',
  uUtils in '..\fontes\uUtils.pas',
  rtUsuario in '..\fontes\rtUsuario.pas',
  rtCliente in '..\fontes\rtCliente.pas',
  rtFornecedor in '..\fontes\rtFornecedor.pas',
  rtCategoria in '..\fontes\rtCategoria.pas',
  rtBandeira in '..\fontes\rtBandeira.pas',
  rtLancamento in '..\fontes\rtLancamento.pas',
  ucPadrao in '..\fontes\ucPadrao.pas' {fcPadrao},
  ucEmpresa in '..\fontes\ucEmpresa.pas' {fcEmpresa},
  uFrame_Endereco in '..\fontes\uFrame_Endereco.pas' {frame_Endereco: TFrame},
  uFrame_Fone in '..\fontes\uFrame_Fone.pas' {frame_Fone: TFrame},
  ucLogin in '..\fontes\ucLogin.pas' {frmLogin},
  ucEmpresaCadastro in '..\fontes\ucEmpresaCadastro.pas' {fcEmpresaCadastro},
  ucCadHistorico in '..\fontes\ucCadHistorico.pas' {fcCadHistorico},
  rtHistorico in '..\fontes\rtHistorico.pas',
  ucCadCategoria in '..\fontes\ucCadCategoria.pas' {fcCadCategoria},
  ucCadBandeira in '..\fontes\ucCadBandeira.pas' {fcCadBandeira},
  rtTypesCat in '..\fontes\rtTypesCat.pas',
  ucCadCartaoDebCre in '..\fontes\ucCadCartaoDebCre.pas' {fcCadCartaoDebCre},
  uFrame_Bandeira in '..\fontes\uFrame_Bandeira.pas' {frame_Bandeira: TFrame},
  uFrame_Categoria in '..\fontes\uFrame_Categoria.pas' {frame_Categoria: TFrame},
  ucCtaPagLan in '..\fontes\ucCtaPagLan.pas' {fcCtaPagLan},
  uFrame_CtaPAG in '..\fontes\uFrame_CtaPAG.pas' {frame_CtaPAG: TFrame},
  rtCtaPAG in '..\fontes\rtCtaPAG.pas',
  ucCadCliente in '..\fontes\ucCadCliente.pas' {fcCadCliente},
  uFrame_Cliente in '..\fontes\uFrame_Cliente.pas' {Frame_Cliente: TFrame},
  ucCadFornecedor in '..\fontes\ucCadFornecedor.pas' {fcCadFornecedor},
  uFrame_Fornecedor in '..\fontes\uFrame_Fornecedor.pas' {Frame_Fornecedor: TFrame},
  uFrame_ForCli in '..\fontes\uFrame_ForCli.pas' {Frame_ForCli: TFrame},
  uFrame_Historico in '..\fontes\uFrame_Historico.pas' {Frame_Historico: TFrame},
  uFrame_Moeda in '..\fontes\uFrame_Moeda.pas' {Frame_Moeda: TFrame},
  ucBrwHistorico in '..\fontes\ucBrwHistorico.pas' {fcBrwHistorico},
  ucBrwCliente in '..\fontes\ucBrwCliente.pas' {fcBrwCliente},
  ucBrwForne in '..\fontes\ucBrwForne.pas' {fcBrwForne},
  ucBrwCategoria in '..\fontes\ucBrwCategoria.pas' {fcBrwCategoria},
  ucBrwCartaoDebCre in '..\fontes\ucBrwCartaoDebCre.pas' {fcBrwCartaoDebCre},
  ucBrwFaturaCTAPAG in '..\fontes\ucBrwFaturaCTAPAG.pas' {fcBrwFaturaCTAPAG},
  ucCtaPagLanParceAlt in '..\fontes\ucCtaPagLanParceAlt.pas' {fcCtaPagLanParceAlt},
  ucCtaPagBai in '..\fontes\ucCtaPagBai.pas' {fcCtaPagBai},
  ucConFluxoDeCaixa in '..\fontes\ucConFluxoDeCaixa.pas' {fcConFluxoDeCaixa},
  rtCtaREC in '..\fontes\rtCtaREC.pas',
  ucCtaRecLan in '..\fontes\ucCtaRecLan.pas' {fcCtaRecLan},
  uFrame_CtaREC in '..\fontes\uFrame_CtaREC.pas' {frame_CtaREC: TFrame},
  ucBrwFaturaCTAREC in '..\fontes\ucBrwFaturaCTAREC.pas' {fcBrwFaturaCTAREC},
  ucCtaRecLanParceAlt in '..\fontes\ucCtaRecLanParceAlt.pas' {fcCtaRecLanParceAlt},
  ucCtaRecBai in '..\fontes\ucCtaRecBai.pas' {fcCtaRecBai},
  rtCartao in '..\fontes\rtCartao.pas',
  uFrame_Cartao in '..\fontes\uFrame_Cartao.pas' {Frame_Cartao: TFrame};

{$R *.res}

var
  sl: TStringList;
  dfm, temp: string;
  i: integer;
  Hnd: Cardinal;
begin
  Hnd := FindWindow(nil, '..: Sistema Financeiro :..');
  if (Hnd <> 0) then begin
    //ShowWindow(Hnd,sw_Restore);
    ShowWindow(Hnd,sw_Show);
    SetForegroundWindow(Hnd);
    Application.Terminate;
    Exit;
  end;

  { Verificar a existencia de .DFM em formato binary }
  if FileExists('\financeiro\fontes\*.dfm') then
  begin
    sl:= TStringList.create;
    try
      dfm:='';
      FileList(sl, '\financeiro\fontes\*.dfm');

      for i:=0 to sl.Count-1 do
      begin
        temp := LoadFromFileEx(sl[i],6);
        if (temp<>'object') and (temp<>'inheri') then
          dfm:= dfm + sl[i] +#13#10;
      end;

      if (dfm<>'') then
      begin
        MessageDlg('::  ATENÇÃO: Existem form''s em formato binary  ::'#13#10#13#10+dfm, mtError, [mbOK], 0);
        exit;
      end;
    finally
      sl.Free;
    end;
  end;

  Application.Initialize;
  Application.Title := '..: Sistema Financeiro :..';
  Application.CreateForm(TfDataM, fDataM);
  if (Assigned(fDataM)) and (fDataM.Loaded) then
    Application.CreateForm(TfrPrincipal, frPrincipal);
  Application.Run;
end.

