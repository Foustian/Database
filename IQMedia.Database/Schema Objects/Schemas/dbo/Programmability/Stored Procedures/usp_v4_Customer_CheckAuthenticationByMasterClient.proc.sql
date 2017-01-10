CREATE PROCEDURE [dbo].[usp_v4_Customer_CheckAuthenticationByMasterClient]
	@MasterCustomerID bigint,
	@ClientID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		CustomerKey,
		--RedlassoUserGUID,
		--RedlassoUserName,
		--RedlassoPassword,
		ClientID,
		ClientName,
		FirstName,
		LastName,
		Email,
		LoginID,
		Customer.MultiLogin,
		Customer.CustomerGUID,
		Client.MCID,
		customer.MasterCustomerID,
		Customer.CustomerPassword,
		Client.ClientGUID,
		Client.PlayerLogo,
		Client.IsActivePlayerLogo,
		DefaultPage,
		Client.AuthorizedVersion,
		Client.TimeZone,
		IsNull(Client.dst,0) as dst,
		isNull(Client.gmt,0) as gmt
		
	FROM
		Customer
			Inner join  Client 
				on Customer.ClientID = Client.ClientKey
				AND (Customer.MasterCustomerID = @MasterCustomerID OR Customer.CustomerKey = @MasterCustomerID)
				AND Client.ClientKey = @ClientID 
	WHERE
		Customer.IsActive = 1 and Client.IsActive = 1
	
END
