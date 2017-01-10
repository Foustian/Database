CREATE TABLE [dbo].[IQMove_Media]
(
	[ID]	BIGINT IDENTITY(1,1) NOT NULL,
	[_RecordFileGUID]	UNIQUEIDENTIFIER NOT NULL,
	[OriginLocation]	VARCHAR(250) NOT NULL,
	[OriginStatus]	VARCHAR(20) NOT NULL,
	[OriginRPID]	INT NOT NULL,
	[OriginSite]	VARCHAR(5) NOT NULL,
	[DestinationLocation]	VARCHAR(250) NULL,
	[DestinationStatus]	VARCHAR(20) NULL,
	[DestinationRPID]	INT NULL,
	[DestinationSite]	VARCHAR(5) NULL,
	[DateCreated]	DATETIME2(7) NOT NULL,
	[DateModified]	DATETIME2(7) NULL
)
