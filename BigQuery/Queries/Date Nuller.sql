-- Replace #VALUE! with NULL and convert to DATE
UPDATE `jago-technical-test.SLIK.SLIK_RAW`
SET tanggalUpdate = NULLIF(tanggalUpdate, '#VALUE!')
WHERE tanggalUpdate = '#VALUE!';

UPDATE `jago-technical-test.SLIK.SLIK_RAW`
SET tanggalAkadAwal = NULLIF(tanggalAkadAwal, '#VALUE!')
WHERE tanggalAkadAwal = '#VALUE!';

UPDATE `jago-technical-test.SLIK.SLIK_RAW`
SET tanggalJatuhTempo = NULLIF(tanggalJatuhTempo, '#VALUE!')
WHERE tanggalJatuhTempo = '#VALUE!';

UPDATE `jago-technical-test.SLIK.SLIK_RAW`
SET tanggalKondisi = NULLIF(tanggalKondisi, '#VALUE!')
WHERE tanggalKondisi = '#VALUE!';