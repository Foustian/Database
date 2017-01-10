
CREATE PROCEDURE [dbo].[usp_UGCRawMedia_Select]
(
	@ClientGUID			uniqueidentifier,
	@PageNumber			int,
	@PageSize			int,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@TotalRecordsCount	int output,
	@CategoryGUID		uniqueidentifier,
	@CustomerGUID		uniqueidentifier		
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
	
	SET @Query = ' WITH IQUGCArchive_CTE  '
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
	
            IQUGCArchive.UGCGUID,
			Title,
			Keywords,
			CreateDT,
			CategoryName,
			IQUGCArchive.CategoryGUID,
			FirstName,
			AirDate,
			IQUGCArchive.CustomerGUID
	From
			IQUGCArchive
				inner join CustomCategory
					on IQUGCArchive.CategoryGUID=CustomCategory.CategoryGUID
				inner join Customer
					on IQUGCArchive.CustomerGUID=Customer.CustomerGUID
      WHERE 
				IQUGCArchive.ClientGUID='''+CONVERT(varchar(40),@ClientGUID)+''' and
				IQUGCArchive.IsActive=1'
				
	if(@CategoryGUID is not null)
		begin
				set @Query=@Query+' and IQUGCArchive.CategoryGUID = '''+ CONVERT(varchar(36),@CategoryGUID)+''''
		end
	
	if(@CustomerGUID is not null)
		begin
				set @Query=@Query+' and IQUGCArchive.CustomerGUID = '''+ CONVERT(varchar(36),@CustomerGUID)+''''
		end

	SET @Query = @Query + ') '
	
	SET  @Query = @Query + ' SELECT * FROM IQUGCArchive_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)	
	
	print @Query
			
	EXEC SP_EXECUTESQL @Query
	
	
	Select	
			@TotalRecordsCount=COUNT([UGCGUID])
	FROM  
			IQUGCArchive				
    WHERE 
			[ClientGUID]= @ClientGUID and
			(@CategoryGUID is null or CategoryGUID=@CategoryGUID) and
			(@CustomerGUID is null or CustomerGUID=@CustomerGUID) and
			IsActive=1
	
	
END
