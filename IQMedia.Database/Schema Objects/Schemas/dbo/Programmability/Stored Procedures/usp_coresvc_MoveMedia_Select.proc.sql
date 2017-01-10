CREATE PROCEDURE [dbo].[usp_coresvc_MoveMedia_Select]
(
	@OriginSite	VARCHAR(5),
	@DestinationSite VARCHAR(5),
	@OriginStatus VARCHAR(20),
	@DestinationStatus VARCHAR(20),
	@NumRecords INT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			TOP(@NumRecords)
			ID,
			_RecordFileGUID,
			OriginRPID,
			OriginLocation,
			OriginStatus,
			OriginSite,
			DestinationRPID,
			DestinationLocation,
			DestinationStatus,
			DestinationSite,
			DateCreated,
			DateModified			
	FROM
			IQMove_Media
	WHERE
			(@OriginSite IS NULL OR @OriginSite = ''  OR OriginSite = @OriginSite)
		AND	(@DestinationSite IS NULL OR @DestinationSite = '' OR DestinationSite = @DestinationSite)
		AND	(@OriginStatus IS NULL OR @OriginStatus = '' OR OriginStatus = @OriginStatus)
		AND (@DestinationStatus IS NULL OR @DestinationStatus = '' OR DestinationStatus = @DestinationStatus)

	ORDER BY
			ID ASC

END