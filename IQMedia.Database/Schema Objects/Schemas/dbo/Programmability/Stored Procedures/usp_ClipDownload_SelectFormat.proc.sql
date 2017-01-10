
CREATE PROCEDURE usp_ClipDownload_SelectFormat
(
	@ClipID			uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	
	Select 			
			Extension
	From 
			IQCore_Clip
				Inner Join IQCore_Recordfile
					On IQCore_Clip._RecordfileGuid = IQCore_Recordfile.[Guid]
				Inner Join IQCore_RecordfileType
					on IQCore_Recordfile._RecordfileTypeID = IQCore_RecordfileType.ID
	Where
			 IQCore_Clip.[Guid] = @ClipID



END
