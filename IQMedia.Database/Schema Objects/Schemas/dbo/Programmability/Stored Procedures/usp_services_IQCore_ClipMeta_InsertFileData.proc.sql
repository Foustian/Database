CREATE PROCEDURE [dbo].[usp_services_IQCore_ClipMeta_InsertFileData]
(
	@ClipGuid		uniqueidentifier,
	@Location		varchar(MAX),
	@Filename		varchar(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ISCommited BIT
	SET @ISCommited =1;
	BEGIN TRANSACTION 
	BEGIN TRY
		IF NOT EXISTS(Select Value FROM IQCore_ClipMeta Where _ClipGuid = @ClipGuid AND (LOWER(Field) = 'filename' OR LOWER(Field) = 'filelocation'))
		BEGIN
			INSERT INTO	IQCore_ClipMeta(
				Field,
				Value,
				_ClipGuid)
			VALUES(
				'FileName',
				@Filename,
				@ClipGuid)
				
			INSERT INTO	IQCore_ClipMeta(
				Field,
				Value,
				_ClipGuid)
			VALUES(
				'FileLocation',
				@Location,
				@ClipGuid)
			
			IF NOT EXISTS(Select Value FROM IQCore_ClipMeta Where _ClipGuid = @ClipGuid AND LOWER(Field) = 'nooftimesdownloaded')
			BEGIN
				INSERT INTO	IQCore_ClipMeta(
					Field,
					Value,
					_ClipGuid)
				VALUES(
					'NoOfTimesDownloaded',
					'0',
					@ClipGuid)
			END
		END
		COMMIT TRANSACTION
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @ISCommited =0;
	END CATCH
	SELECT @ISCommited as IsCommited
END