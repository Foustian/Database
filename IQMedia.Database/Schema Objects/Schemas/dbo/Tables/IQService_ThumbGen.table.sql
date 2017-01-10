CREATE TABLE [dbo].[IQService_ThumbGen] (
    [ID]           UNIQUEIDENTIFIER NOT NULL,
    [ClipGuid]     UNIQUEIDENTIFIER NOT NULL,
    [Offset]       INT              NULL,
    [Status]       VARCHAR (255)    NOT NULL,
    [DateQueued]   DATETIME         NOT NULL,
    [LastModified] DATETIME         NOT NULL,
	[MachineName]	VARCHAR (255)	NULL
);

