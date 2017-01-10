CREATE PROCEDURE [dbo].[usp_iossvc_CustomCategory_SelectByCustomerGUID]
(
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
			[CustomCategory].[CategoryName],
			[CustomCategory].[CategoryGUID]
	FROM	
			[CustomCategory]
				INNER JOIN	[Client]
					ON	[CustomCategory].[ClientGUID] = [Client].[ClientGUID]
				INNER JOIN	[fliQ_Customer]
					ON	[Client].[ClientKey] = [fliQ_Customer].[ClientID]
					AND	[fliQ_Customer].[CustomerGUID] = @CustomerGUID

	WHERE
			[CustomCategory].[IsActive] = 1
		AND	[Client].[IsActive] = 1
		AND	[fliQ_Customer].[IsActive] = 1

	ORDER BY
			[CustomCategory].[CategoryName]

END