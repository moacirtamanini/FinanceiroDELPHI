unit rtTypesCat;

interface

type
  TCategPadrao = record
    Codigo    : integer;
    TpConta   : integer;
    Classi    : string;
    Apelido   : string;
    Descricao : string;
  end;

  THistoPadrao = record
    Codigo    : integer;
    Descricao : string;
  end;

  TBandePadrao = record
    Codigo    : integer;
    Descricao : string;
  end;

const
  co_CategPadrao: array[1..52] of TCategPadrao = (
      (Codigo:  1;    TpConta: 0;    Classi: '1';                 Apelido: '';                Descricao: 'ATIVO (BENS E DIREITOS)'),
      (Codigo:  2;    TpConta: 0;    Classi: '1.1';               Apelido: '';                Descricao: 'BENS'),
      (Codigo:  3;    TpConta: 0;    Classi: '1.1.1';             Apelido: '';                Descricao: 'DISPONIBILIDADES'),
      (Codigo:  4;    TpConta: 0;    Classi: '1.1.1.01';          Apelido: '';                Descricao: 'CAIXA'),
      (Codigo:  5;    TpConta: 1;    Classi: '1.1.1.01.0001';     Apelido: 'CX';              Descricao: 'Caixa'),

      (Codigo: 20;    TpConta: 0;    Classi: '1.1.1.02';          Apelido: '';                Descricao: 'BANCOS CONTA MOVIMENTO'),
      (Codigo: 21;    TpConta: 1;    Classi: '1.1.1.02.0001';     Apelido: 'VIA81';           Descricao: 'Viacredi Moacir - 81.996-4'),
      (Codigo: 22;    TpConta: 1;    Classi: '1.1.1.02.0002';     Apelido: 'VIA284';          Descricao: 'Viacredi Moacir - 284.410-9'),

      (Codigo: 30;    TpConta: 0;    Classi: '1.1.1.03';          Apelido: '';                Descricao: 'POUPAN�A'),
      (Codigo: 31;    TpConta: 1;    Classi: '1.1.1.03.0001';     Apelido: 'POVIA81';         Descricao: 'Viacredi Moacir - 81.996-4'),
      (Codigo: 32;    TpConta: 1;    Classi: '1.1.1.03.0002';     Apelido: 'POVIA284';        Descricao: 'Viacredi Moacir - 284.410-9'),

      (Codigo: 40;    TpConta: 0;    Classi: '1.1.1.04';          Apelido: '';                Descricao: 'APLICA��ES'),
      (Codigo: 41;    TpConta: 1;    Classi: '1.1.1.04.0001';     Apelido: 'APVIA81';         Descricao: 'Viacredi Moacir - 81.996-4'),
      (Codigo: 42;    TpConta: 1;    Classi: '1.1.1.04.0002';     Apelido: 'APVIA284';        Descricao: 'Viacredi Moacir - 284.410-9'),

      (Codigo: 60;    TpConta: 0;    Classi: '1.2';               Apelido: '';                Descricao: 'DIREITOS'),
      (Codigo: 61;    TpConta: 0;    Classi: '1.2.1';             Apelido: '';                Descricao: 'INVESTIMENTOS'),
      (Codigo: 62;    TpConta: 0;    Classi: '1.2.1.01';          Apelido: '';                Descricao: 'INVESTIMENTOS DIVERSOS'),
      (Codigo: 63;    TpConta: 1;    Classi: '1.2.1.01.0001';     Apelido: 'IVVIA81';         Descricao: 'Viacredi Moacir - 81.996-4'),
      (Codigo: 64;    TpConta: 1;    Classi: '1.2.1.01.0002';     Apelido: 'IVVIA284';        Descricao: 'Viacredi Moacir - 284.410-9'),

      (Codigo: 71;    TpConta: 0;    Classi: '1.2.2';             Apelido: '';                Descricao: 'A RECEBER'),
      (Codigo: 72;    TpConta: 0;    Classi: '1.2.2.02';          Apelido: '';                Descricao: 'CLIENTES A RECEBER'),
      (Codigo: 73;    TpConta: 1;    Classi: '1.2.2.02.0001';     Apelido: 'ARCLFU';          Descricao: 'Cliente A Receber - Fulano'),
      (Codigo: 74;    TpConta: 1;    Classi: '1.2.2.02.0002';     Apelido: 'ARCLBE';          Descricao: 'Cliente A Receber - Beltrano'),

      (Codigo: 90;    TpConta: 0;    Classi: '1.2.2.03';          Apelido: '';                Descricao: 'OUTRAS CONTAS A RECEBER'),
      (Codigo: 91;    TpConta: 1;    Classi: '1.2.2.03.0001';     Apelido: 'AROUFU';          Descricao: 'A Receber de Fulano'),
      (Codigo: 92;    TpConta: 1;    Classi: '1.2.2.03.0002';     Apelido: 'AROUBE';          Descricao: 'A Receber de Beltrano'),



      (Codigo: 1000;  TpConta: 0;    Classi: '2';                 Apelido: '';                Descricao: 'PASSIVO (OBRIGA��ES)'),
      (Codigo: 1001;  TpConta: 0;    Classi: '2.1';               Apelido: '';                Descricao: 'OBRIGA��ES A PAGAR'),
      (Codigo: 1002;  TpConta: 0;    Classi: '2.1.1';             Apelido: '';                Descricao: 'FORNECEDORES A PAGAR'),
      (Codigo: 1003;  TpConta: 0;    Classi: '2.1.1.01';          Apelido: '';                Descricao: 'FORNECEDORES DIVERSOS'),
      (Codigo: 1004;  TpConta: 1;    Classi: '2.1.1.01.0001';     Apelido: '';                Descricao: 'Fornecedores Diversos A Pagar'),

      (Codigo: 1010;  TpConta: 0;    Classi: '2.1.1.02';          Apelido: '';                Descricao: 'CONTAS A PAGAR'),
      (Codigo: 1011;  TpConta: 1;    Classi: '2.1.1.02.0001';     Apelido: 'AGUA';            Descricao: '�gua e/ou Esgoto'),
      (Codigo: 1012;  TpConta: 1;    Classi: '2.1.1.02.0002';     Apelido: 'LUZ';             Descricao: 'Energia El�trica'),
      (Codigo: 1013;  TpConta: 1;    Classi: '2.1.1.02.0003';     Apelido: 'TELEFONE';        Descricao: 'Telefone Fixo'),
      (Codigo: 1014;  TpConta: 1;    Classi: '2.1.1.02.0004';     Apelido: 'CELULAR';         Descricao: 'Telefone M�vel/Celular'),
      (Codigo: 1015;  TpConta: 1;    Classi: '2.1.1.02.0005';     Apelido: 'INTERNET';        Descricao: 'Interner Fixa'),
      (Codigo: 1016;  TpConta: 1;    Classi: '2.1.1.02.0006';     Apelido: 'TV';              Descricao: 'TV A Cabo ou Via Sat�lite'),
      (Codigo: 1017;  TpConta: 1;    Classi: '2.1.1.02.0007';     Apelido: 'ALUGUELCASA';     Descricao: 'Aluguel Casa / AP'),
      (Codigo: 1018;  TpConta: 1;    Classi: '2.1.1.02.0008';     Apelido: 'ALUGUELEMPRE';    Descricao: 'Aluguel Empresa'),
      (Codigo: 1019;  TpConta: 1;    Classi: '2.1.1.02.0009';     Apelido: 'ALUGUELLOJA';     Descricao: 'Aluguel Loja'),
      (Codigo: 1020;  TpConta: 1;    Classi: '2.1.1.02.0010';     Apelido: 'LIMPCASA';        Descricao: 'Limpeza e Conserva��o da Casa'),
      (Codigo: 1021;  TpConta: 1;    Classi: '2.1.1.02.0011';     Apelido: 'LIMPVEIC';        Descricao: 'Limpeza e Conserva��o de Ve�culos'),
      (Codigo: 1022;  TpConta: 1;    Classi: '2.1.1.02.0012';     Apelido: 'MANUCASA';        Descricao: 'Manuten��o da Casa'),
      (Codigo: 1023;  TpConta: 1;    Classi: '2.1.1.02.0013';     Apelido: 'MANUVEIC';        Descricao: 'Manuten��o de Ve�culos'),
      (Codigo: 1024;  TpConta: 1;    Classi: '2.1.1.02.0014';     Apelido: 'MANUDIVE';        Descricao: 'Manuten��o de Diversos'),
      (Codigo: 1025;  TpConta: 1;    Classi: '2.1.1.02.0015';     Apelido: 'EQUIPAMENTOS';    Descricao: 'Aquisi��o de Equipamentos Diversos'),
      (Codigo: 1026;  TpConta: 1;    Classi: '2.1.1.02.0016';     Apelido: 'EQUIPELETRON';    Descricao: 'Aquisi��o de Equipamentos Eletr�nicos'),
      (Codigo: 1027;  TpConta: 1;    Classi: '2.1.1.02.0017';     Apelido: 'EQUIPCOMPUTA';    Descricao: 'Aquisi��o de Computadores e Perif�ricos'),
      (Codigo: 1028;  TpConta: 1;    Classi: '2.1.1.02.0018';     Apelido: 'AQUIIMOVEIS';     Descricao: 'Aquisi��o de Im�veis'),
      (Codigo: 1029;  TpConta: 1;    Classi: '2.1.1.02.0019';     Apelido: 'AQUIVEICULOS';    Descricao: 'Aquisi��o de Ve�culos'),
      (Codigo: 1030;  TpConta: 1;    Classi: '2.1.1.02.0020';     Apelido: 'AQUIMOVEIS';      Descricao: 'Aquisi��o de M�veis e Utens�lios'));


  co_HistoPadrao: array[1..7] of THistoPadrao = (
      (Codigo:  1;    Descricao: 'VALOR RECEBIDO DE * REFERENTE *'),
      (Codigo:  2;    Descricao: 'PAGTO DE * A *'),
      (Codigo:  3;    Descricao: 'NOSSO DEP�SITO'),
      (Codigo:  4;    Descricao: 'SAQUE COM CART�O'),
      (Codigo:  5;    Descricao: 'COMPRA COM CART�O DE D�BITO (*)'),
      (Codigo:  6;    Descricao: 'COMPRA COM CART�O DE CR�DITO (*)'),
      (Codigo:  7;    Descricao: 'VALOR TRANSFERIDO DE * PARA *'));

  co_BandePadrao: array[1..19] of TBandePadrao = (
      (Codigo:  1;    Descricao: 'VISA'),
      (Codigo:  2;    Descricao: 'Mastercard'),
      (Codigo:  3;    Descricao: 'AMEX'),
      (Codigo:  4;    Descricao: 'ELO'),
      (Codigo:  5;    Descricao: 'Hipercard'),
      (Codigo:  6;    Descricao: 'Diners Club'),
      (Codigo:  7;    Descricao: 'Sorocred'),
      (Codigo:  8;    Descricao: 'Dicover Network'),
      (Codigo:  9;    Descricao: 'Banescard'),
      (Codigo: 10;    Descricao: 'Policard'),
      (Codigo: 11;    Descricao: 'Agicard'),
      (Codigo: 12;    Descricao: 'JCB'),
      (Codigo: 13;    Descricao: 'CredSystem'),
      (Codigo: 14;    Descricao: 'Cabal'),
      (Codigo: 15;    Descricao: 'Green Card'),
      (Codigo: 16;    Descricao: 'Verocheque'),
      (Codigo: 17;    Descricao: 'Avista'),
      (Codigo: 18;    Descricao: 'Aura'),
      (Codigo: 19;    Descricao: 'Credz'));

implementation

end.

