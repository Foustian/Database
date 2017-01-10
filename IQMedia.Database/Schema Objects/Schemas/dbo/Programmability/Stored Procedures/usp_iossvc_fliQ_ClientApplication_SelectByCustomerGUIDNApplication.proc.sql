CREATE PROCEDURE [dbo].[usp_iossvc_fliQ_ClientApplication_SelectByCustomerGUIDNApplication]
(
	@CustomerGUID	UNIQUEIDENTIFIER,
	@Application	VARCHAR(155)
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT			
			[fliQ_ClientApplication].[FTPHost],
			[fliQ_ClientApplication].[FTPPath],
			[fliQ_ClientApplication].[FTPLoginID],
			[fliQ_ClientApplication].[FTPPwd],
			[fliQ_ClientApplication].[DefaultCategory],
			[fliQ_ClientApplication].[MaxVideoDuration],
			[fliQ_ClientApplication].[IsCategoryEnable],
			[fliQ_ClientApplication].[ForceLandscape]
	FROM	
			[fliQ_Customer] 
				INNER JOIN	[Client]
					ON	[fliQ_Customer].[ClientID] = [Client].[ClientKey]
					AND [fliQ_Customer].[CustomerGUID] = @CustomerGUID
				INNER JOIN	[fliQ_CustomerApplication]
					ON	[fliQ_Customer].[CustomerGUID] = [fliQ_CustomerApplication].[_FliqCustomerGUID]
				INNER JOIN	[fliQ_ClientApplication] 
					ON	[Client].[ClientGUID] = [fliQ_ClientApplication].[ClientGUID]
					and [fliQ_CustomerApplication].[_FliqApplicationID] = [fliQ_ClientApplication].[_FliqApplicationID]
				INNER JOIN	[fliQ_Application] 
					ON	[fliQ_Application].[ID] = [fliQ_CustomerApplication].[_FliqApplicationID]
					AND [fliQ_Application].[ID] = [fliQ_ClientApplication].[_FliqApplicationID]
					AND [fliQ_Application].[Application] = @Application
	WHERE
			[fliQ_Customer].[IsActive] = 1 
		AND [Client].[IsActive] = 1 
		AND [fliQ_CustomerApplication].[IsActive] = 1 
		AND [fliQ_ClientApplication].[IsActive] = 1 
		AND [fliQ_Application].[IsActive] = 1

END