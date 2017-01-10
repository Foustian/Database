CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectFeedsExportSettingsByClientGUID]
	@ClientGuid uniqueidentifier
AS
BEGIN
	
	DECLARE @MaxFeedsExportItems AS INT,
			@IQRawMediaExpiration AS INT

	SELECT	@MaxFeedsExportItems = [Value]
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'v4MaxFeedsExportItems'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid asc

	SELECT	@IQRawMediaExpiration = [Value]
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'IQRawMediaExpiration'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid asc

	SELECT	@MaxFeedsExportItems as MaxFeedsExportItems,
			@IQRawMediaExpiration as IQRawMediaExpiration
END