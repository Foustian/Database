CREATE PROCEDURE [dbo].[usp_v5_TAdsResult_GetRawData]
	@IQ_CC_Key varchar(50)
AS  
BEGIN   
	SET NOCOUNT ON;  
   
	SELECT [OPFileLoc] + [IQ_CC_Key] + '_adc.xml' AS 'xmlFile',[OPFileLoc] + SUBSTRING([IQ_CC_Key], 0, LEN([IQ_CC_Key]) - 1) + '.tgz' AS 'tgzFile'
	FROM [IQMediaGroup].[dbo].[IQ_ADS_Staging]
	WHERE IQ_CC_Key = @IQ_CC_Key

END