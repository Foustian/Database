CREATE TABLE [dbo].[ClipDownloadSettings] (
    [IQ_ClipDownloadSettings_Key] BIGINT           IDENTITY (1, 1) NOT NULL,
    [ClientGUID]                  UNIQUEIDENTIFIER NOT NULL,
    [AudioFormat]                 VARCHAR (5)      NOT NULL,
    [VideoFormat]                 VARCHAR (5)      NOT NULL,
    [ClipDownloadFileLocation]    VARCHAR (150)    NULL,
    [ClipFinalDestination]        VARCHAR (50)     NULL,
    [ClipTransportMode]           VARCHAR (50)     NULL,
    [CreatedBy]                   VARCHAR (50)     NULL,
    [ModifiedBy]                  VARCHAR (50)     NULL,
    [CreatedDate]                 DATETIME         NULL,
    [ModifiedDate]                DATETIME         NULL,
    [IsActive]                    BIT              NULL
);

