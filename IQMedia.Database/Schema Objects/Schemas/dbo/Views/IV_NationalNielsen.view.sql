CREATE VIEW [dbo].[IV_NationalNielsen]
WITH SCHEMABINDING
AS
    SELECT SUM(isnull(IQSSP_NationalNielsen.Audience,0)) as NationalAudience,
			SUM(isnull(IQSSP_NationalNielsen.MediaValue,0)) as NationalMediaValue,
			SUM(CONVERT(INT,ISNULL(IQSSP_NationalNielsen.IsActual,0))) as NationalIsActual,
			LocalDate,
			Title120,
			Station_Affil,
			COUNT_BIG(*) AS COUNT
	FROM dbo.IQSSP_NationalNielsen    
    GROUP BY LocalDate, Title120, Station_Affil;
GO