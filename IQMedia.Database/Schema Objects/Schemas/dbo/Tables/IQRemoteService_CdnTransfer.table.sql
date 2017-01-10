CREATE TABLE [dbo].[IQRemoteService_CdnTransfer] (
    [ID]             UNIQUEIDENTIFIER NOT NULL,
    [Status]         VARCHAR (50)     NOT NULL,
    [RecorddileGuid] UNIQUEIDENTIFIER NOT NULL,
    [RemoteInputXml] XML              NOT NULL,
    [DateCreated]    DATETIME2 (7)    NULL,
    [LastModiFied]   DATETIME2 (7)    NULL
);

