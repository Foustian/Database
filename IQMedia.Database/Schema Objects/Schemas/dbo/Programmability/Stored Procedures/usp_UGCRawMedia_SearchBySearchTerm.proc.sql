CREATE PROCEDURE [dbo].[usp_UGCRawMedia_SearchBySearchTerm]
(
	@ClientGUID			uniqueidentifier,
	@CategoryGUID		uniqueidentifier,
	@SearchTerm			varchar(Max),
	@PageNumber			int,
	@PageSize			int,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@TotalRecordsCount	int output
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query NVARCHAR(MAX)
	
	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
	
	SET @StartRowNo = (@PageNumber * @PageSize) + 1
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize
	
	SET @Query = ' WITH UGCRawMediaSearch  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL OR @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' CreateDT '
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
	
	
	SET @Query = @Query + 	') as RowNumber,
	
            Title,
            Keywords,
            CreateDT,
            AirDate,
            UGCGUID
      FROM  
			IQUGCArchive			
      WHERE 
				ClientGUID='''+CONVERT(varchar(40),@ClientGUID)+''' and 
				(
					Title like ''%'+@SearchTerm+'%'' or
					Keywords like ''%'+@SearchTerm+'%'' or
					 [Description] like ''%'+@SearchTerm+'%''
				) and
				IsActive=1'
				
	if(@CategoryGUID is not null)
		begin
				set @Query=@Query+' and CategoryGUID = '''+ CONVERT(varchar(36),@CategoryGUID)+''''
		end

	SET @Query = @Query + ') '
	
	SET  @Query = @Query + ' SELECT * FROM UGCRawMediaSearch Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	
	print @Query
	
			
 EXEC SP_EXECUTESQL @Query
 
	Select	
			@TotalRecordsCount=COUNT(UGCGUID)
	FROM  
			IQUGCArchive
				
      WHERE       
				ClientGUID = @ClientGUID and 
				(
					Title like '%'+@SearchTerm+'%' or
					Keywords like '%'+@SearchTerm+'%' or
					 [Description] like '%'+@SearchTerm+'%'
				) and
				(@CategoryGUID is null or CategoryGUID=@CategoryGUID)and
				(IsActive=1)
	


END
