-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCore_RecordFile_SelectFileLocation_ByGUID]
	@RLVideoGUID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
    Select
		IQCore_RootPath.StoragePath + IQCore_RecordFile.Location as 'FileLocation',
		IQCore_RecordFile._RootPathID as 'RootPathID',
		IQCore_Recording.StartDate as 'RecordingDate'
		
	From
		IQCore_RecordFile
		
	Inner Join IQCore_RootPath
	ON IQCore_RecordFile._RootPathID = IQCore_RootPath.ID
	
	Inner join IQCore_Recording
	ON IQCore_Recording.ID = IQCore_RecordFile._RecordingID
	
	Where --IQCore_RootPath.IsActive = 1
	IQCore_RecordFile.Guid = @RLVideoGUID
    
END