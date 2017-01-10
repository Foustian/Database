CREATE PROCEDURE [dbo].[usp_v4_JobStatus_Download_SelectByID]
	@ID	BIGINT
AS
BEGIN

	SELECT
	
		StoragePath + _DownLoadPath AS DownloadLocation
		
	FROM
		IQJob_Master
			INNER JOIN IQCore_RootPath
				ON IQJob_Master._RootPathID = IQCore_RootPath.ID
	WHERE IQJob_Master.ID = @ID
	
END