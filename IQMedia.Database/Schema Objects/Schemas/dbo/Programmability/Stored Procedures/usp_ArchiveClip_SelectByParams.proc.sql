CREATE PROCEDURE [dbo].[usp_ArchiveClip_SelectByParams]
	-- Add the parameters for the stored procedure here
	@ClientGUID uniqueidentifier,
	@PageNumber			int,
	@PageSize			int,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@Category			varchar(MAX),
	@SubCategory1		varchar(MAX),
	@SubCategory2		varchar(MAX),
	@SubCategory3		varchar(MAX),
	@CustomerGUID		varchar(MAX),
	@SearchTerm			varchar(MAX),
	@ClipTitle			varchar(MAX),
	@ClipID				uniqueidentifier output,
	@TotalRecordsClipCount	int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
    
    DECLARE @Query NVARCHAR(MAX)
    DECLARE @JoinQuery NVARCHAR(MAX)
    DECLARE @WhereQuery NVARCHAR(MAX)
	set @JoinQuery =''
	set @WhereQuery =''
	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
	
	SET @StartRowNo = (@PageNumber * @PageSize) + 1
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize
	
	SET @Query = ' WITH TempIQCore_Recordfile  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL AND @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' ArchiveClip.ClipCreationDate '
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
    
    SET @Query = @Query + 	') as RowNumber,
   
		ArchiveClip.ClipID,
		ArchiveClip.ClipTitle,
		ArchiveClip.Keywords,
		ArchiveClip.Description,
		ArchiveClip.ClipDate,
		ArchiveClip.ClipCreationDate,		
		ArchiveClip.ThumbnailImagePath
	FROM
			ArchiveClip
				INNER join CustomCategory
					on ArchiveClip.CategoryGUID=CustomCategory.CategoryGUID '
	
			
	if(isnull(@Category,'') <>'')
	begin
		set @WhereQuery=@WhereQuery+' and '
		set @WhereQuery=@WhereQuery+' lower(CustomCategory.CategoryName) in ('+ @Category + ')';
	end
	
	if(isnull(@SubCategory1,'') <>'')
	begin
		set @JoinQuery = @JoinQuery + ' inner join CustomCategory as SubCat1 on 
				ArchiveClip.SubCategory1GUID = SubCat1.CategoryGUID'
		set @WhereQuery=@WhereQuery +' and '
		set @WhereQuery=@WhereQuery +' lower(SubCat1.CategoryName) in ('+ @SubCategory1 + ')';
	end
	
	if(isnull(@SubCategory2,'') <>'')
	begin
		set @JoinQuery = @JoinQuery + ' inner join CustomCategory as SubCat2 on 
				ArchiveClip.SubCategory2GUID = SubCat2.CategoryGUID'
		set @WhereQuery=@WhereQuery+' and '
		set @WhereQuery=@WhereQuery+' lower(SubCat2.CategoryName) in ('+ @SubCategory2 + ')';
	end
	
	if(isnull(@SubCategory3,'') <>'')
	begin
		set @JoinQuery = @JoinQuery + ' inner join CustomCategory as SubCat3 on 
				ArchiveClip.SubCategory3GUID = SubCat3.CategoryGUID'
		set @WhereQuery=@WhereQuery+' and '
		set @WhereQuery=@WhereQuery+' lower(SubCat3.CategoryName) in ('+ @SubCategory3 + ')';
	end
	
	if(isnull(@CustomerGUID,'') <>'')
	begin
		set @WhereQuery=@WhereQuery+' and ArchiveClip.CustomerGUID in ('+ @CustomerGUID + ')'
	end
	
	if(ISNULL(@SearchTerm,'') <> '')
	begin
		set @WhereQuery = @WhereQuery+' and 
		(ArchiveClip.ClipTitle like ''%'+REPLACE(@SearchTerm,'''','''''')+'%'' OR 
		 ArchiveClip.[Description] like  ''%'+REPLACE(@SearchTerm,'''','''''')+'%'' OR
		 ArchiveClip.Keywords like  ''%'+REPLACE(@SearchTerm,'''','''''')+'%'' )'
	end
	
	set @Query = @Query + @JoinQuery 
	set @Query=@Query+' WHERE
			ArchiveClip.ClientGUID='''+CONVERT(varchar(40),@ClientGUID)+'''
			 AND ArchiveClip.IsActive = 1'
	set @Query = @Query + @WhereQuery
	
	Declare @ClipQuery NVARCHAR(max)
	
	SET @Query = @Query + ') '
	
	if(ISNULL(@ClipTitle,'') <> '')
	begin
		SET @ClipQuery = @Query + 'SELECT top 1 @ClipID = ClipID from TempIQCore_Recordfile Where ClipTitle ='''+CONVERT(varchar(40),@ClipTitle)+''''
	end
	
	
	Declare @CountQuery nvarchar(MAX)
	
	SET @CountQuery = @Query + 'SELECT @TotalRecordsClipCount = COUNT(ClipID) FROM  TempIQCore_Recordfile'
	
	SET  @Query = @Query + ' SELECT * FROM TempIQCore_Recordfile Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	
	
	
	
	EXEC sp_executesql @Query
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalRecordsClipCount INT OUTPUT', 
        @TotalRecordsClipCount = @TotalRecordsClipCount OUTPUT 
        
    if(@ClipQuery is not null)
    begin
		EXEC sp_executesql 
        @query = @ClipQuery, 
        @params = N'@ClipID uniqueidentifier OUTPUT', 
        @ClipID = @ClipID OUTPUT
    end
    else
    begin
		select @ClipID
    end
    
	print @Query 
	print @CountQuery
	print @ClipQuery
	

END