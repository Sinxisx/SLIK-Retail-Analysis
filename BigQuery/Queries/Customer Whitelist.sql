WITH
  COMPLETE AS(
  SELECT
    *,
    CASE
      WHEN LENGTH(CAST(ljk AS STRING))<4 THEN 'Bank'
      WHEN LENGTH(CAST(ljk AS STRING))=4 THEN 'Modal Ventura'
      WHEN LENGTH(CAST(ljk AS STRING))=6 AND SUBSTR(CAST(ljk AS STRING),1,1) = '6' THEN 'BPR'
      ELSE 'Perusahaan Pembiayaan'
  END
    AS ljkJenis
  FROM
    `jago-technical-test.SLIK.SLIK_FINAL` ),
  ACTIVE AS(
  SELECT
    ktp,
    GREATEST(MAX(Kol_202310), MAX(Kol_202309), MAX(Kol_202308), MAX(Kol_202307), MAX(Kol_202306), MAX(Kol_202305), MAX(Kol_202304), MAX(Kol_202303), MAX(Kol_202302), MAX(Kol_202301), MAX(Kol_202212), MAX(Kol_202211),MAX(Kol_202210), MAX(Kol_202209), MAX(Kol_202208), MAX(Kol_202207), MAX(Kol_202206), MAX(Kol_202205), MAX(Kol_202204), MAX(Kol_202203), MAX(Kol_202202), MAX(Kol_202201), MAX(Kol_202112), MAX(Kol_202111)) active_col,
    MAX(frekuensiRestrukturisasi) active_restru
  FROM
    COMPLETE
  WHERE
    kondisi = 0
  GROUP BY
    ktp ),
  WO AS (
  SELECT
    ktp,
    SUM(CASE
        WHEN kondisi IN (3, 4) THEN 1
        ELSE 0
    END
      ) write_off
  FROM
    COMPLETE
  GROUP BY
    ktp ),
  WHITELIST AS(
  SELECT
    *,
    CASE
      WHEN a.active_col > 2 THEN 'Active Collections > 2'
      WHEN a.active_restru > 0 THEN 'Active Restructure'
      WHEN b.write_off > 0 THEN 'Write-off'
      ELSE 'Whitelisted'
  END
    Result
  FROM
    WO b
  LEFT JOIN
    ACTIVE a
  USING
    (ktp) )
SELECT
  ktp NIK,
  Result
FROM
  WHITELIST