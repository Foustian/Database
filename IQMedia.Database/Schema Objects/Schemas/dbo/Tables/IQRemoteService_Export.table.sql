CREATE TABLE [dbo].[IQRemoteService_Export] (
    [ID]               UNIQUEIDENTIFIER NOT NULL,
    [ClipGUID]         UNIQUEIDENTIFIER NOT NULL,
    [OutputExt]        VARCHAR (4)      NOT NULL,
    [OutputDimensions] VARCHAR (10)     NULL,
    [RemoteInputXml]   XML              NOT NULL,
    [Status]           VARCHAR (250)    NOT NULL,
    [DateQueued]       DATETIME2 (7)    NULL,
    [LastModiFied]     DATETIME2 (7)    NULL
);

