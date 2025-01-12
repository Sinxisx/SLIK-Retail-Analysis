WITH
  COMPLETE AS(
    SELECT *,
    CASE WHEN LENGTH(CAST(ljk AS STRING))<4 THEN 'Bank'
    WHEN LENGTH(CAST(ljk AS STRING))=4 THEN 'Modal Ventura'
    WHEN LENGTH(CAST(ljk AS STRING))=6 AND SUBSTR(CAST(ljk AS STRING),1,1) = '6' THEN 'BPR'
    ELSE 'Perusahaan Pembiayaan'
    END AS ljkJenis
    FROM `jago-technical-test.SLIK.SLIK_FINAL`
  ),
  ALL_LOANS AS (
  SELECT
    ktp,
    COUNT(ktp) flags_allcondition_count,
    GREATEST(MAX(Ht_202310), MAX(Ht_202309), MAX(Ht_202308)) dpd_allcondition_last_3months_max,
    GREATEST(MAX(Kol_202310), MAX(Kol_202309), MAX(Kol_202308), MAX(Kol_202307), MAX(Kol_202306), MAX(Kol_202305)) collection_status_allcondition_last_6months_max,
    GREATEST(MAX(Kol_202310), MAX(Kol_202309), MAX(Kol_202308), MAX(Kol_202307), MAX(Kol_202306), MAX(Kol_202305), MAX(Kol_202304), MAX(Kol_202303), MAX(Kol_202302), MAX(Kol_202301), MAX(Kol_202212), MAX(Kol_202211))collection_status_allcondition_last_12months_max,
    SUM(CASE WHEN kondisi = 0 THEN plafon ELSE 0 END) plafon_sum,
    MAX(CASE
        WHEN kondisi = 0 THEN DATE_DIFF(PARSE_DATE('%Y-%m-%d', '2023-11-30'), tanggalAwalKreditNew, MONTH)
        ELSE 0
    END
      ) mob_allcondition_max,
    SUM(CASE WHEN kondisi = 0 THEN bakiDebet ELSE 0 END) balance_sum,
    SUM(CASE
        WHEN kondisi IN (3, 4) THEN 1
        ELSE 0
    END
      ) flags_chargewriteoff_count,
    SUM(CASE
        WHEN kondisi=0 AND jenisPenggunaan = 3 AND jenisAgunan IS NULL THEN bakiDebet
        ELSE 0
    END
      ) balance_unsecured_sum,
    SUM(CASE WHEN frekuensiRestrukturisasi > 0 AND jenisPenggunaan=3 AND jenisAgunan IS NULL THEN 1 ELSE 0 END) flags_restructured_allcondition_unsecured_count
  FROM
    COMPLETE
  GROUP BY
    ktp ),

  ALL_ACTIVE_LOANS AS (
  SELECT
    ktp,
    SUM(CASE
        WHEN frekuensiRestrukturisasi>0 THEN 1
        ELSE 0
    END
      ) flags_restructured_active_count,
    MAX(plafon) plafond_credit_card_active_max,
    MAX(angsuran)installment_active_max,
    AVG(DATE_DIFF(PARSE_DATE('%Y-%m-%d', '2023-11-30'), tanggalAwalKreditNew, MONTH)) mob_active_avg,
    SUM(CASE
        WHEN jenisPenggunaan=3 AND jenisAgunan NOT IN ('X-176','X-189') AND jenisKredit NOT IN ('X-30', 'P05') THEN bakiDebet
        ELSE 0
    END
      )balance_personal_loan_active_sum,
    SUM(CASE
        WHEN jenisPenggunaan=3 AND jenisAgunan NOT IN ('X-176','X-189') AND jenisKredit NOT IN ('X-30', 'P05') THEN angsuran
        ELSE 0
    END
      ) installment_personal_loan_active_sum,
    SUM(CASE
        WHEN jenisPenggunaan=3 AND jenisKredit IN ('X-30', 'P05') THEN plafon
        ELSE 0
    END
      )plafond_credit_card_active_sum,
    SUM(CASE
        WHEN jenisPenggunaan=3 AND jenisKredit IN ('X-30', 'P05') THEN bakiDebet
        ELSE 0
    END
      ) balance_credit_card_active_sum,
    SUM(CASE
        WHEN GREATEST(Ht_202310, Ht_202309, Ht_202308, Ht_202307, Ht_202306, Ht_202305, Ht_202304, Ht_202303, Ht_202302, Ht_202301, Ht_202212, Ht_202211,Ht_202210, Ht_202209, Ht_202208, Ht_202207, Ht_202206, Ht_202205, Ht_202204, Ht_202203, Ht_202202, Ht_202201, Ht_202112, Ht_202111)>10 THEN 1
        ELSE 0
    END
      ) flags_active_dpd10plus_count
  FROM
    COMPLETE
  WHERE
    kondisi = 0
  GROUP BY
    ktp ),

  ALL_NONBANK AS (
  SELECT
    ktp,
    GREATEST(MAX(Ht_202310), MAX(Ht_202309), MAX(Ht_202308), MAX(Ht_202307), MAX(Ht_202306), MAX(Ht_202305), MAX(Ht_202304), MAX(Ht_202303), MAX(Ht_202302), MAX(Ht_202301), MAX(Ht_202212), MAX(Ht_202211)) dpd_nonbank_allcondition_last_12months_max
  FROM
    COMPLETE
  WHERE
    ljkJenis NOT IN ('BPR',
      'Bank')
  GROUP BY
    ktp ),

  CLOSED_UNSECURED AS (
  SELECT
    ktp,
    GREATEST(MAX(Kol_202310), MAX(Kol_202309), MAX(Kol_202308), MAX(Kol_202307), MAX(Kol_202306), MAX(Kol_202305), MAX(Kol_202304), MAX(Kol_202303), MAX(Kol_202302), MAX(Kol_202301), MAX(Kol_202212), MAX(Kol_202211),MAX(Kol_202210), MAX(Kol_202209), MAX(Kol_202208), MAX(Kol_202207), MAX(Kol_202206), MAX(Kol_202205), MAX(Kol_202204), MAX(Kol_202203), MAX(Kol_202202), MAX(Kol_202201), MAX(Kol_202112), MAX(Kol_202111)) collection_status_closed_unsecured_last_24months_max
  FROM
    COMPLETE
  WHERE
    kondisi != 0
    AND jenisAgunan IS NULL
    AND jenisPenggunaan = 3
  GROUP BY
    ktp )
SELECT
  *
FROM
ALL_LOANS
LEFT JOIN
ALL_ACTIVE_LOANS
USING (ktp)
LEFT JOIN
ALL_NONBANK
USING (ktp)
LEFT JOIN
CLOSED_UNSECURED
USING (ktp)