CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectIQLicenseByCustomerID]
(
	@CustomerID	BIGINT
)
AS
BEGIN

	SET NOCOUNT OFF;

	SELECT	
			[VALUE] AS 'IQLicense'
	FROM	
			IQClient_CustomSettings
				INNER JOIN	Client
					ON		IQClient_CustomSettings._ClientGuid=Client.ClientGUID
				INNER JOIN	Customer
					ON		Client.ClientKey=Customer.ClientID
						AND	Customer.CustomerKey=@CustomerID
	WHERE	
				Field = 'IQLicense'
		AND		(_ClientGuid = ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY 
			_ClientGuid DESC


END