CREATE PROCEDURE [dbo].[usp_Customer_SelectByCustomerGUIDForAuthentication]
(
	@CustomerGUID		uniqueidentifier
)

AS
BEGIN
	SET NOCOUNT ON;
	
	Select
	
		CustomerKey,	
		ClientID,
		ClientName,
		FirstName,
		LastName,
		Email,
		Customer.MultiLogin,
		Customer.CustomerGUID,
		Client.CustomHeaderImage,
		Client.IsCustomHeader,
		Client.ClientGUID,
		Client.PlayerLogo,
		Client.IsActivePlayerLogo,
		DefaultPage,
		Client.AuthorizedVersion
	From
			Customer
				inner join Client
					on Customer.ClientID=Client.ClientKey
	Where
			Customer.CustomerGUID=@CustomerGUID


END