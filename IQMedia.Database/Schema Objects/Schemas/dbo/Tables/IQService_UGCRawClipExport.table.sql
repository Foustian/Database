CREATE TABLE [dbo].[IQService_UGCRawClipExport] (
    [ID]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [ClipGUID]     UNIQUEIDENTIFIER NOT NULL,
    [Status]       VARCHAR (255)    NOT NULL,
    [DateQueued]   DATETIME         NOT NULL,
    [LastModified] DATETIME         NOT NULL,
	[OutputPath] [varchar](255) NULL,
);

