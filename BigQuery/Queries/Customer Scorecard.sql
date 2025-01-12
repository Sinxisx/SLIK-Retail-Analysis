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
  AGG AS (
  SELECT
    ktp,
    SUM(CASE
        WHEN kondisi = 0 AND jenisKredit IN ('X-30', 'P05') THEN bakiDebet
        ELSE 0
    END
      ) active_cc_os,
    SUM(CASE
        WHEN kondisi = 0 AND jenisKredit IN ('X-30', 'P05') THEN plafon
        ELSE 0
    END
      ) active_cc_limit,
    SUM(CASE
        WHEN kondisi = 0 AND jenisKredit IN ('X-30', 'P05') THEN 1
        ELSE 0
    END
      ) active_cc_count,
    SUM(CASE
        WHEN kondisi != 0 AND jenisKredit IN ('X-30', 'P05') THEN 1
        ELSE 0
    END
      ) closed_cc_count,
    SUM(CASE
        WHEN kondisi = 0 AND jenisPenggunaan=3 AND jenisAgunan IS NULL AND jenisKredit NOT IN ('X-30', 'P05') THEN bakiDebet
        ELSE 0
    END
      ) active_pl_os,
    SUM(CASE
        WHEN kondisi = 0 AND jenisPenggunaan=3 AND jenisAgunan IS NULL AND jenisKredit NOT IN ('X-30', 'P05') THEN 1
        ELSE 0
    END
      ) active_unsecured_pl_count,
    SUM(CASE
        WHEN kondisi != 0 AND jenisPenggunaan=3 AND jenisAgunan IS NULL AND jenisKredit NOT IN ('X-30', 'P05') THEN 1
        ELSE 0
    END
      ) closed_unsecured_pl_count,
    SUM(CASE
        WHEN jenisAgunan IS NOT NULL AND jenisAgunan NOT IN ('X-176','X-189') AND kondisi = 0 AND jenisPenggunaan=3 AND jenisKredit NOT IN ('X-30', 'P05') THEN 1
        ELSE 0
    END
      ) active_secured_pl_count,
    SUM(CASE
        WHEN kondisi != 0 AND jenisPenggunaan=3 AND jenisAgunan IS NOT NULL AND jenisAgunan NOT IN ('X-176','X-189') AND jenisKredit NOT IN ('X-30', 'P05') THEN 1
        ELSE 0
    END
      ) closed_secured_pl_count,
    SUM(angsuran) total_installment,
    GREATEST(MAX(Ht_202310), MAX(Ht_202309), MAX(Ht_202308), MAX(Ht_202307), MAX(Ht_202306), MAX(Ht_202305), MAX(Ht_202304), MAX(Ht_202303), MAX(Ht_202302), MAX(Ht_202301), MAX(Ht_202212), MAX(Ht_202211),MAX(Ht_202210), MAX(Ht_202209), MAX(Ht_202208), MAX(Ht_202207), MAX(Ht_202206), MAX(Kol_202205), MAX(Ht_202204), MAX(Ht_202203), MAX(Ht_202202), MAX(Ht_202201), MAX(Ht_202112), MAX(Ht_202111)) dpd_max,
    GREATEST(MAX(Kol_202310), MAX(Kol_202309), MAX(Kol_202308), MAX(Kol_202307), MAX(Kol_202306), MAX(Kol_202305), MAX(Kol_202304), MAX(Kol_202303), MAX(Kol_202302), MAX(Kol_202301), MAX(Kol_202212), MAX(Kol_202211),MAX(Kol_202210), MAX(Kol_202209), MAX(Kol_202208), MAX(Kol_202207), MAX(Kol_202206), MAX(Kol_202205), MAX(Kol_202204), MAX(Kol_202203), MAX(Kol_202202), MAX(Kol_202201), MAX(Kol_202112), MAX(Kol_202111)) col_max,

  FROM
    COMPLETE
  GROUP BY
    ktp),
  FINAL AS(
  SELECT
    ktp NIK,
    (active_cc_os*0.05 + total_installment) SLIK_Installment,
    (active_cc_limit+active_pl_os) SLIK_Exposure,
    dpd_max Max_DPD,
    col_max Max_Col,
    active_cc_count Number_of_CC_Active,
    closed_cc_count Number_of_CC_Closed,
    active_unsecured_pl_count Number_of_Unsecured_PL_Active,
    closed_unsecured_pl_count Number_of_Unsecured_PL_Closed,
    active_secured_pl_count Number_of_Secured_PL_Active,
    closed_secured_pl_count Number_of_Secured_PL_Closed
  FROM
    AGG )
SELECT
  *
FROM
  FINAL