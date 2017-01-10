-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQCore_RootPath_SelectMediaLocationByRecordFileGUID]
	@RecordFileGUID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	Select 
		GUID,
		IQCore_RootPath.StoragePath +  IQCore_Recordfile.Location as 'FullLocation',
		Status as 'MediaStatus'
	FROM 
		IQCore_Recordfile 
	INNER JOIN IQCore_RootPath
	ON IQCore_Recordfile._RootPathID = IQCore_RootPath.ID
	WHERE 
		_RecordingID = (
						Select 
						_RecordingID from
						IQCore_Recordfile where GUID = @RecordFileGUID
						)
END
