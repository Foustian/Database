CREATE PROCEDURE [dbo].[usp_v4_Client_SelectByCustomerAndMasterClient]
	@CustomerID varchar(300),
	@MCID INT,
	@ClientName varchar(500),
	@IsAsc bit
AS
BEGIN
	
	DECLARE @MasterCustomerID bigint

	SELECT
			@MasterCustomerID = CASE WHEN MasterCustomerID IS NULL THEN CustomerKey ELSE MasterCustomerID END
	FROM	
			Customer
	WHERE	
			Customer.CustomerKey = @CustomerID

	SELECT 
			CASE WHEN @IsAsc = 1 THEN 
				ROW_NUMBER() OVER ( order by ClientName asc)
			ELSE 
				ROW_NUMBER() OVER ( order by ClientName desc)
			END as RowNum,
			Client.ClientKey,
			Client.ClientName
	FROM 
			Client
				INNER JOIN Customer
				ON Client.ClientKey = Customer.ClientID
	WHERE
			Client.MCID = @MCID
			AND (Customer.MasterCustomerID = @MasterCustomerID OR Customer.CustomerKey = @MasterCustomerID)
			AND Customer.CustomerKey != @CustomerID	
			AND Customer.IsActive = 1 and Client.IsActive = 1
			AND (Client.AuthorizedVersion = 0 OR Client.AuthorizedVersion = 4)
			AND (@ClientName is null or ClientName like '%'+ @ClientName +'%')
	ORDER BY RowNum
			
END