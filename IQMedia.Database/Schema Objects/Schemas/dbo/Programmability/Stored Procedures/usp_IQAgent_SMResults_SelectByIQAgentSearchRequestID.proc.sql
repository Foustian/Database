CREATE PROCEDURE [dbo].[usp_IQAgent_SMResults_SelectByIQAgentSearchRequestID]
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

	SET @Query = ' WITH Temp_IQAgent_SMResults  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL AND @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' IQAgent_SMResults.itemHarvestDate_DT'
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
    
    SET @Query = @Query + 	') as RowNumber,
				IQAgent_SMResults.ID,
				IQAgent_SMResults.SeqID,
				IQAgent_SMResults.homelink,
				IQAgent_SMResults.[description],
				IQAgent_SMResults.feedCategories,
				IQAgent_SMResults.feedClass,
				IQAgent_SMResults.feedRank,
				IQAgent_SMResults.itemHarvestDate_DT,
				IQAgent_SMResults.link
		FROM
				IQAgent_SMResults
		Where	
				IQAgent_SMResults.IQAgentSearchRequestID = '+ CAST(@SearchRequestID as VARCHAR) +'
				AND IQAgent_SMResults.IsActive = 1)'

	Declare @CountQuery nvarchar(MAX)
	SET @CountQuery = @Query + 'SELECT @TotalRecordsCount = COUNT(ID) FROM  Temp_IQAgent_SMResults'

	SET  @Query = @Query + ' SELECT * FROM Temp_IQAgent_SMResults '
	SET @Query = @Query + 'Where RowNumber >=' + CAST(@StartRow as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRow as VARCHAR)

				
	print @Query
	EXEC sp_executesql @Query
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalRecordsCount INT OUTPUT', 
        @TotalRecordsCount = @TotalRecordsCount OUTPUT 	
		
END