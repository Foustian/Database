-- =============================================
-- Author:		<Author,,Name>
-- Create date: 21 June 2013
-- Description:	Update record in respected table
-- =============================================
CREATE PROCEDURE [dbo].[usp_v5_IQArchive_Media_UpdateMediaRecord]
	@ID					BIGINT,
	@Title				VARCHAR(500),
	@CategoryGuid		VARCHAR(100),
	@SubCategory1Guid	VARCHAR(100),
	@SubCategory2Guid	VARCHAR(100),
	@SubCategory3Guid	VARCHAR(100),
	@Keywords			VARCHAR(MAX),
	@Description		VARCHAR(2048),
	@DisplayDescription	BIT,
	@PositiveSentiment TINYINT,
	@NegativeSentiment TINYINT,
	@ClientGuid			uniqueidentifier
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @DataModelType AS VARCHAR(10),@ArhiveMediaID AS BIGINT
	
	SELECT 
			@DataModelType = DataModelType,
			@ArhiveMediaID = _ArchiveMediaID
	FROM 
			IQArchive_Media
	INNER	JOIN IQ_MediaTypes
			ON IQ_MediaTypes.SubMediaType = IQArchive_Media.v5SubMediaType 
	WHERE	IQArchive_Media.ID = @ID
	
	-- Update in IQArchive_Media table
	
	UPDATE	IQArchive_Media 
	SET		Title= @Title,
			CategoryGUID = @CategoryGuid,
			SubCategory1GUID = @SubCategory1Guid,
			SubCategory2GUID = @SubCategory2Guid,
			SubCategory3GUID = @SubCategory3Guid,
			Content = CASE WHEN @DataModelType = 'MS' THEN @Description ELSE IQArchive_Media.Content END,
			DisplayDescription = CASE WHEN @DisplayDescription IS NOT NULL THEN @DisplayDescription ELSE DisplayDescription END,
			PositiveSentiment = @PositiveSentiment,
			NegativeSentiment = @NegativeSentiment
	WHERE	ID = @ID
	AND IQArchive_Media.ClientGuid = @ClientGuid
	
	IF @DataModelType IS NOT NULL AND @DataModelType = 'PM'
		BEGIN
				UPDATE	ArchiveBLPM
						
				SET		Headline = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategory1GUID = @SubCategory1Guid,
						SubCategory2GUID = @SubCategory2Guid,
						SubCategory3GUID = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = SUBSTRING(@Description, 0, 1000),
						ModifiedDate = GETDATE()
				WHERE	ArchiveBLPMKey = @ArhiveMediaID AND ArchiveBLPM.ClientGUID = @ClientGuid
				
		END
		
	IF @DataModelType IS NOT NULL AND @DataModelType = 'TV'
		BEGIN
				UPDATE	ArchiveClip
				SET		ClipTitle = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategory1GUID = @SubCategory1Guid,
						SubCategory2GUID = @SubCategory2Guid,
						SubCategory3GUID = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = @Description,
						PositiveSentiment = @PositiveSentiment,
						NegativeSentiment = @NegativeSentiment,
						ModifiedDate = GETDATE()
				WHERE	ArchiveClipKey = @ArhiveMediaID AND ArchiveClip.ClientGUID = @ClientGuid
				
				DECLARE @RowUpdated int

				SET @RowUpdated = @@ROWCOUNT

				DECLARE @ClipGuid AS UNIQUEIDENTIFIER
				
				SELECT @ClipGuid = ClipID FROM ArchiveClip WHERE ArchiveClipKey = @ArhiveMediaID
				
				IF @ClipGuid IS NOT NULL AND @RowUpdated > 0
					BEGIN

						UPDATE IQCore_ClipInfo SET Title = @Title,Keywords = @Keywords,[Description] = @Description Where _ClipGuid = @ClipGuid
						
						UPDATE IQCore_ClipMeta SET [Value] = @CategoryGuid WHERE _ClipGuid = @ClipGuid AND Field = 'iQCategory'
						
						-- Check for SubCategory 1
						
						IF @SubCategory1Guid IS NOT NULL
							BEGIN
								IF EXISTS(SELECT 1 FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory1GUID')
									BEGIN
										UPDATE IQCore_ClipMeta SET [Value] = @SubCategory1Guid WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory1GUID'
									END
								ELSE
									BEGIN
										INSERT INTO IQCore_ClipMeta(_ClipGuid,Field,Value) VALUES(@ClipGuid,'SubCategory1GUID',@SubCategory1Guid)
									END
							END
						
						-- Check for SubCategory 2
						
						IF @SubCategory2Guid IS NOT NULL
							BEGIN
								IF EXISTS(SELECT 1 FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory2GUID')
									BEGIN
										UPDATE IQCore_ClipMeta SET [Value] = @SubCategory2Guid WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory2GUID'
									END
								ELSE
									BEGIN
										INSERT INTO IQCore_ClipMeta(_ClipGuid,Field,Value) VALUES(@ClipGuid,'SubCategory2GUID',@SubCategory2Guid)
									END
							END
						-- Check for SubCategory 3
						
						IF @SubCategory3Guid IS NOT NULL
							BEGIN
								IF EXISTS(SELECT 1 FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory3GUID')
									BEGIN
										UPDATE IQCore_ClipMeta SET [Value] = @SubCategory3Guid WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory3GUID'
									END
								ELSE
									BEGIN
										INSERT INTO IQCore_ClipMeta(_ClipGuid,Field,Value) VALUES(@ClipGuid,'SubCategory3GUID',@SubCategory3Guid)
									END
							END
					END
				
		END
	
	IF @DataModelType IS NOT NULL AND @DataModelType = 'NM'
		BEGIN
				UPDATE  ArchiveNM
				SET		Title = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategory1GUID = @SubCategory1Guid,
						SubCategory2GUID = @SubCategory2Guid,
						SubCategory3GUID = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = @Description,
						PositiveSentiment = @PositiveSentiment,
						NegativeSentiment = @NegativeSentiment,
						ModifiedDate = GETDATE()
						
				WHERE	ArchiveNMKey = @ArhiveMediaID
				AND ArchiveNM.ClientGuid = @ClientGuid
		END
	
	IF @DataModelType IS NOT NULL AND @DataModelType = 'SM'
		BEGIN
				UPDATE  ArchiveSM
				SET		Title = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategory1GUID = @SubCategory1Guid,
						SubCategory2GUID = @SubCategory2Guid,
						SubCategory3GUID = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = @Description,
						PositiveSentiment = @PositiveSentiment,
						NegativeSentiment = @NegativeSentiment,
						ModifiedDate = GETDATE()
						
				WHERE	ArchiveSMKey = @ArhiveMediaID
				AND ArchiveSM.ClientGuid = @ClientGuid
		END
		
	IF @DataModelType IS NOT NULL AND @DataModelType = 'TW'
		BEGIN
				UPDATE  ArchiveTweets
				SET		Actor_DisplayName = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategory1GUID = @SubCategory1Guid,
						SubCategory2GUID = @SubCategory2Guid,
						SubCategory3GUID = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = @Description,
						PositiveSentiment = @PositiveSentiment,
						NegativeSentiment = @NegativeSentiment,
						ModifiedDate = GETDATE()
						
				WHERE	ArchiveTweets_Key = @ArhiveMediaID
				AND ArchiveTweets.ClientGUID = @ClientGuid
		END

	IF @DataModelType IS NOT NULL AND @DataModelType = 'TM'
		BEGIN
				UPDATE  ArchiveTVEyes
				SET		Title = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategory1GUID = @SubCategory1Guid,
						SubCategory2GUID = @SubCategory2Guid,
						SubCategory3GUID = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = @Description,
						PositiveSentiment = @PositiveSentiment,
						NegativeSentiment = @NegativeSentiment,
						ModifiedDate = GETDATE()
						
				WHERE	ArchiveTVEyesKey = @ArhiveMediaID
				AND ArchiveTVEyes.ClientGUID = @ClientGuid
		END
	
	IF @DataModelType IS NOT NULL AND @DataModelType = 'MS'
		BEGIN
				UPDATE	ArchiveMisc
						
				SET		Title = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategoryGUID1 = @SubCategory1Guid,
						SubCategoryGUID2 = @SubCategory2Guid,
						SubCategoryGUID3 = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = @Description,
						ModifiedDate = GETDATE()
				WHERE	ArchiveMiscKey = @ArhiveMediaID AND ArchiveMisc.ClientGUID = @ClientGuid
				
		END

	IF @DataModelType IS NOT NULL AND @DataModelType = 'PQ'
		BEGIN
				UPDATE  ArchivePQ
				SET		Title = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategory1GUID = @SubCategory1Guid,
						SubCategory2GUID = @SubCategory2Guid,
						SubCategory3GUID = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = @Description,
						PositiveSentiment = @PositiveSentiment,
						NegativeSentiment = @NegativeSentiment,
						ModifiedDate = GETDATE()
						
				WHERE	ArchivePQKey = @ArhiveMediaID
				AND ArchivePQ.ClientGUID = @ClientGuid
		END		
		
	IF @DataModelType IS NOT NULL AND @DataModelType = 'IQR'
		BEGIN
				UPDATE	ArchiveRadio
				SET		Title = @Title,
						CategoryGUID = @CategoryGuid,
						SubCategory1GUID = @SubCategory1Guid,
						SubCategory2GUID = @SubCategory2Guid,
						SubCategory3GUID = @SubCategory3Guid,
						Keywords = @Keywords,
						[Description] = @Description,
						PositiveSentiment = @PositiveSentiment,
						NegativeSentiment = @NegativeSentiment,
						ModifiedDate = GETDATE()
				WHERE	ArchiveRadioKey = @ArhiveMediaID AND ArchiveRadio.ClientGUID = @ClientGuid
				
				SET @RowUpdated = @@ROWCOUNT
				
				SELECT @ClipGuid = ClipGuid FROM ArchiveRadio WHERE ArchiveRadioKey = @ArhiveMediaID
				
				IF @ClipGuid IS NOT NULL AND @RowUpdated > 0
					BEGIN

						UPDATE IQCore_ClipInfo SET Title = @Title,Keywords = @Keywords,[Description] = @Description Where _ClipGuid = @ClipGuid
						
						UPDATE IQCore_ClipMeta SET [Value] = @CategoryGuid WHERE _ClipGuid = @ClipGuid AND Field = 'iQCategory'
						
						-- Check for SubCategory 1
						
						IF @SubCategory1Guid IS NOT NULL
							BEGIN
								IF EXISTS(SELECT 1 FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory1GUID')
									BEGIN
										UPDATE IQCore_ClipMeta SET [Value] = @SubCategory1Guid WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory1GUID'
									END
								ELSE
									BEGIN
										INSERT INTO IQCore_ClipMeta(_ClipGuid,Field,Value) VALUES(@ClipGuid,'SubCategory1GUID',@SubCategory1Guid)
									END
							END
						
						-- Check for SubCategory 2
						
						IF @SubCategory2Guid IS NOT NULL
							BEGIN
								IF EXISTS(SELECT 1 FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory2GUID')
									BEGIN
										UPDATE IQCore_ClipMeta SET [Value] = @SubCategory2Guid WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory2GUID'
									END
								ELSE
									BEGIN
										INSERT INTO IQCore_ClipMeta(_ClipGuid,Field,Value) VALUES(@ClipGuid,'SubCategory2GUID',@SubCategory2Guid)
									END
							END
						-- Check for SubCategory 3
						
						IF @SubCategory3Guid IS NOT NULL
							BEGIN
								IF EXISTS(SELECT 1 FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory3GUID')
									BEGIN
										UPDATE IQCore_ClipMeta SET [Value] = @SubCategory3Guid WHERE _ClipGuid = @ClipGuid AND Field = 'SubCategory3GUID'
									END
								ELSE
									BEGIN
										INSERT INTO IQCore_ClipMeta(_ClipGuid,Field,Value) VALUES(@ClipGuid,'SubCategory3GUID',@SubCategory3Guid)
									END
							END
					END
				
		END
END
