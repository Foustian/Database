-- =============================================
-- Author:		<Author,,Name>
-- Create date: 21 June 2013
-- Description:	Select record from ArchiveBLPM,ArchiveNM,ArchiveSM,ArchiveTweets,ArchiveClip to edit
-- =============================================
CREATE PROCEDURE [dbo].[usp_v5_IQArchive_Media_SelectByIDForEdit] 
	@ClientGUID		VARCHAR(100),
	@ID				BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DataModelType AS VARCHAR(10), @MediaType AS VARCHAR(10),@ArhiveMediaID AS BIGINT,@DisplayDescription AS BIT,
			@PositiveSentiment tinyint, @NegativeSentiment tinyint
	
	SELECT 
			@DataModelType = DataModelType,
			@MediaType = v5MediaType,
			@ArhiveMediaID = _ArchiveMediaID,
			@DisplayDescription = DisplayDescription,
			@PositiveSentiment = PositiveSentiment,
			@NegativeSentiment = NegativeSentiment
	FROM 
			IQMediaGroup.dbo.IQArchive_Media WITH (NOLOCK)
	INNER	JOIN IQMediaGroup.dbo.IQ_MediaTypes
			ON IQ_MediaTypes.SubMediaType = IQArchive_Media.v5SubMediaType			 
	WHERE	IQArchive_Media.ID = @ID
	
	SELECT	CategoryGUID,
			CategoryName 
	FROM	IQMediaGroup.dbo.CustomCategory 
	WHERE	ClientGUID = @ClientGUID
			AND IsActive = 1
	ORDER	BY CategoryName
	
	IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'PM'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchiveBLPMKey AS ArchiveMediaKey,
						Headline AS Title,
						CategoryGUID AS CategoryGuid,
						SubCategory1GUID AS SubCategory1Guid,
						SubCategory2GUID AS SubCategory2Guid,
						SubCategory3GUID AS SubCategory3Guid,
						Keywords,
						[Description],						
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchiveBLPM WITH (NOLOCK)
				WHERE	ArchiveBLPMKey = @ArhiveMediaID
		END
		
	IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'TV'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchiveClipKey AS ArchiveMediaKey,
						ClipTitle AS Title,
						CategoryGUID AS CategoryGuid,
						SubCategory1GUID AS SubCategory1Guid,
						SubCategory2GUID AS SubCategory2Guid,
						SubCategory3GUID AS SubCategory3Guid,
						Keywords,
						[Description],
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchiveClip WITH (NOLOCK)
				WHERE	ArchiveClipKey = @ArhiveMediaID
		END
	
	IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'NM'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchiveNMKey AS ArchiveMediaKey,
						Title,
						CategoryGUID AS CategoryGuid,
						SubCategory1GUID AS SubCategory1Guid,
						SubCategory2GUID AS SubCategory2Guid,
						SubCategory3GUID AS SubCategory3Guid,
						Keywords,
						[Description],
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchiveNM WITH (NOLOCK)
				WHERE	ArchiveNMKey = @ArhiveMediaID
		END
	
	IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'SM'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchiveSMKey AS ArchiveMediaKey,
						Title,
						CategoryGUID AS CategoryGuid,
						SubCategory1GUID AS SubCategory1Guid,
						SubCategory2GUID AS SubCategory2Guid,
						SubCategory3GUID AS SubCategory3Guid,
						Keywords,
						[Description],
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchiveSM WITH (NOLOCK)
				WHERE	ArchiveSMKey = @ArhiveMediaID
		END
		
	IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'TW'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchiveTweets_Key AS ArchiveMediaKey,
						Actor_DisplayName AS Title,
						CategoryGUID AS CategoryGuid,
						SubCategory1GUID AS SubCategory1Guid,
						SubCategory2GUID AS SubCategory2Guid,
						SubCategory3GUID AS SubCategory3Guid,
						Keywords,
						[Description],
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchiveTweets WITH (NOLOCK)
				WHERE	ArchiveTweets_Key = @ArhiveMediaID
		END
				
		IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'TM'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchiveTVEyesKey AS ArchiveMediaKey,
						Title,
						CategoryGUID AS CategoryGuid,
						SubCategory1GUID AS SubCategory1Guid,
						SubCategory2GUID AS SubCategory2Guid,
						SubCategory3GUID AS SubCategory3Guid,
						Keywords,
						[Description],
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchiveTVEyes WITH (NOLOCK)
				WHERE	ArchiveTVEyesKey = @ArhiveMediaID
		END		
				
		IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'MS'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchiveMiscKey AS ArchiveMediaKey,
						Title,
						CategoryGUID AS CategoryGuid,
						SubCategoryGUID1 AS SubCategory1Guid,
						SubCategoryGUID2 AS SubCategory2Guid,
						SubCategoryGUID3 AS SubCategory3Guid,
						Keywords,
						[Description],
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchiveMisc WITH (NOLOCK)
				WHERE	ArchiveMiscKey = @ArhiveMediaID
		END	
				
		IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'PQ'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchivePQKey AS ArchiveMediaKey,
						Title,
						CategoryGUID AS CategoryGuid,
						SubCategory1GUID AS SubCategory1Guid,
						SubCategory2GUID AS SubCategory2Guid,
						SubCategory3GUID AS SubCategory3Guid,
						Keywords,
						[Description],
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchivePQ WITH (NOLOCK)
				WHERE	ArchivePQKey = @ArhiveMediaID
		END		
				
		IF @ArhiveMediaID IS NOT NULL AND @DataModelType = 'IQR'
		BEGIN
				SELECT 
						@MediaType AS MediaType,
						v5SubMediaType AS SubMediaType,
						ArchiveRadioKey AS ArchiveMediaKey,
						Title,
						CategoryGUID AS CategoryGuid,
						SubCategory1GUID AS SubCategory1Guid,
						SubCategory2GUID AS SubCategory2Guid,
						SubCategory3GUID AS SubCategory3Guid,
						Keywords,
						[Description],
						@DisplayDescription AS DisplayDescription,
						@PositiveSentiment AS PositiveSentiment,
						@NegativeSentiment AS NegativeSentiment
				FROM
						IQMediaGroup.dbo.ArchiveRadio WITH (NOLOCK)
				WHERE	ArchiveRadioKey = @ArhiveMediaID
		END	
END
