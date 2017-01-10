-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgentResults_SelectByQueryNameNew]
	-- Add the parameters for the stored procedure here
	@SearchRequestID	bigint,
	@PageNumber			Int,
	@PageSize			Int,
	@SortField			Varchar(250),
	@IsAscSortDirection		bit,
	@SearchTerm			Varchar(max)	Output
	
AS
BEGIN	
	SET NOCOUNT ON;

    Declare @TotalRecordsCount	bigint,
			@StartRowNo			bigint,
			@EndRowNo			bigint,
			@Query				nvarchar(Max)
    
    Select
			@TotalRecordsCount=COUNT(*)
	From
			IQAgent_TVResults
	Where
			IQAgent_TVResults.SearchRequestID=@SearchRequestID and
			IQAgent_TVResults.IsActive=1
			
    SET		@StartRowNo = (@PageNumber * @PageSize) + 1
	SET		@EndRowNo   = (@PageNumber * @PageSize) + @PageSize
	
	if (@EndRowNo>@TotalRecordsCount)
		begin
		
				Set	@EndRowNo=@TotalRecordsCount
		
		end
		
	SET @Query = ' WITH IQAgentResults_CTE  '
	SET @Query = @Query + ' AS ( '
					 
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
						
	IF (@SortField IS NOT NULL OR @SortField != '')
	BEGIN
							
			IF (@SortField = 'DateTime')
					BEGIN
							SET @Query = @Query + ' CONVERT(datetime,CONVERT(varchar(Max),IQAgent_TVResults.Rl_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),IQAgent_TVResults.RL_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') '
					END
			ELSE
					BEGIN
							set @Query = @Query + @SortField	
					END
						
			IF (@IsAscSortDirection = 0)
							BEGIN
										SET @Query = @Query + ' DESC '
							END
	END
	ELSE
			BEGIN
					SET @Query = @Query + 'RL_Market'
			END
							
						
			SET @Query = @Query + 	') as RowNumber,IQAgent_TVResults.* From IQAgent_TVResults Where IQAgent_TVResults.SearchRequestID='+@SearchRequestID+' and IQAgent_TVResults.IsActive=1'
			SET @Query=@Query + ')'
			
			SET  @Query = @Query + ' SELECT * FROM IQAgentResults_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
						
			EXEC SP_EXECUTESQL @Query
    
    SELECT
			@SearchTerm=CONVERT(varchar(max),SearchTerm)
	FROM
			IQAgent_SearchRequest	
	WHERE 
			ID = @SearchRequestID and 
			dbo.IQAgent_SearchRequest.IsActive=1
    
END
