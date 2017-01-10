CREATE PROCEDURE [dbo].[usp_v4_fliQ_CustomerApplication_SelectByID]
	@ID bigint
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			fliQ_CustomerApplication.ID,
			fliQ_CustomerApplication._FliqApplicationID,
			Client.ClientKey,
			fliQ_Customer.CustomerKey,
			fliQ_CustomerApplication.IsActive
	FROM
			fliQ_CustomerApplication
				inner join fliQ_ClientApplication 
					on fliQ_CustomerApplication._FliqApplicationID = fliQ_ClientApplication._FliqApplicationID
				inner join Client 
					on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
					and Client.IsActive = 1
					and Client.IsFliq = 1
				inner join fliQ_Customer 
					on fliQ_CustomerApplication._FliqCustomerGUID = fliQ_Customer.CustomerGUID
					and fliQ_Customer.ClientID = Client.ClientKey
					and fliQ_Customer.IsActive = 1
	WHERE
		fliQ_CustomerApplication.ID = @ID	
END