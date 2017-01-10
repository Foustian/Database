-- =============================================
-- Create date: 30/01/2012
-- Description:	Get file path of clip by clipGUID
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCore_RecordFileMeta_SelectPathByClipGuid]
	@ClipGUID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;			
			
			/*SELECT 
					@listStr = COALESCE(@listStr+'' , '') + IQCore_RecordfileMeta.Value 
			from 
					IQCore_Clip 
						inner join IQCore_RecordfileMeta 
							on IQCore_Clip._RecordfileGuid = IQCore_RecordfileMeta._RecordfileGuid 
			where 
					IQCore_Clip.Guid = @ClipGUID and 
					(IQCore_RecordfileMeta.Field='UGC-FileLocation' OR IQCore_RecordfileMeta.Field='UGC-FileName')
			
			Select @listStr as FilePath*/
			
			declare @RecordFileGUID uniqueidentifier					
			
			Select
					@RecordFileGUID=_RecordfileGuid
			From	
					IQCore_Clip
			Where
					[Guid]=@ClipGUID				
			
					
			Select
					([UGC-FileLocation]+[UGC-FileName]) as FilePath
			From
					
			(Select
					Field,Value
			From
					IQCore_RecordfileMeta
			Where
					_RecordfileGuid=@RecordFileGUID
					
					) AS SourceTable
			PIVOT
			(
				MAX(Value)
				FOR Field IN ([UGC-FileLocation], [UGC-FileName])
			) AS PivotTable
				
			
			
			

END
