CREATE PROCEDURE [dbo].[usp_Services_ClipCCExport_Insert]
(
	@ClipGUID	UNIQUEIDENTIFIER,
	@ClientGUID	UNIQUEIDENTIFIER = NULL,
	@AddExisted	BIT = 0
)
AS
BEGIN

	DECLARE @ClipCCExportSettings	BIT

	IF (@ClientGUID IS NULL)
		BEGIN

			SELECT
					@ClientGUID = ClientGUID

			FROM
					ArchiveClip WITH (NOLOCK)
			WHERE
					ClipID = @ClipGUID

		END

	SELECT
			@ClipCCExportSettings = [Value]
	FROM
			IQClient_CustomSettings WITH (NOLOCK)
	WHERE
			_ClientGuid = @ClientGUID
		AND	Field = 'ClipCCEXport'

	IF (@ClipCCExportSettings = 1)
		BEGIN

			DECLARE @IsExist BIT = 0
			
			IF EXISTS(SELECT * FROM IQService_ClipCCExport WHERE _ClipGUID = @ClipGUID AND (@AddExisted = 1 OR ([Status] IN ('QUEUED','IN_PROCESS', 'SELECT'))))
				BEGIN
					SET @IsExist = 1
				END			

			IF (@IsExist = 0)
				BEGIN

					DECLARE @Date	DATETIME2(7) = SYSDATETIME()

					INSERT INTO IQService_ClipCCExport
					(
						ID,
						_ClipGUID,
						[Status],
						DateQueued,
						LastModified
					)
					VALUES
					(
						NEWID(),
						@ClipGUID,
						'QUEUED',
						@Date,
						@Date
					)

					IF (@@ROWCOUNT > 0)
						BEGIN
							-- Success
							SELECT 0

						END
					ELSE
						BEGIN							
							SELECT -1
						END
				END
			ELSE
				BEGIN
					-- Record already existed.
					SELECT 1

				END				
		END
	ELSE
		BEGIN
			-- Client doesn't have ClipCCExport Settings on
			SELECT 2
		END
END