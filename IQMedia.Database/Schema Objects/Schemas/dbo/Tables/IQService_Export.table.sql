CREATE TABLE [dbo].[IQService_Export] (
    [ID]               UNIQUEIDENTIFIER NOT NULL,
    [ClipGuid]         UNIQUEIDENTIFIER NOT NULL,
    [OutputExt]        VARCHAR (4)      NOT NULL,
    [OutputPath]       VARCHAR (2048)   NULL,
    [OutputDimensions] VARCHAR (10)     NULL,
    [Status]           VARCHAR (255)    NOT NULL,
    [DateQueued]       DATETIME2 (7)    NOT NULL,
    [LastModified]     DATETIME2 (7)    NOT NULL,
	[MachineName]	   VARchar(255)		NULL
);

