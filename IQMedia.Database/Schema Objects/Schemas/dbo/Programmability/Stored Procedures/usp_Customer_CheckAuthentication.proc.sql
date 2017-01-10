CREATE PROCEDURE [dbo].[usp_Customer_CheckAuthentication]
	-- Add the parameters for the stored procedure here
	@Email varchar(300),
	@CustomerPassword varchar(30)
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
		Customer.MultiLogin,
		Customer.CustomerGUID,
		Client.CustomHeaderImage,
		Client.IsCustomHeader,
		Client.ClientGUID,
		Client.PlayerLogo,
		Client.IsActivePlayerLogo,
		DefaultPage,
		AuthorizedVersion
		
	FROM
		Customer
	Inner join  Client on Client.ClientKey = Customer.ClientID
	 
	WHERE
		Customer.Email = @Email
	AND
		Customer.CustomerPassword = @CustomerPassword COLLATE SQL_Latin1_General_Cp1_CS_AS
	AND
		Customer.IsActive = 1
	
END
