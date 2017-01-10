CREATE PROCEDURE [dbo].[usp_v4_TAdsResult_SelectByIQCCKey]
	@IQ_CC_Key varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	ID, IQ_CC_Key, StationID, Hits, Hit_Count, CreatedDate, ISactive 
	FROM IQMediaGroup.dbo.IQ_ADS_Results
	WHERE IQ_CC_Key = @IQ_CC_Key
END