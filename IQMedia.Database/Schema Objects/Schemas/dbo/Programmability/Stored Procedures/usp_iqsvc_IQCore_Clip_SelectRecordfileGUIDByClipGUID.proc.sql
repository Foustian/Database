CREATE PROCEDURE [dbo].[usp_iqsvc_IQCore_Clip_SelectRecordfileGUIDByClipGUID]
	 @GUID   uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select
			CASE 
			WHEN IQCore_Recordfile._ParentGuid is null then IQCore_Recordfile.[Guid]
			ELSE IQCore_Recordfile._ParentGuid
			END

			From IQCore_Clip
			INNER JOIN IQCore_Recordfile
			ON IQCore_Clip._RecordfileGuid = IQCore_Recordfile.Guid
			WHERE IQCore_Clip.Guid = @GUID
    
END