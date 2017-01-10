CREATE PROCEDURE [dbo].[usp_cdntransfer_IQService_CdnTransfer_QueueExpiredMedia]
(
	 @ExpirationThreshold INT
)
AS
BEGIN

	SET NOCOUNT, XACT_ABORT ON;
	
	DECLARE @tblQueuedRecords TABLE (InsertedID BIGINT)
	 
	MERGE IQService_CdnTransfer WITH (HOLDLOCK)
	USING (SELECT 
				DISTINCT IQCore_Clip._RecordfileGuid 
			FROM 
				IQCore_Clip
					LEFT OUTER JOIN IQTrack_PlaySummary
						ON IQCore_Clip.Guid = IQTrack_PlaySummary._AssetGuid 
					INNER JOIN IQCore_Recordfile 
						ON IQCore_Clip._RecordfileGuid = IQCore_Recordfile.Guid 
					INNER JOIN IQCore_RootPath
						ON IQCore_Recordfile._RootPathID = IQCore_RootPath.ID 
			WHERE 
				IQCore_RootPath._RootPathTypeID = 5 -- RootPathType of 5 is CDN
					AND (IQTrack_PlaySummary._AssetGUID IS NULL OR DATEDIFF(day, IQTrack_PlaySummary.LastUpdated, CURRENT_TIMESTAMP) >= @ExpirationThreshold)) AS TempExpired
		ON TempExpired._RecordfileGuid = IQService_CdnTransfer.RecordfileGuid
			AND IQService_CdnTransfer.Direction = 'ToLocal'
			AND IQService_CdnTransfer.Status = 'QUEUED'
	WHEN NOT MATCHED THEN		
		INSERT (RecordfileGuid, Direction, Status, DateCreated, LastModified)
		VALUES (TempExpired._RecordfileGuid, 'ToLocal', 'QUEUED', GETDATE(), GETDATE())
	OUTPUT
		INSERTED.ID INTO @tblQueuedRecords;

	SELECT COUNT(*) AS NoOfQueuedRecords FROM @tblQueuedRecords		
END