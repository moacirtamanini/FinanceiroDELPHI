CREATE OR ALTER trigger ctarecparcebaixa_aiud for ctarecparcebaixa
active after insert or update or delete position 0
AS
  declare variable wDoctoID integer;
  declare variable wParcela integer;
  declare variable wStatuFA integer;
  declare variable wStatuPA integer;
  declare variable wQtdeParce integer;
  declare variable wVlrFatu numeric(18,4);
  declare variable wVlrPago numeric(18,4);
  declare variable wVlrParce numeric(18,4);
  declare variable wVlrBaixa numeric(18,4);
  declare variable wVlrEstor numeric(18,4);
begin
  wDoctoID = 0;
  wStatuFA = 0;
  wStatuPA = 0;

  IF (INSERTING) THEN
  BEGIN
    wDoctoID = NEW.doctoid;
    wParcela = NEW.parcela;
  END
  ELSE
  BEGIN
    wDoctoID = OLD.doctoid;
    wParcela = NEW.parcela;
  END

  if (wDoctoID < 1) then EXIT;

  wVlrPago = 0;

  select coalesce(sum(ValorPrincipal),0) from ctarecparcebaixa
    where (doctoid = :wdoctoid) and (ctarecparcebaixa.status = 0)
      into :wvlrpago;

  select count(*) from ctarecparce where (doctoid = :wdoctoid) into :wQtdeParce;
  if (wqtdeparce > 0) then
    wstatufa = 1; /* Desdobrada */
  else
    wstatufa = 0; /* Pendente   */

  select count(*) from ctarecparcebaixa where (doctoid = :wdoctoid) into :wQtdeParce;
  if (wqtdeparce > 0) then
    wstatufa = 2;  /* Pagto Parcial */

  select coalesce(ValorPrincipal,0) from ctarecdocto where (id = :wdoctoid) into :wvlrfatu;
  if (wvlrfatu = wvlrpago) then wstatufa = 3;

  update ctarecdocto set valorpago = :wvlrpago, status = :wstatufa where (id = :wdoctoid);

  /* Atualiza a Parcela */
  select coalesce(sum(ValorPrincipal),0) from ctarecparcebaixa
    where (doctoid = :wdoctoid) and (parcela = :wparcela) and (ctarecparcebaixa.status = 0)
      into :wvlrpago;
  update ctarecparce set valorpago = :wvlrpago, status = :wstatufa where (doctoid = :wdoctoid) and (parcela = :wparcela);

  select coalesce(sum(VALORPARCELA),0)   from ctarecparce      where (doctoid = :wdoctoid) and (Parcela = :wparcela) into :wVlrParce;
  select coalesce(sum(VALORPRINCIPAL),0) from ctarecparcebaixa where (doctoid = :wdoctoid) and (Parcela = :wparcela) and (status = 0) into :wVlrBaixa;
  select coalesce(sum(VALORPRINCIPAL),0) from ctarecparcebaixa where (doctoid = :wdoctoid) and (Parcela = :wparcela) and (status = 1) into :wVlrEstor;
  if ((wVlrBaixa - wVlrEstor) >= wVlrParce) then
    update ctarecparce set status = 3 where (doctoid = :wdoctoid) and (Parcela = :wparcela);
  else
    if ((wVlrBaixa - wVlrEstor) = 0) then
      update ctarecparce set status = 0 where (doctoid = :wdoctoid) and (Parcela = :wparcela);
    else
      update ctarecparce set status = 2 where (doctoid = :wdoctoid) and (Parcela = :wparcela);
end

/* Status Fatura : 0-Pendente  || 1-Desdobrada    || 2-Pagto Parcial || 3-Quitada || 7-Cancelada */
/* Status Parcela: 0-Em aberto                    || 2-Pagto Parcial || 3-Quitada || 7-Cancelada */
/* Status Baixa  : 0-Normal    || 1-Estorno */