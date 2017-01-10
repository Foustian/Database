CREATE PROCEDURE [dbo].[usp_IQ_Sentiments_SelectByClientGuid]
	@ClientGuid uniqueidentifier
AS
BEGIN
	DECLARE @UseDefaultWords BIT = 0

	-- Use default words if the specified client doesn't have any words specific to them
	IF (SELECT COUNT(*) FROM IQMediaGroup.dbo.IQ_Sentiments WHERE _ClientGuid = @ClientGuid) = 0
	  BEGIN
		SET @UseDefaultWords = 1
	  END

	;WITH Temp as
	(
		SELECT 
			ROW_NUMBER() OVER( PARTITION BY WORD ORDER BY _ClientGuid desc) as Rownum,
			Word,
			Value
		FROM 
			IQMediaGroup.dbo.IQ_Sentiments
		WHERE 
			_ClientGuid = @ClientGuid OR (@UseDefaultWords = 1 AND _ClientGuid IS NULL)
	)
	SELECT Word,Value FROM Temp WHERE Rownum= 1
END