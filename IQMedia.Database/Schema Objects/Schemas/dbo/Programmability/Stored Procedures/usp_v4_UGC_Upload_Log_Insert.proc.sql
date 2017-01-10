CREATE PROCEDURE [dbo].[usp_v4_UGC_Upload_Log_Insert]
(
	@CustomerGUID		UNIQUEIDENTIFIER,
	@UGCContentXml		XML,
	@FileName			VARCHAR(255),
	@UploadedDateTime	DATETIME,
	@Output bigint output
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @UGC_Upload_Key bigint

	INSERT INTO UGC_Upload_Log
	(
		CustomerGUID,
		UGCContentXml,
		UploadedDateTime,
		[FileName],
		CreatedBy,
		ModifiedBy,
		CreatedDate,
		ModifiedDate,
		IsActive
	)
	VALUES
	(
		@CustomerGUID,
		@UGCContentXml,		
		@UploadedDateTime,
		@FileName,
		'System',
		'System',
		GETDATE(),
		GETDATE(),
		1
	)

	SET @UGC_Upload_Key = SCOPE_IDENTITY()

	IF(@UGC_Upload_Key > 0)
	BEGIN
		INSERT INTO IQService_Conversion
		(
			[Filename],
			ugc_upload_logKey,
			[Status],
			[DateQueued],
			[LastModified]
		)
		values
		(
			@FileName,
			@UGC_Upload_Key,
			'QUEUED',
			GETDATE(),
			GETDATE()
		)

		SET @Output = SCOPE_IDENTITY()

		IF(@Output > 0)
		BEGIN
			UPDATE 
					UGC_Upload_Log
			SET
					UGCContentXml.modify('insert <ID>{sql:variable("@Output")}</ID> as first into (/IngestionData)[1]')
			WHERE	
					UGC_Upload_LogKey = @UGC_Upload_Key
		END
	END
END