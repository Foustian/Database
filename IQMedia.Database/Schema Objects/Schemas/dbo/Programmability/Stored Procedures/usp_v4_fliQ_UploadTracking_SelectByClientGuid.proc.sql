CREATE PROCEDURE [dbo].[usp_v4_fliQ_UploadTracking_SelectByClientGuid]
	@ClientGuid uniqueidentifier,
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
			fliQ_UploadTracking
				INNER JOIN Fliq_Customer 
					on fliQ_UploadTracking._FliqCustomerGuid = Fliq_Customer.CustomerGuid
					and Fliq_Customer.IsActive = 1
				INNER JOIN Fliq_Application
					on Fliq_Application.ID = fliQ_UploadTracking._FliqApplicationID
					and Fliq_Application.IsActive = 1
				INNER JOIN Fliq_CustomerApplication 
					on Fliq_Customer.CustomerGuid = Fliq_CustomerApplication._FliqCustomerGuid
					and Fliq_CustomerApplication._FliqApplicationID = Fliq_Application.ID
					and Fliq_CustomerApplication.IsActive = 1
				INNER JOIN Client
					on Fliq_Customer.ClientID = Client.ClientKey
					and Client.IsActive = 1
				INNER JOIN CustomCategory
					on Client.ClientGuid = CustomCategory.ClientGuid
					and fliQ_UploadTracking._CategoryGuid = CustomCategory.CategoryGuid
	WHERE
			Client.ClientGuid =@ClientGuid
			and fliQ_UploadTracking.IsActive = 1	
	
	;With tempFliqUpload AS(
		SELECT
				CASE
					WHEN @SortColumn = 'Date' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By UploadedDateTime ASC)
					WHEN @SortColumn = 'Date' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By UploadedDateTime DESC)
					WHEN @SortColumn = 'CustomerName' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By Fliq_Customer.FirstName + ' ' + Fliq_Customer.LastName ASC)
					WHEN @SortColumn = 'CustomerName' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By Fliq_Customer.FirstName + ' ' + Fliq_Customer.LastName DESC)
					ELSE ROW_NUMBER() OVER(ORDER By UploadedDateTime DESC)
				END as RowNum,
				Fliq_Customer.FirstName,
				Fliq_Customer.LastName,
				UploadedDateTime,
				[Status],
				Tags,
				CategoryName
		FROM 
			fliQ_UploadTracking
				INNER JOIN Fliq_Customer 
					on fliQ_UploadTracking._FliqCustomerGuid = Fliq_Customer.CustomerGuid
					and Fliq_Customer.IsActive = 1
				INNER JOIN Fliq_Application
					on Fliq_Application.ID = fliQ_UploadTracking._FliqApplicationID
					and Fliq_Application.IsActive = 1
				INNER JOIN Fliq_CustomerApplication 
					on Fliq_Customer.CustomerGuid = Fliq_CustomerApplication._FliqCustomerGuid
					and Fliq_CustomerApplication._FliqApplicationID = Fliq_Application.ID
					and Fliq_CustomerApplication.IsActive = 1
				INNER JOIN Client
					on Fliq_Customer.ClientID = Client.ClientKey
					and Client.IsActive = 1
				INNER JOIN CustomCategory
					on Client.ClientGuid = CustomCategory.ClientGuid
					and fliQ_UploadTracking._CategoryGuid = CustomCategory.CategoryGuid
		WHERE
				Client.ClientGuid =@ClientGuid
				and fliQ_UploadTracking.IsActive = 1	
	)

	SELECT 
			FirstName,
			LastName,
			UploadedDateTime,
			[Status],
			Tags,
			CategoryName
	FROM
			tempFliqUpload
	WHERE
			RowNum >= @StartRow AND RowNum <= @EndRow
	order by 
			RowNum

	
		
	
END