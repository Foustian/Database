CREATE PROCEDURE [dbo].[usp_feedsexport_IQService_FeedsExport_UpdateDownloadPath]
(
	@ID		BIGINT,
	@DownloadPath	VARCHAR(255)
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRANSACTION

    UPDATE IQMediaGroup.dbo.IQService_FeedsExport
    SET
		DownloadPath=@DownloadPath
    WHERE
			ID=@ID
			
	DECLARE @TypeID	BIGINT
		
	SELECT
		@TypeID=ID
	FROM
		IQMediaGroup.dbo.IQJob_Type
	WHERE
		Name='FeedsCSVExport'
			
	UPDATE IQMediaGroup.dbo.IQJob_Master
    SET
		_DownloadPath=@DownloadPath
    WHERE
			_RequestID=@ID
		AND _TypeID=@TypeID
	
	COMMIT TRANSACTION
    
END
