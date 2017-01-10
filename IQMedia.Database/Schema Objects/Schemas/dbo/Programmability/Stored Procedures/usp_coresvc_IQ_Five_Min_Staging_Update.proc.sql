-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQ_Five_Min_Staging_Update]
	@IQCCKey varchar(150),
	@RecordFileGuid uniqueidentifier,
	@LastMediaSegment int,
	@MediaStatus varchar(50),
	@MediaFilename varchar(150)
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE IQMediaGroup.dbo.IQ_Five_Min_Staging
    SET 
		  [Media_Recordfile_GUID] = @RecordFileGuid,
		  [Last_Media_Segment]=@LastMediaSegment,
		  [Current_Active_Media_File]=@MediaFilename,
		  [Media_Process_Status]=@MediaStatus,
		  [ModifiedDate]=SYSDATETIME()
	WHERE IQ_CC_key = @IQCCKey 
	Select @@ROWCOUNT as RowAffected

END
