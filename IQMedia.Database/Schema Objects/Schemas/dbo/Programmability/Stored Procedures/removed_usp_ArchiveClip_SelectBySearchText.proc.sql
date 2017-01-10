-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[removed_usp_ArchiveClip_SelectBySearchText] 
	-- Add the parameters for the stored procedure here
	@SearchText varchar(100),
	@Category varchar(100),
	@ClientGUID uniqueidentifier,
	@PageNumber			int,
	@PageSize			int,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@TotalRecordsCount	int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--if @Category IS NULL or @Category=''
	IF @Category='0'
		BEGIN
		
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
				ArchiveClip.ClipDate,
				ArchiveClip.ClipLogo,
				ArchiveClip.ClipTitle,
				ArchiveClip.FirstName,
				ArchiveClip.ClipCreationDate,
				ArchiveClip.ClosedCaption,
				ArchiveClip.[Description],
				ArchiveClip.CustomerID,
				ArchiveClip.Category,
				CustomCategory.CategoryName
				
			FROM
				ArchiveClip
				
			Inner join Customer on Customer.CustomerGUID = ArchiveClip.CustomerGUID
			Inner join CustomCategory on ArchiveClip.CategoryGUID = CustomCategory.CategoryGUID 
			WHERE
				
				( ArchiveClip.[Description] like ''%'+@SearchText+'%''  
				 
					or ArchiveClip.ClipTitle like ''%'+@SearchText+'%''
					
					or ArchiveClip.ClosedCaption.query(''tt/body/div/p'').value(''.'',''varchar(Max)'') like ''%'+@SearchText+'%''		
				)
				
				
				--and ArchiveClip.Category = @Category
				
				 and ArchiveClip.IsActive = 1
				 
				 and ArchiveClip.ClientGUID = '''+CONVERT(varchar(40),@ClientGUID)+''''
				 
				 SET @Query = @Query + ') '
			
			SET  @Query = @Query + ' SELECT * FROM TempIQCore_Recordfile Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
			
			print @Query 
			
			EXEC SP_EXECUTESQL @Query
			
			Select	
					@TotalRecordsCount=COUNT(ArchiveClip.ArchiveClipKey)
			FROM  
				ArchiveClip
				
			Inner join Customer on Customer.CustomerGUID = ArchiveClip.CustomerGUID
			Inner join CustomCategory on ArchiveClip.CategoryGUID = CustomCategory.CategoryGUID 
				 WHERE
				
				( ArchiveClip.[Description] like '%' + @SearchText + '%'  
				 
					or ArchiveClip.ClipTitle like '%' + @SearchText + '%'
					
					or ArchiveClip.ClosedCaption.query('tt/body/div/p').value('.','varchar(Max)') like '%' + @SearchText + '%'		
				)
				
				
				--and ArchiveClip.Category = @Category
				
				 and ArchiveClip.IsActive = 1
				 
				 and ArchiveClip.ClientGUID = @ClientGUID
		 		END
	ELSE
		BEGIN
			 DECLARE @Query1 NVARCHAR(MAX)
	
	DECLARE @StartRowNo1 AS BIGINT,@EndRowNo1 AS BIGINT
	
	SET @StartRowNo1 = 1
	SET @EndRowNo1 = 1				
	
	SET @StartRowNo1 = (@PageNumber * @PageSize) + 1
	SET @EndRowNo1   = (@PageNumber * @PageSize) + @PageSize
	
	SET @Query1 = ' WITH TempIQCore_Recordfile  '
	SET @Query1 = @Query1 + ' AS ( '
	
	SET @Query1 = @Query1 + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL OR @SortField != ''
		BEGIN		
				set @Query1 = @Query1 + @SortField	
		END
	ELSE
		BEGIN
				SET @Query1 = @Query1 + ' [RecordMetaData].[UGCCreateDT] '
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query1 = @Query1 + ' DESC '
		END
    
    SET @Query1 = @Query1 + 	') as RowNumber,
		
			
				ArchiveClip.ArchiveClipKey,
				ArchiveClip.ClipID,
				ArchiveClip.ClipDate,
				ArchiveClip.ClipLogo,
				ArchiveClip.ClipTitle,
				ArchiveClip.FirstName,
				ArchiveClip.ClipCreationDate,
				ArchiveClip.ClosedCaption,
				ArchiveClip.[Description],
				ArchiveClip.CustomerID,
				ArchiveClip.Category,
				CustomCategory.CategoryName
	FROM
		ArchiveClip
		
	INNER JOIN Customer on Customer.CustomerGUID = ArchiveClip.CustomerGUID
	Inner join CustomCategory on ArchiveClip.CategoryGUID = CustomCategory.CategoryGUID 
	WHERE
		
		( ArchiveClip.[Description] LIKE ''%'+@SearchText+'%''  
		 
			OR ArchiveClip.ClipTitle LIKE ''%'+@SearchText+'%''
			
			OR ArchiveClip.ClosedCaption.query(''tt/body/div/p'').value(''.'',''varchar(Max)'') LIKE ''%'+@SearchText+'%''	
		)
		
		
		AND ArchiveClip.CategoryGUID = '''+CONVERT(varchar(40),@Category)+'''
		AND ArchiveClip.ClientGUID = '''+CONVERT(varchar(40),@ClientGUID)+'''
		 AND ArchiveClip.IsActive = 1
		 
		 '
		 
		 SET @Query1 = @Query1 + ') '
	
	SET  @Query1 = @Query1 + ' SELECT * FROM TempIQCore_Recordfile Where RowNumber >=' + CAST(@StartRowNo1 as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo1 as VARCHAR)
	
	print @Query1 
	
	EXEC SP_EXECUTESQL @Query1
		
	Select	
			@TotalRecordsCount=COUNT(ArchiveClip.ArchiveClipKey)
	FROM  
		
			ArchiveClip
		
	INNER JOIN Customer on Customer.CustomerGUID = ArchiveClip.CustomerGUID
	Inner join CustomCategory on ArchiveClip.CategoryGUID = CustomCategory.CategoryGUID 
	WHERE
		
		( ArchiveClip.[Description] LIKE '%' + @SearchText + '%'  
		 
			OR ArchiveClip.ClipTitle LIKE '%' + @SearchText + '%'
			
			OR ArchiveClip.ClosedCaption.query('tt/body/div/p').value('.','varchar(Max)') LIKE '%' + @SearchText + '%'		
		)
		
		
		AND ArchiveClip.CategoryGUID = @Category
		
		 AND ArchiveClip.IsActive = 1
		 
		 AND ArchiveClip.ClientGUID = @ClientGUID
		 
		END
END
