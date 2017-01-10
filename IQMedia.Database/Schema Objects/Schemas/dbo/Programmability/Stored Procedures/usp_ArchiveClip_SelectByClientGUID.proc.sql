-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveClip_SelectByClientGUID]
	-- Add the parameters for the stored procedure here
	@ClientGUID uniqueidentifier,
	@PageNumber			int,
	@PageSize			int,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@CategoryGUID		uniqueidentifier,
	@CustomerGUID		uniqueidentifier,
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
		ArchiveClip.ClipCreationDate,		
		ArchiveClip.CategoryGUID,
		ArchiveClip.ClientGUID,
		ArchiveClip.CustomerGUID,
		ArchiveClip.ThumbnailImagePath,
		CustomCategory.CategoryName
		
	FROM
			ArchiveClip
				INNER join CustomCategory
					on ArchiveClip.CategoryGUID=CustomCategory.CategoryGUID
		 
	WHERE
			ArchiveClip.ClientGUID='''+CONVERT(varchar(40),@ClientGUID)+'''
			 AND ArchiveClip.IsActive = 1
			'
			
	if(@CategoryGUID is not null)
		begin
				set @Query=@Query+' and ArchiveClip.CategoryGUID = '''+ CONVERT(varchar(36),@CategoryGUID)+''''
		end
	
	if(@CustomerGUID is not null)
		begin
				set @Query=@Query+' and ArchiveClip.CustomerGUID = '''+ CONVERT(varchar(36),@CustomerGUID)+''''
		end
		
	SET @Query = @Query + ') '
	
	SET  @Query = @Query + ' SELECT * FROM TempIQCore_Recordfile Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	
	print @Query 
	
	EXEC SP_EXECUTESQL @Query
		
	Select	
			@TotalRecordsClipCount=COUNT(ArchiveClip.ArchiveClipKey)
	FROM  
			ArchiveClip
				INNER join CustomCategory
					on ArchiveClip.CategoryGUID=CustomCategory.CategoryGUID
		 
	WHERE
			ArchiveClip.ClientGUID=@ClientGUID AND ArchiveClip.IsActive = 1
	 
			
	
END
