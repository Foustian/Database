CREATE TABLE [dbo].[IQService_Conversion] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Filename]     VARCHAR (255) NOT NULL,
	[ugc_upload_logKey] [bigint] NULL,
    [Status]       VARCHAR (255) NOT NULL,
	[_RecordFileGuid] [uniqueidentifier] NULL,
	[_ClipGuid] [uniqueidentifier] NULL,
	[DateQueued] [datetime2](7) NOT NULL,
	[LastModified] [datetime2](7) NOT NULL,
	[MachineName] VARCHAR(255) NULL,
 CONSTRAINT [PK_IQService_Conversion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

