CREATE PROCEDURE [dbo].[usp_v4_ArchiveMS_Insert]
	@MediaIDs XML,
	@ClientGUID UNIQUEIDENTIFIER,
	@CustomerGUID UNIQUEIDENTIFIER,
	@Output INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- If any Media-type records are selected, exit the procedure
	DECLARE @NumMedia INT

	SELECT	@NumMedia = COUNT(*)
	FROM	@MediaIDs.nodes('list/item') as UGC(ID)
	INNER	JOIN IQUGCArchive WITH (NOLOCK) ON IQUGCArchive.IQUGCArchiveKey = UGC.ID.value('@id', 'bigint')
	INNER	JOIN IQUGC_FileTypes ON IQUGCArchive._FileTypeID = IQUGC_FileTypes.ID
	WHERE	IQUGC_FileTypes.FileType = 'VMedia'

	IF @NumMedia = 0
	  BEGIN	  
		BEGIN TRANSACTION
		BEGIN TRY
			
			DECLARE @TempNewData table(ID bigint, Title varchar(2048), CategoryGUID uniqueidentifier, SubCategoryGUID1 uniqueidentifier, SubCategoryGUID2 uniqueidentifier, SubCategoryGUID3 uniqueidentifier, Description varchar(2048), CreateDT datetime, TimeZone varchar(3))
			DECLARE @TempExistingData table(ID bigint)
			
			INSERT INTO @TempExistingData
			SELECT	ArchiveMiscKey
			FROM	@MediaIDs.nodes('list/item') as UGC(ID)
			INNER	JOIN IQUGCArchive WITH (NOLOCK) ON IQUGCArchive.IQUGCArchiveKey = UGC.ID.value('@id', 'bigint')
			INNER	JOIN ArchiveMisc WITH (NOLOCK) ON ArchiveMisc.UGCGUID = IQUGCArchive.UGCGUID

			INSERT INTO ArchiveMisc
			(
				UGCGUID,
				CategoryGUID,
				SubCategoryGUID1,
				SubCategoryGUID2,
				SubCategoryGUID3,
				CustomerGUID,
				ClientGUID,
				Title,
				Keywords,
				Description,
				_RootPathID,
				Location,
				_FileTypeID,
				CreateDT,
				CreateDTTimeZone,
				CreatedDate,
				ModifiedDate,
				IsActive,
				v5SubMediaType
			)
			OUTPUT INSERTED.ArchiveMiscKey as ID, INSERTED.Title as Title, INSERTED.CategoryGUID as CategoryGUID, INSERTED.SubCategoryGUID1 as SubCategoryGUID1, INSERTED.SubCategoryGUID2 as SubCategoryGUID1, 
					INSERTED.SubCategoryGUID3 as SubCategoryGUID1, INSERTED.Description as Description, INSERTED.CreateDT as CreateDT, INSERTED.CreateDTTimeZone as TimeZone
			INTO @TempNewData
			SELECT	UGCGUID,
					CategoryGUID,
					SubCategory1GUID,
					SubCategory2GUID,
					SubCategory3GUID,
					@CustomerGUID,
					@ClientGUID,
					Title,
					SUBSTRING(Keywords, 0, 2049),
					SUBSTRING(Description, 0, 2049),
					_RootPathID,
					Location,
					_FileTypeID,
					CreateDT,
					CreateDTTimeZone,
					GETDATE(),
					GETDATE(),
					1,
					'MS'
			FROM	@MediaIDs.nodes('list/item') as UGC(ID)
			INNER	JOIN IQUGCArchive WITH (NOLOCK) ON IQUGCArchive.IQUGCArchiveKey = UGC.ID.value('@id', 'bigint')
			WHERE	NOT EXISTS (SELECT	NULL
								FROM	ArchiveMisc WITH (NOLOCK)
								WHERE	ArchiveMisc.UGCGUID = IQUGCArchive.UGCGUID)
			
			-- Convert CreateDT field to GMT based on selected time zone, to ensure proper sorting
			UPDATE @TempNewData
			SET CreateDT = DATEADD(HOUR, 
									((CASE TimeZone WHEN 'EST' THEN 5
											 	    WHEN 'CST' THEN 6
												    WHEN 'MST' THEN 7
												    WHEN 'PST' THEN 8 END) - 
									 (CASE dbo.fnIsDayLightSaving(CreateDT) WHEN 1 THEN 1 
																		    ELSE 0 END)), 
									CreateDT)
			
			INSERT INTO IQArchive_Media
			(
				_ArchiveMediaID,
				MediaType,
				Title,
				SubMediaType,
				CategoryGUID,
				SubCategory1GUID,
				SubCategory2GUID,
				SubCategory3GUID,
				MediaDate,
				ClientGUID,
				CustomerGUID,
				CreatedDate,
				IsActive,
				Content,
				v5MediaType,
				v5SubMediaType
			)
			SELECT	ID,
					'MS',
					Title,
					'MS',
					CategoryGUID,
					SubCategoryGUID1,
					SubCategoryGUID2,
					SubCategoryGUID3,
					CreateDT,
					@ClientGUID,
					@CustomerGUID,
					GETDATE(),
					1,
					Description,
					'MS',
					'MS'
			FROM	@TempNewData

			SET @Output = @@ROWCOUNT
			
			UPDATE	ArchiveMisc 
			SET		IsActive = 1
			WHERE	EXISTS (SELECT	NULL
							FROM	@TempExistingData temp
							WHERE	temp.ID = ArchiveMisc.ArchiveMiscKey)
							
			UPDATE	IQArchive_Media
			SET		IsActive = 1
			WHERE	EXISTS (SELECT	NULL
							FROM	@TempExistingData temp
							WHERE	temp.ID = IQArchive_Media._ArchiveMediaID
									AND IQArchive_Media.MediaType = 'MS')
									
			SET @Output = @Output + @@ROWCOUNT

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
					@CreatedBy='usp_v4_ArchiveMS_Insert',
					@ModifiedBy='usp_v4_ArchiveMS_Insert',
					@CreatedDate=GETDATE(),
					@ModifiedDate=GETDATE(),
					@IsActive=1
				
			SET @Output = -1
		
			EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT		
		END CATCH
	  END
	ELSE
	  BEGIN
		SET @Output = -2
	  END
END
