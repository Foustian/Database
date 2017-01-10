
CREATE PROCEDURE [dbo].[usp_ArchiveClip_SearchBySearchTerm]
(
	@ClientGUID			uniqueidentifier,
	@SearchTerm			varchar(50),
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
	
	SET @Query = ' WITH ArchiveClipSearch  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
						
	IF @SortField IS NOT NULL OR @SortField <> ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' ClipCreationDate '
		END
		
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END

	SET @Query = @Query + 	') as RowNumber,   
			ArchiveClip.ClipID,
			ArchiveClip.ClipLogo,
			ArchiveClip.ClipTitle,
			ArchiveClip.ClipDate,
			ArchiveClip.ClipCreationDate
	From
			ArchiveClip
	Where
			ArchiveClip.ClientGUID='''+CONVERT(varchar(40),@ClientGUID)+''' and
			(
				ArchiveClip.ClipTitle like ''%'+@SearchTerm+'%'' or
				ArchiveClip.[Description] like ''%'+@SearchTerm+'%'' or
				ArchiveClip.ClosedCaption is null or ArchiveClip.ClosedCaption.query(''tt/body/div/p'').value(''.'',''varchar(Max)'') like ''%' + @SearchTerm + '%''
			) and
			ArchiveClip.IsActive=1'
			
	SET @Query = @Query + ') '
		
	SET  @Query = @Query + ' SELECT * FROM ArchiveClipSearch Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	
		
	print @Query
			
   EXEC SP_EXECUTESQL @Query
    
    Select	
			@TotalRecordsCount=COUNT(ArchiveClip.ClipID)
	From
			ArchiveClip
	Where
			ArchiveClip.ClientGUID=@ClientGUID and
			(
				ArchiveClip.ClipTitle like '%'+@SearchTerm+'%' or
				ArchiveClip.[Description] like '%'+@SearchTerm+'%' or
				(ArchiveClip.ClosedCaption is null or ArchiveClip.ClosedCaption.query('tt/body/div/p').value('.','varchar(Max)') like '%' + @SearchTerm + '%')
			) and
			ArchiveClip.IsActive=1
END
