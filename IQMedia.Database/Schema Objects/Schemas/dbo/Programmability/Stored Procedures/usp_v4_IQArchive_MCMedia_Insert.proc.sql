CREATE PROCEDURE [dbo].[usp_v4_IQArchive_MCMedia_Insert] 
	@MasterClientID INT,
	@IsMediaRoomEditor BIT,
	@MediaIDs XML,
	@ReturnValue INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @MasterClientGUID UNIQUEIDENTIFIER
		SELECT @MasterClientGUID = ClientGUID FROM Client WHERE ClientKey = @MasterClientID

		INSERT INTO IQArchive_MCMedia (MasterClientGUID, ArchiveID, IsActive, CreatedDate, ModifiedDate)
		SELECT	@MasterClientGUID,
				Media.ID.value('.', 'bigint'),
				1,
				GETDATE(),
				GETDATE()		
		FROM	@MediaIDs.nodes('MediaResults/ID') as Media(ID)
		INNER	JOIN IQArchive_Media WITH (NOLOCK)
				ON IQArchive_Media.ID = Media.ID.value('.', 'bigint')
		WHERE	NOT EXISTS (SELECT	null
							FROM	IQArchive_MCMedia m1 WITH (NOLOCK)
							WHERE	m1.ArchiveID = Media.ID.value('.', 'bigint')
									AND m1.MasterClientGUID = @MasterClientGUID)

		SET @ReturnValue = @@ROWCOUNT

		UPDATE	IQArchive_MCMedia
		SET		IsActive = 1,
				ModifiedDate = GETDATE()
		WHERE	MasterClientGUID = @MasterClientGUID
				AND IsActive = 0
				AND @MediaIDs.exist('MediaResults/ID[text()=sql:column("IQArchive_MCMedia.ArchiveID")]') = 1

		SET @ReturnValue = @ReturnValue + @@ROWCOUNT

		-- Insert the new records into the published report
		DECLARE @ReportGUID UNIQUEIDENTIFIER
		DECLARE @ReportTypeID INT

		SELECT	@ReportTypeID = CAST(Value AS INT)
		FROM	IQClient_CustomSettings 
		WHERE	Field = 'MCMediaPublishedTemplateID'
		AND		(_ClientGuid = @MasterClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
		order by _ClientGuid asc

		IF(@IsMediaRoomEditor = 1)
			BEGIN
				EXEC dbo.usp_v4_IQArchive_MCMedia_AddToReport NULL, @MasterClientID, @MediaIDs, @ReportTypeID, @ReportGUID OUTPUT 
			END

		COMMIT TRANSACTION	
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SET @ReturnValue = -1
		
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
				@CreatedBy='usp_v4_IQArchive_MCMedia_Insert',
				@ModifiedBy='usp_v4_IQArchive_MCMedia_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
						
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT		
	END CATCH

END
