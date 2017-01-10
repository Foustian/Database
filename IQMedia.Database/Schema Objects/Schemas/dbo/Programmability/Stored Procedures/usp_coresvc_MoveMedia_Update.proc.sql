CREATE PROCEDURE [dbo].[usp_coresvc_MoveMedia_Update]
(
	@ID	BIGINT,
	@RecordfileGUID	UNIQUEIDENTIFIER,
	@OriginRPID	INT,
	@OriginStatus	VARCHAR(20),
	@DestinationRPID	INT,
	@DestinationLocation	VARCHAR(250),
	@DestinationStatus	VARCHAR(20),
	@DestinationSite	VARCHAR(5),
	@UpdateOrigin	BIT
)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@UpdateOrigin=1)
		BEGIN

			UPDATE
					IQMove_Media
			SET
					OriginStatus = @OriginStatus,
					DateModified = SYSDATETIME()
			WHERE
					((@ID IS NULL AND _RecordFileGUID = @RecordfileGUID AND OriginRPID = @OriginRPID) OR
					(ID = @ID))

		END
	ELSE
		BEGIN

			UPDATE
					IQMove_Media
			SET
					DestinationRPID = @DestinationRPID,
					DestinationLocation = @DestinationLocation,
					DestinationStatus = @DestinationStatus,
					DestinationSite = @DestinationSite,
					DateModified = SYSDATETIME()
			WHERE
					((@ID IS NULL AND _RecordFileGUID = @RecordfileGUID AND OriginRPID = @OriginRPID) OR
					(ID = @ID))

		END

	SELECT @@ROWCOUNT

END