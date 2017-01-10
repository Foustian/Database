CREATE PROCEDURE [dbo].[usp_iossvc_fliQ_Customer_SelectForAuthentication]
(
	@LoginID		VARCHAR(300),
	@Application	VARCHAR(155)
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			[fliQ_Customer].[CustomerPassword],
			[fliQ_Customer].[PasswordAttempts],
			[fliQ_Application].[Version],
			[fliQ_Application].[Path],
			[fliQ_Customer].[CustomerGUID]

	FROM
			[fliQ_Customer]
				INNER JOIN	[Client]
					ON	[fliQ_Customer].[ClientID] = [Client].ClientKey
					AND	[fliQ_Customer].[LoginID] = @LoginID
				INNER JOIN	[fliQ_CustomerApplication] ON
						[fliQ_Customer].[CustomerGUID] = [fliQ_CustomerApplication].[_FliqCustomerGUID]
				INNER JOIN	[fliQ_ClientApplication]
					ON	[Client].[ClientGUID] = [fliQ_ClientApplication].[ClientGUID]
					AND	[fliQ_CustomerApplication].[_FliqApplicationID] = [fliQ_ClientApplication].[_FliqApplicationID]
				INNER JOIN	[fliQ_Application] ON
						[fliQ_Application].[ID] = [fliQ_CustomerApplication].[_FliqApplicationID]
						AND [fliQ_Application].[ID] = [fliQ_ClientApplication].[_FliqApplicationID]
						AND [fliQ_Application].[Application] = @Application
	WHERE
			[fliQ_Customer].[IsActive] = 1
		AND	[Client].[IsActive] = 1
		AND [fliQ_CustomerApplication].[IsActive] = 1 
		AND [fliQ_ClientApplication].[IsActive] = 1 
		AND [fliQ_Application].[IsActive] = 1

END