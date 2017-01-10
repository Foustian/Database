CREATE TABLE [dbo].[UGCDownloadTracking] (
    [UGCDownloadTrackingKey] BIGINT           IDENTITY (1, 1) NOT NULL,
    [CustomerGUID]           UNIQUEIDENTIFIER NOT NULL,
    [UGCGUID]                UNIQUEIDENTIFIER NOT NULL,
    [DownloadedDateTime]     DATETIME         NOT NULL,
    [IsDownloadSuccess]      BIT              NOT NULL,
    [DownloadDescription]    VARCHAR (255)    NULL
);

