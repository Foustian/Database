CREATE TABLE [dbo].[IQService_CdnTransfer] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [RecordfileGuid] UNIQUEIDENTIFIER NOT NULL,
    [Direction]      VARCHAR (7)      NOT NULL,
    [Status]         VARCHAR (50)     NOT NULL,
    [DateCreated]    DATETIME2 (7)    NOT NULL,
    [LastModified]   DATETIME2 (7)    NOT NULL,
	[MachineName]    VARCHAR (255)    NULL
);

