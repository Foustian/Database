-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveBLPM_Search]
	@ClientGUID uniqueidentifier,
	@PageNumber			int,
	@PageSize			int,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@SearchTermTitle	varchar(MAX),
	@SearchTermDesc		varchar(MAX),
	@SearchTermKeyword	varchar(MAX),
	@SearchTermCC		varchar(MAX),
	@DateFrom			date,
	@DateTo 			date,
	@CategoryGUID1		uniqueidentifier,
	@CategoryGUID2		uniqueidentifier,
	@CategoryGUID3		uniqueidentifier,
	@CategoryGUID4		uniqueidentifier,
	@CategoryOperator1	VARCHAR(5),
	@CategoryOperator2	VARCHAR(5),
	@CategoryOperator3	VARCHAR(5),	
	@TotalRecordsCount	int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  
  DECLARE @Query NVARCHAR(MAX)
	
	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
	
	SET @StartRowNo = (@PageNumber * @PageSize) + 1
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize
	
	SET @Query = ' WITH TempIQCore_Article  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL AND @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' ArchiveBLPM.CreatedDate'
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
    
    SET @Query = @Query + 	') as RowNumber,
    
		ArchiveBLPM.ArchiveBLPMKey,
		ArchiveBLPM.Pub_Name,
		ArchiveBLPM.BLID,
		ArchiveBLPM.Headline,
		ArchiveBLPM.Description,
		ArchiveBLPM.PubDate,
		ArchiveBLPM.CreatedDate,
		ArchiveBLPM.Keywords,
		ArchiveBLPM.Rating,
		ArchiveBLPM.Circulation,
		IQCore_RootPath.StoragePath + ArchiveBLPM.FileLocation as ''FileLocation'',
		IQCore_RootPath.StreamSuffixPath+ ArchiveBLPM.FileLocation as ''Url''
		
	FROM
			ArchiveBLPM
			INNER JOIN IQCore_RootPath
			ON ArchiveBLPM.RPID = IQCore_RootPath.ID
	WHERE
			ArchiveBLPM.ClientGuid='''+CONVERT(varchar(40),@ClientGUID)+'''
			 AND ArchiveBLPM.IsActive = 1
			'
	if(isnull(@SearchTermTitle,'') <> '' or ISNULL(@SearchTermCC,'') <> '' or isnull(@SearchTermDesc,'') <> '' or isnull(@SearchTermKeyword,'') <> '')
	begin
		set @Query=@Query+' and ( ';
		declare @Query1 varchar(MAX)
		set @Query1=''
		if(isnull(@SearchTermTitle,'') <> '')
		begin
			set @Query1=@Query1+' lower(ArchiveBLPM.Headline) like ''%'+lower(@SearchTermTitle)+'%''  '
		End
		
		if(isnull(@SearchTermDesc,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or lower(ArchiveBLPM.Description) like ''%'+lower(@SearchTermDesc)+'%''  '
			end
			else
			begin
				set @Query1=@Query1+' lower(ArchiveBLPM.Description) like ''%'+lower(@SearchTermDesc)+'%''  '
			end
		End
		
		if(isnull(@SearchTermKeyword,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or lower(ArchiveBLPM.Keywords) like ''%'+lower(@SearchTermKeyword)+'%'' '
			end
			else
			begin
				set @Query1=@Query1+' lower(ArchiveBLPM.Keywords) like ''%'+lower(@SearchTermKeyword)+'%'' '
			end
		End
		
		if(isnull(@SearchTermCC,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or ArchiveBLPM.Text like ''%' + lower(@SearchTermCC) + '%'' '
			end
			else
			begin
				set @Query1=@Query1+' ArchiveBLPM.Text like ''%' + lower(@SearchTermCC) + '%'' '
			end
		End
		
		
		
		set @Query=@Query+@Query1
		set @Query=@Query+' ) '
	end
	
	
	if(isnull(@DateFrom,'') <>'' and isnull(@DateTo,'') <>'')
	begin
		set @Query=@Query+' and (convert(date,ArchiveBLPM.CreatedDate) between '''+convert(varchar(10),@DateFrom)+''' and  '''+convert(varchar(10),@DateTo)+''') '
	end
			
	if(isnull(CONVERT(varchar(40),@CategoryGUID1),'') <>'')
	begin
		set @Query=@Query+' and (
			(ArchiveBLPM.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveBLPM.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveBLPM.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveBLPM.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''') ';
			
		if(isnull(CONVERT(varchar(40),@CategoryGUID2),'') <>'')
		begin
			set @Query=@Query+' '+ @CategoryOperator1 +' 
			(ArchiveBLPM.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveBLPM.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveBLPM.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveBLPM.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''') ';	
			
			if(isnull(CONVERT(varchar(40),@CategoryGUID3),'') <>'')
			begin
				set @Query=@Query+' '+ @CategoryOperator2 +' 
				(ArchiveBLPM.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveBLPM.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveBLPM.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveBLPM.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''') ';	
				
				if(isnull(CONVERT(varchar(40),@CategoryGUID4),'') <>'')
				begin
					set @Query=@Query+' '+ @CategoryOperator3 +' 
					(ArchiveBLPM.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveBLPM.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveBLPM.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveBLPM.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''') ';	
				end
				
			end
		end
		
		set @Query=@Query+')';
		
	end
		
	
	Declare @CountQuery nvarchar(MAX)
	SET @CountQuery = @Query + ') '
	SET @CountQuery = @CountQuery + 'SELECT @TotalRecordsCount = COUNT(ArchiveBLPMKey) FROM  TempIQCore_Article'
	
	SET @Query = @Query + ') '
	
	
	SET  @Query = @Query + ' SELECT * FROM TempIQCore_Article '
	SET @Query = @Query + 'Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	
	
	print @Query 
	
	EXEC sp_executesql @Query
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalRecordsCount INT OUTPUT', 
        @TotalRecordsCount = @TotalRecordsCount OUTPUT 
  
  
END
