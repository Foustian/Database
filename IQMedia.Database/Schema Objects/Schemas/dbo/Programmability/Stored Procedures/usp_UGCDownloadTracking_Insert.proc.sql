
CREATE PROCEDURE usp_UGCDownloadTracking_Insert
(
	@CustomerGUID		uniqueidentifier,
	@UGCGUID			uniqueidentifier,
	@DownloadedDateTime	datetime,
	@IsDownloadSuccess bit,
	@DownloadDescription	varchar(255),
	@UGCDownloadTrackingKey	bigint output
)
AS
BEGIN
	SET NOCOUNT ON;
	
	insert into UGCDownloadTracking
	(
		CustomerGUID,
		UGCGUID,
		DownloadedDateTime,
		IsDownloadSuccess,
		[DownloadDescription]
	)
	values
	(
		@CustomerGUID,
		@UGCGUID,
		@DownloadedDateTime,
		@IsDownloadSuccess,
		@DownloadDescription
	)
	
	Select @UGCDownloadTrackingKey=SCOPE_IDENTITY()


END
