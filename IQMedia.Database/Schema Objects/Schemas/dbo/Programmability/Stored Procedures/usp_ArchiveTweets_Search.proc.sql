-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- DECLARE @Total int; exec usp_ArchiveTweets_Search '7722A116-C3BC-40AE-8070-8C59EE9E3D2A',0,10,'Tweet_PostedDateTime',0,'radio','radio','radio','radio',NULL,NULL,NULL,NULL,NULL,NULL,'','','',NULL,@Total output
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveTweets_Search]
	-- Add the parameters for the stored procedure here
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
	@CustomerGUID		varchar(MAX),
	@TotalRecordsCount	int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
    
    DECLARE @Query NVARCHAR(MAX)
	
	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
	
	SET @StartRowNo = (@PageNumber * @PageSize) + 1
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize
	
	SET @Query = ' WITH TempArchiveTweets  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL AND @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' ArchiveTweets.Tweet_PostedDateTime'
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
    
    SET @Query = @Query + 	') as RowNumber,
		
		ArchiveTweets.Title,
		ArchiveTweets.Keywords,
		ArchiveTweets.Actor_link,
		ArchiveTweets.Actor_DisplayName,
		ArchiveTweets.ArchiveTweets_Key,
		ArchiveTweets.Actor_FollowersCount,
		ArchiveTweets.Actor_FriendsCount,
		ArchiveTweets.Tweet_Body,
		ArchiveTweets.Actor_Image,
		ArchiveTweets.Tweet_PostedDateTime,
		ArchiveTweets.gnip_Klout_Score,
		''@'' + ArchiveTweets.Actor_PreferredUserName as ''Actor_PreferredUserName''
			
	FROM
			ArchiveTweets
	WHERE
			ArchiveTweets.ClientGuid='''+CONVERT(varchar(40),@ClientGUID)+'''
			 AND ArchiveTweets.IsActive = 1
			'
	if(isnull(@SearchTermTitle,'') <> '' or ISNULL(@SearchTermCC,'') <> '' or isnull(@SearchTermDesc,'') <> '' or isnull(@SearchTermKeyword,'') <> '')
	begin
		set @Query=@Query+' and ( ';
		declare @Query1 varchar(MAX)
		set @Query1=''
		if(isnull(@SearchTermTitle,'') <> '')
		begin
			set @Query1=@Query1+' lower(ArchiveTweets.Title) like ''%'+lower(@SearchTermTitle)+'%''  '
		End
		
		if(isnull(@SearchTermDesc,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or lower(ArchiveTweets.[Description]) like ''%'+lower(@SearchTermDesc)+'%''  '
			end
			else
			begin
				set @Query1=@Query1+' lower(ArchiveTweets.[Description]) like ''%'+lower(@SearchTermDesc)+'%''  '
			end
		End
		
		if(isnull(@SearchTermKeyword,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or lower(ArchiveTweets.Keywords) like ''%'+lower(@SearchTermKeyword)+'%'' '
			end
			else
			begin
				set @Query1=@Query1+' lower(ArchiveTweets.Keywords) like ''%'+lower(@SearchTermKeyword)+'%'' '
			end
		End
		
		if(isnull(@SearchTermCC,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or ArchiveTweets.Tweet_Body like ''%' + lower(@SearchTermCC) + '%'' '
			end
			else
			begin
				set @Query1=@Query1+' ArchiveTweets.Tweet_Body like ''%' + lower(@SearchTermCC) + '%'' '
			end
		End
		
		
		
		set @Query=@Query+@Query1
		set @Query=@Query+' ) '
	end
	
	
	if(isnull(@DateFrom,'') <>'' and isnull(@DateTo,'') <>'')
	begin
		set @Query=@Query+' and (convert(date,ArchiveTweets.Tweet_PostedDateTime) between '''+convert(varchar(10),@DateFrom)+''' and  '''+convert(varchar(10),@DateTo)+''') '
	end
			
	if(isnull(CONVERT(varchar(40),@CategoryGUID1),'') <>'')
	begin
		set @Query=@Query+' and (
			(ArchiveTweets.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveTweets.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveTweets.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveTweets.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''') ';
			
		if(isnull(CONVERT(varchar(40),@CategoryGUID2),'') <>'')
		begin
			set @Query=@Query+' '+ @CategoryOperator1 +' 
			(ArchiveTweets.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveTweets.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveTweets.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveTweets.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''') ';	
			
			if(isnull(CONVERT(varchar(40),@CategoryGUID3),'') <>'')
			begin
				set @Query=@Query+' '+ @CategoryOperator2 +' 
				(ArchiveTweets.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveTweets.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveTweets.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveTweets.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''') ';	
				
				if(isnull(CONVERT(varchar(40),@CategoryGUID4),'') <>'')
				begin
					set @Query=@Query+' '+ @CategoryOperator3 +' 
					(ArchiveTweets.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveTweets.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveTweets.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveTweets.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''') ';	
				end
				
			end
		end
		
		set @Query=@Query+')';
		
	end
		
	
	if(isnull(@CustomerGUID,'') <>'')
	begin
		set @Query=@Query+' and ArchiveTweets.CustomerGUID in ('+ @CustomerGUID + ')'
	end
		
	
	Declare @CountQuery nvarchar(MAX)
	SET @CountQuery = @Query + ') '
	SET @CountQuery = @CountQuery + 'SELECT @TotalRecordsCount = COUNT(ArchiveTweets_Key) FROM  TempArchiveTweets'
	
	SET @Query = @Query + ') '
	
	
	SET  @Query = @Query + ' SELECT * FROM TempArchiveTweets '
	SET @Query = @Query + 'Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	
	
	print @Query 
	
	EXEC sp_executesql @Query
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalRecordsCount INT OUTPUT', 
        @TotalRecordsCount = @TotalRecordsCount OUTPUT 
	
	

END
