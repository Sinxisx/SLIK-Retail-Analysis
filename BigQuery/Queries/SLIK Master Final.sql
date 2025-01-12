SELECT * FROM `jago-technical-test.SLIK.SLIK_Aggregated` a
LEFT JOIN `jago-technical-test.SLIK.Customer_Scorecard` b
USING (ktp)
LEFT JOIN `jago-technical-test.SLIK.Customer_Whitelist` c
ON a.ktp=c.NIK
LEFT JOIN `jago-technical-test.SLIK.DEMOGRAPHIC1` d
USING (ktp)
LEFT JOIN `jago-technical-test.SLIK.DEMOGRAPHIC2` e
USING (ktp)