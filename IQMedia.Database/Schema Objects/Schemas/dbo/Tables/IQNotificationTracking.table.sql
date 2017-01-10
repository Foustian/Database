CREATE TABLE [dbo].[IQNotificationTracking] (
    [IQNotificationTrackingKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [SearchRequestID]           BIGINT        NULL,
    [TypeofEntry]               VARCHAR (10)  NULL,
    [Notification_Address]      VARCHAR (50)  NULL,
    [Frequency]                 VARCHAR (25)  NULL,
    [Processed_Flag]            INT           NULL,
    [Processed_DateTime]        DATETIME      NULL,
    [CreatedDate]               DATETIME      NULL,
    [ModifiedDate]              DATETIME      NULL,
    [CreatedBy]                 VARCHAR (150) NULL,
    [ModifiedBy]                VARCHAR (150) NULL,
    [IsActive]                  BIT           NULL,
	[ResultIDs] [xml] NULL
);

