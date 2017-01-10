CREATE PROCEDURE [dbo].[usp_UGCRawMedia_Search]
(
	@ClientGUID			uniqueidentifier,
	@CategoryGUID		varchar(MAX),
	@CustomerGUID		varchar(MAX),
	@SearchTermTitle	varchar(MAX),
	@SearchTermDesc		varchar(MAX),
	@SearchTermKeyword	varchar(MAX),
	@UGCDateFrom		date,
	@UGCDateTo 			date,
	@PageNumber			int,
	@PageSize			int,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@TotalRecordsCount	int output,
	@ErrorNumber		int output
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
	DECLARE @Query NVARCHAR(MAX),@SearchTerm nvarchar(MAX)
	
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
				
	
	if(isnull(@SearchTermTitle,'') <> '' or isnull(@SearchTermDesc,'') <> '' or isnull(@SearchTermKeyword,'') <> '')
	begin
		set @Query=@Query+' and Contains(( ';
		declare @Query1 varchar(MAX)
		set @Query1=''
		if(isnull(@SearchTermTitle,'') <> '')
		begin
			set @Query1=@Query1+' IQUGCArchive.Title'
			set @SearchTerm = @SearchTermTitle
		End
		
		if(isnull(@SearchTermDesc,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+',IQUGCArchive.[Description]'
			end
			else
			begin
				set @Query1=@Query1+'IQUGCArchive.[Description]'
			end
			set @SearchTerm = @SearchTermDesc
		End
		
		if(isnull(@SearchTermKeyword,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+',IQUGCArchive.Keywords'
			end
			else
			begin
				set @Query1=@Query1+'IQUGCArchive.Keywords'
			end
			set @SearchTerm = @SearchTermKeyword
		End
		
		
		
	
		set @Query1=@Query1+' ),'''+ @SearchTerm +''') '
		set @Query=@Query+@Query1
		
	end
	
	if(isnull(@UGCDateFrom,'') <>'' and isnull(@UGCDateTo,'') <>'')
	begin
		set @Query=@Query+' and (convert(date,IQUGCArchive.CreateDT) between '''+convert(varchar(10),@UGCDateFrom)+''' and  '''+convert(varchar(10),@UGCDateTo)+''') '
	end
				
	if(isnull(@CategoryGUID,'') <> '')
		begin
				set @Query=@Query+' and IQUGCArchive.CategoryGUID in ('+ @CategoryGUID + ')';
		end
	
	if(isnull(@CustomerGUID,'') <> '')
		begin
				set @Query=@Query+' and IQUGCArchive.CustomerGUID in ('+ @CustomerGUID + ')';
		end

	
	Declare @CountQuery nvarchar(MAX)
	SET @CountQuery = @Query + ') '
	SET @CountQuery = @CountQuery + 'SELECT @TotalRecordsCount = COUNT(RowNumber) FROM  UGCRawMediaSearch'
	
	
	
	SET @Query = @Query + ') '
	SET  @Query = @Query + ' SELECT * FROM UGCRawMediaSearch Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	
	
	
	print @Query
	print @CountQuery
			
	EXEC sp_executesql @Query
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalRecordsCount INT OUTPUT', 
        @TotalRecordsCount = @TotalRecordsCount OUTPUT 
	select @ErrorNumber = -1
END TRY
BEGIN CATCH
	SELECT @ErrorNumber = ERROR_NUMBER();
END CATCH;

END
