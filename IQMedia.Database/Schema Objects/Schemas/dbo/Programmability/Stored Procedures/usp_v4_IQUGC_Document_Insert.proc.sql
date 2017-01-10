CREATE PROCEDURE [dbo].[usp_v4_IQUGC_Document_Insert]
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
	@_RootPathID [int],
	@Location [varchar](500),
	@ID [bigint] output
AS
BEGIN
	
	INSERT INTO IQUGC_Document
	(
		CategoryGUID,
		SubCategory1GUID,
		SubCategory2GUID,
		SubCategory3GUID,
		Title,
		Keywords,
		[Description],
		DocumentDate,
		DocumentTimeZone,
		CustomerGUID,
		_RootPathID,
		Location,
		CreatedDate,
		ModifiedDate,
		IsActive
	)

	values
	(
		@CategoryGUID,
		@SubCategory1GUID,
		@SubCategory2GUID,
		@SubCategory3GUID,
		@Title,
		@Keywords,
		@Description,
		@DocumentDate,
		@DocumentTimeZone,
		@CustomerGUID,
		@_RootPathID,
		@Location,
		GETDATE(),
		GETDATE(),
		1
	)

	SET @ID = SCOPE_IDENTITY()
END