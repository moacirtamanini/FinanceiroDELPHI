unit rtTypes;

interface

uses Graphics;

type
  TCharSet = set of Char;

  TAntesBuscaEvent = function (Sender: TObject; var Msg: string): boolean of object;
  TDepoisBuscaEvent = procedure(Sender: TObject; Encontrou: Boolean) of object;
  TDepoisDaAcaoEvent = procedure(Sender: TObject) of object;

const
  Eol = #13#10;
  Ecr = #13;
  Elf = #10;
  cMascaraValor = '#,##0.00';
  cMascaraData  = 'dd/mm/yyyy';
  cMascaraDataHora  = 'dd/mm/yyyy hh:nn';
  cMascaraInteiro = '#,##0';
  cDataMinima: TDateTime = 25569; // 01/01/1970
  cDataMaxima: TDateTime = 49674; // 31/12/2035

  DCPKeyName = 'DC085C62366EC4F4EEC850D5CBC7F0F5';
  DCPVectorName = '194348455B12DE55';

{  CorGradeFonteNormal       = clBlack;
  CorGradeFonteRealce       = clBlack;
  CorGradeFonteNormalSele   = clWhite;
  CorGradeFonteRealceSele   = clWhite;
  //
  CorGradeFundoNormal       = $00FFF0E1;
  CorGradeFundoRealce       = $00FFE7CE;
  CorGradeFundoNormalSele   = $00FF9A35;
  CorGradeFundoRealceSele   = $00FF9A35;
  //
  CorGradeFonteColunaNormal = clBlack;
  CorGradeFonteColunaRealce = clBlack;
  CorGradeFundoColunaNormal = $00FFF0E1;
  CorGradeFundoColunaRealce = $00FFDDBB;
}
  CorGradeFonteNormal       = clBlack;
  CorGradeFonteRealce       = $ff0000;
  CorGradeFonteNormalSele   = $ffffff;
  CorGradeFonteRealceSele   = $ffffff;

  CorGradeFundoNormal       = $ffff80;
  CorGradeFundoRealce       = $ecec00;
  CorGradeFundoNormalSele   = $fa802e;
  CorGradeFundoRealceSele   = $f19150;
  //
  CorGradeFonteColunaNormal = clBlack;
  CorGradeFonteColunaRealce = $ffffff;
  CorGradeFundoColunaNormal = $f5e4d6;
  CorGradeFundoColunaRealce = $dbbf24;
  //
  CorGradeFonteAberto       = clBlack;
  CorGradeFonteAtraso       = clRed;
  CorGradeFonteQuitado      = clGreen;
  CorGradeFundoQuitado      = clSilver;
  CorGradeFundoQuitadoSele  = clLime;

implementation

end.
 