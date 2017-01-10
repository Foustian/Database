CREATE PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_GetDayPartData]
	@AffiliateCode VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
   
	SELECT DISTINCT [IQ_DayPart].DP_Affil_Code AS 'AffiliateCode', DOW AS 'DayOfWeek', LEFT(RIGHT('000000' + CAST (TOD as VARCHAR(5)), 4),2) AS 'HourOfDay', [IQ_DayPart].IQ_DayPart_Name AS 'DayPartName', [IQ_DayPart].IQ_DayPart_Code AS 'DayPartCode'
	FROM [IQMediaGroup].[dbo].[IQ_DayPart]
	WHERE [IQ_DayPart].DP_Affil_Code = @AffiliateCode
	AND TOD % 100 = 0 -- Only return parts that start at the top of the hour

END