-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [usp_IQCore_Clip_UpdateRecordFileGUID]
	@RecordFileGUID uniqueidentifier ,
	@NewRecordFileGUID uniqueidentifier 
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE 
		IQCore_Clip 
	SET 
		_RecordfileGuid  = @NewRecordFileGUID
	FROM 
		IQCore_Clip 
			inner join IQCore_Recordfile
		on 
			IQCore_Clip._RecordfileGuid = IQCore_Recordfile.Guid and 
			IQCore_Recordfile.Guid = @RecordFileGUID
				
	SELECT @@ROWCOUNT
END
