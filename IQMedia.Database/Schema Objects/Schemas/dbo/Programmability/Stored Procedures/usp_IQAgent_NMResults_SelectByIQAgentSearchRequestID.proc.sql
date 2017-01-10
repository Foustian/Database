CREATE PROCEDURE [dbo].[usp_IQAgent_NMResults_SelectByIQAgentSearchRequestID]
	@SearchRequestID		bigint,
	@PageNo					int,
	@PageSize				int	,
	@SortField				varchar(50),
	@IsAscending			bit,
	@TotalRecordsCount		int output
AS
BEGIN
	Declare @Query nvarchar(MAX)
	DECLARE @StartRow AS INT,@EndRow AS INT
	
	SET @StartRow = (@PageNo * @PageSize) + 1
	SET @EndRow = (@PageNo * @PageSize) + @PageSize

	SET @Query = ' WITH Temp_IQAgent_NMResults  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL AND @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' IQAgent_NMResults.harvest_time'
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
    
    SET @Query = @Query + 	') as RowNumber,
				IQAgent_NMResults.ID,
				IQAgent_NMResults.ArticleID,
				IQAgent_NMResults.Publication,
				IQAgent_NMResults.[Title],
				IQAgent_NMResults.Category,
				IQAgent_NMResults.Genre,
				IQAgent_NMResults.harvest_time,
				IQAgent_NMResults.Url
		FROM
				IQAgent_NMResults
		Where	
				IQAgent_NMResults.IQAgentSearchRequestID = '+ CAST(@SearchRequestID as VARCHAR) +'
				AND IQAgent_NMResults.IsActive = 1)'

	Declare @CountQuery nvarchar(MAX)
	SET @CountQuery = @Query + 'SELECT @TotalRecordsCount = COUNT(ID) FROM  Temp_IQAgent_NMResults'
	
	SET  @Query = @Query + ' SELECT * FROM Temp_IQAgent_NMResults '
	SET @Query = @Query + 'Where RowNumber >=' + CAST(@StartRow as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRow as VARCHAR)

	print @Query
		
	EXEC sp_executesql @Query
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalRecordsCount INT OUTPUT', 
        @TotalRecordsCount = @TotalRecordsCount OUTPUT 	
		
END