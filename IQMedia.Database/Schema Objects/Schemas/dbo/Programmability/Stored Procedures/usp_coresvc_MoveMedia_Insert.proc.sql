CREATE PROCEDURE [dbo].[usp_coresvc_MoveMedia_Insert]
(
	@RecordfileGUID	UNIQUEIDENTIFIER,
	@OriginRPID	INT,
	@OriginLocation	VARCHAR(250),
	@OriginStatus	VARCHAR(20),
	@OriginSite	VARCHAR(5),
	@DestinationRPID	INT,
	@DestinationLocation	VARCHAR(250),
	@DestinationStatus	VARCHAR(20),
	@DestinationSite	VARCHAR(5),
	@ID	BIGINT OUTPUT,
	@OutStatus INT	OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	/*
		Possible values of OutStatus are:
		1 (Default value) - record not inserted
		-1 - record exist with same RecordfileGUID and OriginRPID
		0 - record inserted successfully
	*/
	SET @OutStatus = 1
	SET @ID=0

	IF EXISTS(SELECT ID FROM IQMove_Media WHERE _RecordFileGUID=@RecordfileGUID AND OriginRPID=@OriginRPID)
		BEGIN
			SET @OutStatus = -1
		END
	ELSE
		BEGIN
				
			INSERT INTO IQMove_Media
			(
				_RecordFileGUID,
				OriginRPID,
				OriginLocation,
				OriginStatus,
				OriginSite,
				DestinationRPID,
				DestinationLocation,
				DestinationStatus,
				DestinationSite,
				DateCreated
			)
			VALUES
			(
				@RecordfileGUID,
				@OriginRPID,
				@OriginLocation,
				@OriginStatus,
				@OriginSite,
				@DestinationRPID,
				@DestinationLocation,
				@DestinationStatus,
				@DestinationSite,
				SYSDATETIME()
			)

			SET @OutStatus = 0

			SELECT @ID=SCOPE_IDENTITY()

		END	
END