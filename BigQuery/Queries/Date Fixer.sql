SELECT
  *,
  DATE(SUBSTR(tanggalAwalKredit,1,19)) tanggalAwalKreditNew,
FROM
  `jago-technical-test.SLIK.SLIK_COLHT`