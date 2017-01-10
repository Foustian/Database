
CREATE PROCEDURE [dbo].[usp_Client_SelectByCustomerGUID]
(
	@CustomerGUID		uniqueidentifier
)

AS
BEGIN
	SET NOCOUNT ON;
	
	Select
			Client.ClientGUID,
			Client.IsActivePlayerLogo,
			Client.PlayerLogo
	From
			Customer
				inner join Client
					on Customer.ClientID=Client.ClientKey
	Where
			Customer.CustomerGUID=@CustomerGUID


END
