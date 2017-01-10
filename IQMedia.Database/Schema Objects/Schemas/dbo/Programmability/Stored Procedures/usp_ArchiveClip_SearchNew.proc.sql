-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- DECLARE @Total int; exec usp_ArchiveClip_SearchNew '7722A116-C3BC-40AE-8070-8C59EE9E3D2A',0,10,'ClipCreationDate',0,'test title','test title','test title','test title',NULL,NULL,NULL,NULL,NULL,NULL,'','','',NULL,1,@Total output
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveClip_SearchNew]
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
	@ClipDateFrom		date,
	@ClipDateTo 		date,
	@CategoryGUID1		uniqueidentifier,
	@CategoryGUID2		uniqueidentifier,
	@CategoryGUID3		uniqueidentifier,
	@CategoryGUID4		uniqueidentifier,
	@CategoryOperator1	VARCHAR(5),
	@CategoryOperator2	VARCHAR(5),
	@CategoryOperator3	VARCHAR(5),
	@CustomerGUID		varchar(MAX),
	@IsNielSen			bit,
	@TotalRecordsClipCount	int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
    
    DECLARE @Query NVARCHAR(MAX)

	DECLARE @MultiPlier float
	
	select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGUID),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))
	
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
    
		ArchiveClip.ArchiveClipKey,
		ArchiveClip.ClipID,
		ArchiveClip.ClipLogo,
		ArchiveClip.ClipTitle,
		ArchiveClip.ClipDate,
		ISNULL(ArchiveClip.FirstName,'''') + '' ''  + ISNULL(ArchiveClip.LastName,'''') as FirstName,
		ArchiveClip.ClipCreationDate,'
	IF(@IsNielSen = 1)
	BEGIN	
		SET @Query = @Query + 	' 
		Substring(ArchiveClip.IQ_CC_KEY, Charindex(''_'', ArchiveClip.IQ_CC_KEY)+10, LEN(ArchiveClip.IQ_CC_KEY)) as IQ_CC_KEY_Time ,
		ArchiveClip.IQ_CC_KEY,
		Dma_Num,
		Universe,
		SQADMARKETID,
		Station_Affil,
		TimeZone,
		IQ_Station_ID,'
	END
	SET @Query = @Query + '
		STUFF((SELECT '','' + CategoryName FROM CustomCategory Where CategoryGuid IN (ArchiveClip.CategoryGuid,SubCategory1Guid,SubCategory2Guid,SubCategory3Guid) FOR XML PATH('''')),1,1,'''') as CategoryName
	  FROM
			ArchiveClip'
			IF(@IsNielSen = 1)
			BEGIN	
				SET @Query = @Query + ' 
					LEFT OUTER JOIN IQ_Station 
					on LTRIM(RTRIM(Substring(ArchiveClip.IQ_CC_KEY,1,Charindex(''_'', ArchiveClip.IQ_CC_KEY)-1))) = IQ_Station.IQ_Station_ID'
			END
	SET @Query = @Query + '
	WHERE
			ArchiveClip.ClientGUID='''+CONVERT(varchar(40),@ClientGUID)+'''
			 AND ArchiveClip.IsActive = 1
			'
	if(isnull(@SearchTermTitle,'') <> '' or ISNULL(@SearchTermCC,'') <> '' or isnull(@SearchTermDesc,'') <> '' or isnull(@SearchTermKeyword,'') <> '')
	begin
		set @Query=@Query+' and ( ';
		declare @Query1 varchar(MAX)
		set @Query1=''
		if(isnull(@SearchTermTitle,'') <> '')
		begin
			set @Query1=@Query1+' lower(ArchiveClip.ClipTitle) like ''%'+lower(@SearchTermTitle)+'%''  '
		End
		
		if(isnull(@SearchTermDesc,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or lower(ArchiveClip.[Description]) like ''%'+lower(@SearchTermDesc)+'%''  '
			end
			else
			begin
				set @Query1=@Query1+' lower(ArchiveClip.[Description]) like ''%'+lower(@SearchTermDesc)+'%''  '
			end
		End
		
		if(isnull(@SearchTermKeyword,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or lower(ArchiveClip.Keywords) like ''%'+lower(@SearchTermKeyword)+'%'' '
			end
			else
			begin
				set @Query1=@Query1+' lower(ArchiveClip.Keywords) like ''%'+lower(@SearchTermKeyword)+'%'' '
			end
		End
		
		if(isnull(@SearchTermCC,'') <> '')
		begin
			if(@Query1 <> '')
			begin
				set @Query1=@Query1+' or ArchiveClip.ClosedCaption is null or lower(ArchiveClip.ClosedCaption.query(''tt/body/div/p'').value(''.'',''varchar(Max)'')) like ''%' + lower(@SearchTermCC) + '%'' '
			end
			else
			begin
				set @Query1=@Query1+' ArchiveClip.ClosedCaption is null or lower(ArchiveClip.ClosedCaption.query(''tt/body/div/p'').value(''.'',''varchar(Max)'')) like ''%' + lower(@SearchTermCC) + '%'' '
			end
		End
		
		
		
		set @Query=@Query+@Query1
		set @Query=@Query+' ) '
	end
	
	
	if(isnull(@ClipDateFrom,'') <>'' and isnull(@ClipDateTo,'') <>'')
	begin
		set @Query=@Query+' and (convert(date,ArchiveClip.ClipCreationDate) between '''+convert(varchar(10),@ClipDateFrom)+''' and  '''+convert(varchar(10),@ClipDateTo)+''') '
	end
			
	if(isnull(CONVERT(varchar(40),@CategoryGUID1),'') <>'')
	begin
		set @Query=@Query+' and (
			(ArchiveClip.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveClip.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveClip.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''' or 
			ArchiveClip.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID1) + ''') ';
			
		if(isnull(CONVERT(varchar(40),@CategoryGUID2),'') <>'')
		begin
			set @Query=@Query+' '+ @CategoryOperator1 +' 
			(ArchiveClip.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveClip.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveClip.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''' or 
			ArchiveClip.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID2) + ''') ';	
			
			if(isnull(CONVERT(varchar(40),@CategoryGUID3),'') <>'')
			begin
				set @Query=@Query+' '+ @CategoryOperator2 +' 
				(ArchiveClip.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveClip.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveClip.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''' or 
				ArchiveClip.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID3) + ''') ';	
				
				if(isnull(CONVERT(varchar(40),@CategoryGUID4),'') <>'')
				begin
					set @Query=@Query+' '+ @CategoryOperator3 +' 
					(ArchiveClip.CategoryGUID  = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveClip.SubCategory1GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveClip.SubCategory2GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''' or 
					ArchiveClip.SubCategory3GUID = ''' + CONVERT(varchar(40),@CategoryGUID4) + ''') ';	
				end
				
			end
		end
		
		set @Query=@Query+')';
		
	end
		
	
	if(isnull(@CustomerGUID,'') <>'')
	begin
		set @Query=@Query+' and ArchiveClip.CustomerGUID in ('+ @CustomerGUID + ')'
	end
		
	
	Declare @CountQuery nvarchar(MAX)
	SET @CountQuery = @Query + ') '
	SET @CountQuery = @CountQuery + 'SELECT @TotalRecordsClipCount = COUNT(ArchiveClipKey) FROM  TempIQCore_Recordfile'
	
	SET @Query = @Query + ') '
	
	IF(@IsNielSen = 1)
	BEGIN
		SET  @Query = @Query + 'SELECT 
				RowNumber,
				ArchiveClipKey,
				ClipID,
				ClipLogo,
				ClipTitle,
				ClipDate,
				FirstName,
				ClipCreationDate,		
				CategoryName,
				CASE
					WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
						Convert(varchar,CONVERT(DECIMAL,Avg_Ratings_Pt * 100* '+ CONVERT(Varchar(10), @MultiPlier) +' *(Convert(Decimal,(EndOffset - StartOffset + 1))/30) * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = tbl.SQADMARKETID AND IQ_SQAD.DAYPARTID = tblavg.DAYPARTID))) + ''(E)''
					ELSE
						Convert(varchar,CONVERT(DECIMAL, SQAD_SHAREVALUE * '+ CONVERT(Varchar(10),@MultiPlier) +' *(Convert(Decimal,(EndOffset - StartOffset + 1))/30))) + ''(A)''
					END
					as SQAD_SHAREVALUE,
				CASE
					WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
						Convert(varchar,CAST((Avg_Ratings_Pt) * (tbl.UNIVERSE) AS DECIMAL))
					ELSE
						AUDIENCE
					END
				  as AUDIENCE 
			FROM 
					TempIQCore_Recordfile tbl
						Inner join IQCore_Clip 
							on tbl.ClipID = IQCore_Clip.Guid 
							AND RowNumber between ' + CAST(@StartRowNo as VARCHAR) + ' AND ' + CAST(@EndRowNo as VARCHAR) + ' 
						LEFT OUTER JOIN IQ_Nielsen_Averages tblavg ON
							tblavg.IQ_Start_Point = CASE WHEN StartOffset = 0 THEN 1 ELSE CEILING(StartOffset /900.0) END  
							AND Affil_IQ_CC_Key =  CASE WHEN Dma_Num =''000'' THEN tbl.IQ_Station_ID ELSE tbl.Station_Affil + ''_'' + TimeZone END  + ''_'' + SUBSTRING(tbl.IQ_CC_Key,CHARINDEX(''_'',tbl.IQ_CC_Key) +1,13)
							AND RowNumber between ' + CAST(@StartRowNo as VARCHAR) + ' AND ' + CAST(@EndRowNo as VARCHAR) + ' 
						LEFT OUTER JOIN [IQ_NIELSEN_SQAD] s1 
						ON
						Tbl.IQ_CC_Key =  s1.IQ_CC_KEY 
						AND s1.IQ_Start_Point = CASE WHEN StartOffset = 0 THEN 1 ELSE CEILING(StartOffset /900.0) END
						AND RowNumber between ' + CAST(@StartRowNo as VARCHAR) + ' AND ' + CAST(@EndRowNo as VARCHAR) + ' 
					ORDER BY RowNumber' 
	END
	ELSE
	BEGIN
		SET  @Query = @Query + ' SELECT * FROM TempIQCore_Recordfile '
		SET @Query = @Query + 'Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	END
	
	print @Query 
	
	EXEC sp_executesql @Query
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalRecordsClipCount INT OUTPUT', 
        @TotalRecordsClipCount = @TotalRecordsClipCount OUTPUT 
	
	

END
