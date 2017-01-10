CREATE PROCEDURE [dbo].[usp_v4_Client_SelectByCustomerGUID]
(
	@CustomerGUID		uniqueidentifier
)

AS
BEGIN
	SET NOCOUNT ON;
	
	Select
			CustomerKey,
		--RedlassoUserGUID,
		--RedlassoUserName,
		--RedlassoPassword,
		ClientID,
		ClientName,
		FirstName,
		LastName,
		Email,
		Customer.LoginID,
		Customer.MultiLogin,
		Customer.CustomerGUID,
		Customer.MasterCustomerID,
		Client.MCID,
		Client.ClientGUID,
		Client.PlayerLogo,
		Client.IsActivePlayerLogo,
		DefaultPage,
		Client.AuthorizedVersion,
		Client.TimeZone,
		ISNULL(Client.dst,0) AS dst,
		ISNULL(Client.gmt,0) AS gmt
	From
			Customer
				inner join Client
					on Customer.ClientID=Client.ClientKey
	Where
			Customer.CustomerGUID=@CustomerGUID


END
