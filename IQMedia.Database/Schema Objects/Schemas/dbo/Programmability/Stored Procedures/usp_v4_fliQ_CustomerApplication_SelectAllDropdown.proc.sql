CREATE PROCEDURE [dbo].[usp_v4_fliQ_CustomerApplication_SelectAllDropdown]
	@IsFetchClient bit,
	@ClientID bigint
AS 
BEGIN
	IF(@IsFetchClient = 1)
	BEGIN
		
		SELECT
			Client.ClientKey,
			Client.ClientName
		FROM
			Client
		WHERe
			Client.IsActive = 1
			and Client.IsFliq = 1
		order by Client.ClientName
	END
	
	IF(@ClientID IS NOT NULL)
	BEGIN
		Select	
			fliQ_Application.ID,
			fliQ_Application.[Application]
		FROM		
				fliQ_ClientApplication
					inner join fliQ_Application 
						on fliQ_ClientApplication._FliqApplicationID = fliQ_Application.ID
						and fliQ_ClientApplication.IsActive = 1
						and fliQ_Application.IsActive = 1
					inner join Client 
						on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
						and Client.IsActive = 1
						and Client.IsFliq = 1
		WHERE
				(@ClientID IS NULL OR Client.ClientKey = @ClientID)
		order by
			fliQ_Application.[Application]

		SELECT
			fliQ_Customer.CustomerKey,
			fliQ_Customer.FirstName,
			fliQ_Customer.LastName
		FROM	
			fliQ_Customer 
				inner join Client
					on fliQ_Customer.ClientID = Client.ClientKey
					and fliQ_Customer.IsActive = 1 
					and Client.IsActive = 1
					and Client.IsFliq =1
		WHERE
			(@ClientID IS NULL OR Client.ClientKey = @ClientID)

		order by fliQ_Customer.FirstName,fliQ_Customer.LastName
	END
END