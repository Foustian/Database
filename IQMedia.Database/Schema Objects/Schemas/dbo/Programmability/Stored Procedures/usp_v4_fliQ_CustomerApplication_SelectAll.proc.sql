CREATE PROCEDURE [dbo].[usp_v4_fliQ_CustomerApplication_SelectAll]
	@ClientName varchar(155),
	@CustomerName varchar(500),
	@PageNumner	int,
	@PageSize	int,
	@IsAsc bit,
	@SortColumn varchar(20),
	@TotalResults int output
AS
BEGIN

	DECLARE @StartRow int, @EndRow int

	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize

	SELECT 
			@TotalResults = COUNT(*)
	FROM 
			fliQ_CustomerApplication
				inner join fliQ_ClientApplication
					on fliQ_CustomerApplication._FliqApplicationID = fliQ_ClientApplication._FliqApplicationID
					and fliQ_ClientApplication.IsActive = 1
				inner join fliQ_Application 
					on 	fliQ_CustomerApplication._FliqApplicationID = fliQ_Application.ID
					and fliQ_CustomerApplication._FliqApplicationID = fliQ_Application.ID
					and fliQ_Application.IsActive = 1
				inner join Client 
					on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
					and Client.IsActive = 1
					and Client.IsFliq = 1
				inner join fliQ_Customer 
					on fliQ_CustomerApplication._FliqCustomerGUID = fliQ_Customer.CustomerGUID
					and fliQ_Customer.ClientID = Client.ClientKey
					and fliQ_Customer.IsActive = 1
	WHERE
			(@ClientName IS NULL OR Client.ClientName = @ClientName)
			and (@CustomerName IS NULL OR fliQ_Customer.FirstName + ' ' + fliQ_Customer.LastName like '%'+@CustomerName+'%')

	;With tempFliqCustomer AS(
		SELECT
				CASE
					WHEN @SortColumn = 'Application' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By fliQ_Application.[Application] ASC)
					WHEN @SortColumn = 'Application' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By fliQ_Application.[Application] DESC)
					WHEN @SortColumn = 'CustomerName' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By Fliq_Customer.FirstName + ' ' + Fliq_Customer.LastName ASC)
					WHEN @SortColumn = 'CustomerName' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By Fliq_Customer.FirstName + ' ' + Fliq_Customer.LastName DESC)
					ELSE ROW_NUMBER() OVER (ORDER BY fliQ_Application.[Application] asc)
				END as RowNum,
				fliQ_CustomerApplication.ID,
				fliQ_Application.[Application],
				fliQ_Customer.FirstName,
				fliQ_Customer.LastName,
				fliQ_CustomerApplication.IsActive
		FROM 
				fliQ_CustomerApplication
					inner join fliQ_ClientApplication
						on fliQ_CustomerApplication._FliqApplicationID = fliQ_ClientApplication._FliqApplicationID
						and fliQ_ClientApplication.IsActive = 1
					inner join fliQ_Application 
						on 	fliQ_CustomerApplication._FliqApplicationID = fliQ_Application.ID
						and fliQ_CustomerApplication._FliqApplicationID = fliQ_Application.ID
						and fliQ_Application.IsActive = 1
					inner join Client 
						on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
						and Client.IsActive = 1
						and Client.IsFliq = 1
					inner join fliQ_Customer 
						on fliQ_CustomerApplication._FliqCustomerGUID = fliQ_Customer.CustomerGUID
						and fliQ_Customer.ClientID = Client.ClientKey
						and fliQ_Customer.IsActive = 1
		WHERE
				(@ClientName IS NULL OR Client.ClientName = @ClientName)
				and (@CustomerName IS NULL OR fliQ_Customer.FirstName + ' ' + fliQ_Customer.LastName like '%'+@CustomerName+'%')
	)

	SELECT 
			ID,
			[Application],
			FirstName,
			LastName,
			IsActive
	FROM
			tempFliqCustomer
	WHERE
			RowNum >= @StartRow AND RowNum <= @EndRow
END