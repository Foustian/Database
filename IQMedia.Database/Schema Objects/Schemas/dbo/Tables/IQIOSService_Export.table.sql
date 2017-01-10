CREATE TABLE [dbo].[IQIOSService_Export] (
    [ID]           UNIQUEIDENTIFIER NOT NULL,
    [ClipGuid]     UNIQUEIDENTIFIER NOT NULL,
    [Status]       VARCHAR (50)     NOT NULL,
    [DateQueued]   DATETIME2 (7)    NOT NULL,
    [LastModified] DATETIME2 (7)    NOT NULL
);

