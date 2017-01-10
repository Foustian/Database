CREATE PROCEDURE [dbo].[usp_v4_fliq_Customer_SelectAll]
(
		@ClientName varchar(100),
		@CustomerName varchar(500),
		@PageNumner	int,
		@PageSize	int,
		@TotalResults int output
	)
AS
BEGIN
	DECLARE @StartRow int, @EndRow int

	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize


	SELECT 
			@TotalResults = COUNT(*) 
	FROM 
			fliq_Customer Inner join Client 
				on fliq_Customer.ClientID = Client.ClientKey
	WHERE
		(@ClientName IS NULL OR Client.ClientName like '%'+@ClientName+'%')
		AND Client.IsActive = 1
		AND Client.IsFliq = 1

	;WITH tempCustomer AS(
	SELECT     
			ROW_NUMBER() OVER (ORDER BY FirstName Asc) as RowNum,
			CustomerKey,
			FirstName,
			LastName,
			Email,
			LoginID,
			ContactNo,
			CustomerPassword,
			CustomerComment,
			ClientID,
			fliq_Customer.IsActive
	FROM         			
			fliq_Customer Inner join Client 
				on fliq_Customer.ClientID = Client.ClientKey
	WHERE
		(@ClientName IS NULL OR Client.ClientName like '%'+@ClientName+'%')
		AND ( @CustomerName IS NULL OR 
				(
					fliQ_Customer.FirstName + ' ' + fliQ_Customer.LastName like '%'+@CustomerName+'%'
					OR fliQ_Customer.Email like '%'+@CustomerName+'%'
					OR fliQ_Customer.LoginID like '%'+@CustomerName+'%'
				)
			)
		AND Client.IsActive = 1
		AND Client.IsFliq = 1
		
)
	SELECT [CustomerKey],
		FirstName,
		LastName,
		Email,
		LoginID,
		ContactNo,
		CustomerPassword,
		CustomerComment,
		ClientID,
		IsActive
		
	FROM 
		tempCustomer 
	Where 
		RowNum >= @StartRow AND RowNum <= @EndRow

END