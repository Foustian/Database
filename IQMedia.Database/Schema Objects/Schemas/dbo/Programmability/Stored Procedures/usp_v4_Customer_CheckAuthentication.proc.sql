-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- exec [dbo].[usp_Customer_CheckAuthentication] 'archdiocese@iqmediacorp.com','Achdiocese123'

CREATE PROCEDURE [dbo].[usp_v4_Customer_CheckAuthentication]
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
		IsNull(Client.dst,0) as dst,
		isNull(Client.gmt,0) as gmt
		
	FROM
		Customer
	Inner join  Client on Client.ClientKey = Customer.ClientID
	 
	WHERE
		Customer.LoginID = @Email
	AND
		Customer.CustomerPassword = @CustomerPassword COLLATE SQL_Latin1_General_Cp1_CS_AS
	AND
		Customer.IsActive = 1
	AND
		Customer.MasterCustomerID IS NULL
	
END
