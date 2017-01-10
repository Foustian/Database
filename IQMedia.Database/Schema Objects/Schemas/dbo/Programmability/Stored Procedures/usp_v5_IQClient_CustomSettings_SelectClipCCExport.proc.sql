CREATE PROCEDURE [dbo].[usp_v5_IQClient_CustomSettings_SelectClipCCExport]
(
	@ClientGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

    SELECT 
			[VALUE] AS 'ClipCCExport'
	FROM 
			IQClient_CustomSettings   
	WHERE 
			Field = 'ClipCCExport'  
		AND	(
				_ClientGuid = @ClientGUID 
			OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
			)  
	ORDER BY 
			_ClientGuid DESC 

END