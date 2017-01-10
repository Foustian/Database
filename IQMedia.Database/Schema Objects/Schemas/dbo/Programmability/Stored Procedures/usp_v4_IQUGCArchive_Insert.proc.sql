CREATE PROCEDURE [dbo].[usp_v4_IQUGCArchive_Insert]
	@CategoryGUID [uniqueidentifier],
	@SubCategory1GUID [uniqueidentifier],
	@SubCategory2GUID [uniqueidentifier],
	@SubCategory3GUID [uniqueidentifier],
	@Title [varchar](2048),
	@Keywords [varchar](max),
	@Description [varchar](max),
	@DocumentDate [datetime],
	@DocumentTimeZone [varchar](3),
	@CustomerGUID [uniqueidentifier],
	@ClientGUID [uniqueidentifier],
	@FileType	[varchar](20),
	@_RootPathID [int],
	@Location [varchar](500),
	@ID [bigint] output
AS
BEGIN

	DECLARE @FileTypeID int

	SELECT @FileTypeID = ID
	FROM	IQUGC_FileTypes
	WHERE	FileTypeExt = @FileType
			AND IsActive = 1

	IF(@FileTypeID IS NOT NULL AND @FileTypeID > 0)
	BEGIN
		INSERT INTO IQUGCArchive
		(
			UGCGUID,
			CategoryGUID,
			SubCategory1GUID,
			SubCategory2GUID,
			SubCategory3GUID,
			Title,
			Keywords,
			[Description],
			CreateDT,
			AirDate,
			CreateDTTimeZone,
			CustomerGUID,
			ClientGUID,
			_RootPathID,
			Location,
			_FileTypeID,
			DateUploaded,
			CreatedDate,
			ModifiedDate,
			CreatedBy,
			ModifiedBy,
			IsActive
		)

		values
		(
			NEWID(),
			@CategoryGUID,
			@SubCategory1GUID,
			@SubCategory2GUID,
			@SubCategory3GUID,
			@Title,
			@Keywords,
			@Description,
			@DocumentDate,
			@DocumentDate,
			@DocumentTimeZone,
			@CustomerGUID,
			@ClientGUID,
			@_RootPathID,
			@Location,
			@FileTypeID,
			GETDATE(),
			GETDATE(),
			GETDATE(),
			'IQUGC_Process',
			'IQUGC_Process',
			1
		)

		SET @ID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SET @ID = -1
	END
END