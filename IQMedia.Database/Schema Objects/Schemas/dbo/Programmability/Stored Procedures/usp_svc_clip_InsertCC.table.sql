CREATE PROCEDURE [dbo].[usp_svc_clip_InsertCC]
(
	@ClipGUID	UNIQUEIDENTIFIER,
	@CC			NVARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE ArchiveClip
			SET ClosedCaption= @CC
		WHERE	ClipID=@ClipGUID
		
		UPDATE IQArchive_Media
		SET	Content=CONVERT(NVARCHAR(MAX),@CC)
		FROM
				IQARchive_Media
					INNER JOIN ArchiveClip
					ON IQArchive_Media._ArchiveMediaID=ArchiveClip.ArchiveClipKey
					AND IQArchive_Media.MediaType='TV'
		WHERE	ArchiveClip.ClipID=@ClipGUID
		
		Select @@ROWCOUNT
		
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION
	
	DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActive	BIT
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v4_svc_Report_Feeds_Insert',
				@ModifiedBy='usp_v4_svc_Report_Feeds_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
	
	END CATCH
	
	
	
END