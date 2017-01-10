
CREATE PROCEDURE [dbo].[usp_UGCRawMedia_Select_Old]
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
	
	SET @Query = ' WITH TempIQCore_Recordfile  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL OR @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' [RecordMetaData].[UGCCreateDT] '
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
	
	/*if (@WhereStatment is not null and @WhereStatment!='')
		begin
			set @WhereStatment=' and '+@WhereStatment
		end
	
	if(@WhereStatment is null)
		begin
			set @WhereStatment=''
		end*/
	
	SET @Query = @Query + 	') as RowNumber,
	
            [RecordMetaData].[UGCTitle],
            [RecordMetaData].[UGCKwords],
            [RecordMetaData].[UGCCreateDT],
            [CustomCategory].[CategoryName],
            [CustomCategory].[CategoryGUID],
            [Customer].[FirstName],
            [IQCore_Recording].[StartDate] AS AirDate,
            [IQCore_Recordfile].[Guid],
            [RecordMetaData].[iQUser] as CustomerGUID
      FROM  
			[IQCore_Recordfile]
				Inner Join [IQCore_Recording]
					ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
				Inner Join [IQCore_Source]
					ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
				Inner Join [IQClient_UGCMap]
					ON [IQCore_Source].[Guid] = [IQClient_UGCMap].[SourceGUID]
				Inner Join
				(
					SELECT
								[_RecordfileGuid], 
								[UGC-Title] as UGCTitle,
								[UGC-Category] as UGCCategory, 
								[UGC-Kwords] as UGCKwords,
								[UGC-CreateDT] as UGCCreateDT,
								[iQUser]
					FROM
						  (
							  SELECT
										[IQCore_RecordfileMeta].[_RecordfileGuid],
										[IQCore_RecordfileMeta].[Field],
										[IQCore_RecordfileMeta].[Value]
							  FROM
										[IQCore_RecordfileMeta]
						  ) AS SourceTable
						  PIVOT
						  (
								Max(Value)
								FOR Field IN ([UGC-Title],[UGC-Category], [UGC-Kwords],[UGC-CreateDT],[iQUser])
						  ) AS PivotTable
				) as RecordMetaData
					ON [IQCore_Recordfile].[Guid]=[RecordMetaData].[_RecordfileGuid]
				Inner Join [Customer]
					ON [RecordMetaData].[iQUser] = [Customer].[CustomerGUID]
				Inner Join [CustomCategory]
					ON [RecordMetaData].[UGCCategory] = [CustomCategory].[CategoryGUID]
      WHERE 
				[IQClient_UGCMap].[ClientGUID]='''+CONVERT(varchar(40),@ClientGUID)+''' and
				[IQCore_RecordFile].[Status]!=''DELETED'' and
				[IQCore_RecordFile].[Status]!=''WEBDELETED'''
				
	if(@CategoryGUID is not null)
		begin
				set @Query=@Query+' and CategoryGUID = '''+ CONVERT(varchar(36),@CategoryGUID)+''''
		end
	
	if(@CustomerGUID is not null)
		begin
				set @Query=@Query+' and iQUser = '''+ CONVERT(varchar(36),@CustomerGUID)+''''
		end

	SET @Query = @Query + ') '
	
	SET  @Query = @Query + ' SELECT * FROM TempIQCore_Recordfile Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	
	print @Query
	
			
 EXEC SP_EXECUTESQL @Query
	
	
	Select	
			@TotalRecordsCount=COUNT([IQCore_Recordfile].[Guid])
	FROM  
			[IQCore_Recordfile]
				Inner Join [IQCore_Recording]
					ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
				Inner Join [IQCore_Source]
					ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
				Inner Join [IQClient_UGCMap]
					ON [IQCore_Source].[Guid] = [IQClient_UGCMap].[SourceGUID]
				Inner Join
				(
					SELECT
								[_RecordfileGuid], 
								[UGC-Title] as UGCTitle,
								[UGC-Category] as UGCCategory, 
								[UGC-Kwords] as UGCKwords,
								[UGC-CreateDT] as UGCCreateDT,
								[iQUser]
					FROM
						  (
							  SELECT
										[IQCore_RecordfileMeta].[_RecordfileGuid],
										[IQCore_RecordfileMeta].[Field],
										[IQCore_RecordfileMeta].[Value]
							  FROM
										[IQCore_RecordfileMeta]
						  ) AS SourceTable
						  PIVOT
						  (
								Max(Value)
								FOR Field IN ([UGC-Title],[UGC-Category], [UGC-Kwords],[UGC-CreateDT],[iQUser])
						  ) AS PivotTable
				) as RecordMetaData
					ON [IQCore_Recordfile].[Guid]=[RecordMetaData].[_RecordfileGuid]
				Inner Join [Customer]
					ON [RecordMetaData].[iQUser] = [Customer].[CustomerGUID]
				Inner Join [CustomCategory]
					ON [RecordMetaData].[UGCCategory] = [CustomCategory].[CategoryGUID]
      WHERE 
				[IQClient_UGCMap].[ClientGUID]= @ClientGUID and
				(@CategoryGUID is null or CategoryGUID=@CategoryGUID) and
				(@CustomerGUID is null or CustomerGUID=@CustomerGUID) and
				([IQCore_Recordfile].[Status]!='DELETED' and [IQCore_Recordfile].[Status]!='WEBDELETED')
	
	
END
