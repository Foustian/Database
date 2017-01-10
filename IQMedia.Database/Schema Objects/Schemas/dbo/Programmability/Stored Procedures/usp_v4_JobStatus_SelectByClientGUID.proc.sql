CREATE PROCEDURE [dbo].[usp_v4_JobStatus_SelectByClientGUID]
	@ClientGuid	UNIQUEIDENTIFIER,
	@PageNumner	INT,
	@PageSize	INT,
	@IsAsc BIT,
	@SortColumn VARCHAR(20),
	@JobTypeID	INT,
	@TotalResults INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRow INT, @EndRow INT

	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize
	PRINT @StartRow
	PRINT @EndRow

	SELECT 
			@TotalResults = COUNT(*)
	FROM 
			IQJob_Master
				INNER JOIN IQJob_Type
					ON IQJob_Master._TypeID = IQJob_Type.ID
					AND IQJob_Type.IsActive = 1
				INNER JOIN Customer 
					ON 	IQJob_Master._CustomerGuid = Customer.CustomerGUID
					AND Customer.IsActive = 1
				INNER JOIN Client 
					ON Customer.ClientID = Client.ClientKey
					AND Client.IsActive = 1
					AND Client.ClientGuid = @ClientGuid
	WHERE @JobTypeID IS NULL OR IQJob_Master._TypeID = @JobTypeID

	;WITH tempJobStatus AS(
		SELECT
				CASE
					WHEN @SortColumn = 'RequestedDateTime' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY IQJob_Master._RequestedDateTime ASC)
					WHEN @SortColumn = 'RequestedDateTime' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY IQJob_Master._RequestedDateTime DESC)
					WHEN @SortColumn = 'CompletedDateTime' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY IQJob_Master._CompletedDateTime ASC)
					WHEN @SortColumn = 'CompletedDateTime' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY IQJob_Master._CompletedDateTime DESC)
					WHEN @SortColumn = 'RequestedBy' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER BY Customer.FirstName + ' ' + Customer.LastName ASC)
					WHEN @SortColumn = 'RequestedBy' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER BY Customer.FirstName + ' ' + Customer.LastName DESC)
					ELSE ROW_NUMBER() OVER (ORDER BY IQJob_Master._RequestedDateTime DESC)
				END AS RowNum,
				IQJob_Master.ID,
				IQJob_Master._RequestID as RequestID,
				IQJob_Master._Title,
				IQJob_Master._DownloadPath,
				IQJob_Master.[Status],
				dbo.fnGetClipAdjustedDateTime(IQJob_Master._RequestedDateTime, gmt + 5, dst - 1, null) as _RequestedDateTime, -- Time is stored in EST
				dbo.fnGetClipAdjustedDateTime(IQJob_Master._CompletedDateTime, gmt + 5, dst - 1, null) as _CompletedDateTime, -- Time is stored in EST
				IQJob_Type.ID AS JobTypeID,
				IQJob_Type.Name,
				IQJob_Type.[Description],
				IQJob_Type.IsActive,
				IQJob_Type.CanReset,
				IQJob_Type.ResetProcedureName,
				Customer.FirstName,
				Customer.LastName
		FROM 
				IQJob_Master
				INNER JOIN IQJob_Type
					ON IQJob_Master._TypeID = IQJob_Type.ID
					AND IQJob_Type.IsActive = 1
				INNER JOIN Customer 
					ON 	IQJob_Master._CustomerGUID = Customer.CustomerGUID
					AND Customer.IsActive = 1
				INNER JOIN Client 
					ON Customer.ClientID = Client.ClientKey
					AND Client.IsActive = 1
					AND Client.ClientGuid = @ClientGuid
		WHERE @JobTypeID IS NULL OR IQJob_Master._TypeID = @JobTypeID
	)
	
	SELECT 
			ID,
			RequestID,
			Name,
			_Title,
			[Description],
			_DownloadPath,
			[Status],
			_RequestedDateTime,
			_CompletedDateTime,
			JobTypeID,
			FirstName,
			LastName,
			IsActive,
			CanReset,
			ResetProcedureName
	FROM
			tempJobStatus
	WHERE
			RowNum >= @StartRow AND RowNum <= @EndRow
	ORDER BY RowNum

END