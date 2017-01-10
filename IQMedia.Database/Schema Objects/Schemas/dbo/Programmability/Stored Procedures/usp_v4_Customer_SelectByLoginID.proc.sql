CREATE PROCEDURE [dbo].[usp_v4_Customer_SelectByLoginID]
(
	@LoginID	VARCHAR(300)
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			CustomerKey,		
			ClientID,
			ClientName,
			FirstName,
			LastName,
			Email,
			LoginID,
			Customer.MultiLogin,
			Customer.CustomerGUID,
			Client.MCID,
			Customer.MasterCustomerID,
			Client.ClientGUID,
			Client.PlayerLogo,
			Client.IsActivePlayerLogo,
			DefaultPage,
			Client.AuthorizedVersion,
			Client.TimeZone,
			ISNULL(Client.dst,0) AS dst,
			ISNULL(Client.gmt,0) AS gmt		
	FROM
			Customer
				INNER JOIN  Client 
					ON	Client.ClientKey = Customer.ClientID
	 
	WHERE
			Customer.LoginID=@LoginID
		AND	Customer.IsActive=1

END