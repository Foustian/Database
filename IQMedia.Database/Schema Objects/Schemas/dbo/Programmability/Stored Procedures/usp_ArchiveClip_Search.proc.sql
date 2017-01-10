-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- DECLARE @Total int; exec usp_ArchiveClip_Search '7722A116-C3BC-40AE-8070-8C59EE9E3D2A',0,10,'ClipCreationDate',0,'radio','radio','radio','radio',NULL,NULL,NULL,NULL,NULL,true,@Total output
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveClip_Search]
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
	@CategoryGUID1		varchar(MAX),
	@CategoryGUID2		varchar(MAX),
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
		ArchiveClip.FirstName,
		ArchiveClip.ClipCreationDate,'
	IF(@IsNielSen = 1)
	BEGIN	
		SET @Query = @Query + 	' 
		LTRIM(RTRIM(Substring(ArchiveClip.IQ_CC_KEY,1,Charindex(''_'', ArchiveClip.IQ_CC_KEY)-1))) as IQ_CC_KEY_Source,
		Substring(ArchiveClip.IQ_CC_KEY, Charindex(''_'', ArchiveClip.IQ_CC_KEY)+10, LEN(ArchiveClip.IQ_CC_KEY)) as IQ_CC_KEY_Time ,
		ArchiveClip.IQ_CC_KEY,
		Dma_Num,'
	END
	SET @Query = @Query + '
		(SELECT CategoryName FROM CustomCategory Where CategoryGuid = ArchiveClip.CategoryGuid) as CategoryName
	  FROM
			ArchiveClip'
			IF(@IsNielSen = 1)
			BEGIN	
				SET @Query = @Query + ' 
					LEFT OUTER JOIN RL_STation 
					on LTRIM(RTRIM(Substring(ArchiveClip.IQ_CC_KEY,1,Charindex(''_'', ArchiveClip.IQ_CC_KEY)-1))) = RL_STation.RL_Station_ID'
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
			
	if(isnull(@CategoryGUID1,'') <>'')
	begin
		set @Query=@Query+' and ('
		set @Query=@Query+' ArchiveClip.CategoryGUID in ('+ @CategoryGUID1 + ') or ';
		set @Query=@Query+' ArchiveClip.SubCategory1GUID in ('+ @CategoryGUID1 + ') or ';
		set @Query=@Query+' ArchiveClip.SubCategory2GUID in ('+ @CategoryGUID1 + ') or ';
		set @Query=@Query+' ArchiveClip.SubCategory3GUID in ('+ @CategoryGUID1 + ')  ';
				set @Query=@Query+') ';
	end
		
	if(isnull(@CategoryGUID2,'') <>'')
	begin
		set @Query=@Query+' and ('
		set @Query=@Query+' ArchiveClip.CategoryGUID in ('+ @CategoryGUID2 + ') or ';
		set @Query=@Query+' ArchiveClip.SubCategory1GUID in ('+ @CategoryGUID2 + ') or ';
		set @Query=@Query+' ArchiveClip.SubCategory2GUID in ('+ @CategoryGUID2 + ') or ';
		set @Query=@Query+' ArchiveClip.SubCategory3GUID in ('+ @CategoryGUID2 + ')  ';
		set @Query=@Query+') ';
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
				REPLACE(Convert(varchar,CAST(CAST((SQAD_SHAREVALUE * (EndOffset - StartOffset + 1)/30) AS INT) as money),1),''.00'','''') + CASE WHEN msNeilSen.IQ_CC_KEY = orgIQ_CC_KEY THEN ''(A)'' ELSE ''(E)''  END as  SQAD_SHAREVALUE,
				REPLACE(Convert(varchar,CAST(AUDIENCE as money),1),''.00'','''') as AUDIENCE
		FROM 
			(SELECT 
							CASE WHEN CONVERT(DATE,SUBSTRING(Tbl.IQ_CC_Key,LEN(MAX(Tbl.IQ_CC_KEY_Source))+2,8)) >= CASE WHEN MAX(Dma_Num) = ''000'' THEN CONVERT(DATE,''2012-06-25'') ELSE CONVERT(DATE,''2012-05-31'') END  THEN
								MAX(s1.[IQ_CC_KEY])
							ELSE 
								MIN(s1.[IQ_CC_KEY])
							END as IQ_CC_KEy,
							Tbl.IQ_CC_KEY as orgIQ_CC_KEY,
							MAX(IQCore_Clip.StartOffset) as StartOffset,
							MAX(IQCore_Clip.EndOffset) as EndOffset,
							MAX(tbl.ArchiveClipKey) as ArchiveClipKey,
							tbl.ClipID,
							MAX(tbl.ClipLogo)  as ClipLogo,
							MAX(tbl.ClipTitle) as ClipTitle,
							MAX(tbl.ClipDate) as ClipDate,
							MAX(tbl.FirstName) as FirstName,
							MAX(tbl.ClipCreationDate) as ClipCreationDate,		
							MAX(tbl.CategoryName) as CategoryName,
							MAX(RowNumber) as RowNumber
			FROM 
					TempIQCore_Recordfile tbl
						LEFT OUTER JOIN IQCore_Clip 
							on tbl.ClipID = IQCore_Clip.Guid
						LEFT OUTER JOIN [IQ_NIELSEN_SQAD] s1 
						ON
						s1.IQ_CC_KEY like  IQ_CC_KEY_Source + ''[_]%[_]'' + IQ_CC_KEY_Time and 
						DATEPART(dw,SUBSTRING(s1.IQ_CC_Key,LEN(IQ_CC_KEY_Source)+2,8)) = DATEPART(dw,SUBSTRING(Tbl.IQ_CC_KEY,LEN(IQ_CC_KEY_Source)+2,8)) and
						(
						  (
							CONVERT(DATE,SUBSTRING(Tbl.IQ_CC_Key,LEN(IQ_CC_KEY_Source)+2,8)) < CASE WHEN Dma_Num = ''000'' THEN CONVERT(DATE,''2012-06-25'') ELSE CONVERT(DATE,''2012-05-31'') END  
						  ) 
						  OR
						  (
							CONVERT(DATE,SUBSTRING(s1.IQ_CC_Key,LEN(IQ_CC_KEY_Source)+2,8)) <= CONVERT(DATE,SUBSTRING(Tbl.IQ_CC_KEY,LEN(IQ_CC_KEY_Source)+2,8))  
								AND
							CONVERT(DATE,SUBSTRING(s1.IQ_CC_Key,LEN(IQ_CC_KEY_Source)+2,8)) >= CASE WHEN Dma_Num = ''000'' THEN CONVERT(DATE,''2012-06-25'') ELSE CONVERT(DATE,''2012-05-31'') END  
						   )
						)
					WHERE RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR) + ' 
					GROUP BY 
						tbl.IQ_CC_KEY,ClipID) chNeilSen
							LEFT OUTER JOIN IQ_NIELSEN_SQAD msNeilSen 
								on msNeilSen.IQ_CC_KEY = chNeilSen.IQ_CC_KEY
								AND msNeilSen.IQ_Start_Point = CASE WHEN StartOffset = 0 THEN 1 ELSE CEILING(StartOffset /900.0) END  
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

