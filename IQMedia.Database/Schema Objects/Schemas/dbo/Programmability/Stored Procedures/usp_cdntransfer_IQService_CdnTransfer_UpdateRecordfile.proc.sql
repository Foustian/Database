CREATE PROCEDURE [dbo].[usp_cdntransfer_IQService_CdnTransfer_UpdateRecordfile]
(
	@Guid	uniqueidentifier,
	@EndOffset int,
	@Location varchar(2048)
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRANSACTION

    UPDATE IQCore_Recordfile
    SET
		EndOffset = @EndOffset,
		Location = @Location
    WHERE
		Guid = @Guid
	
	COMMIT TRANSACTION
    
END