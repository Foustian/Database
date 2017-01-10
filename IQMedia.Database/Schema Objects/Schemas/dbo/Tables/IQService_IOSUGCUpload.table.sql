CREATE TABLE [dbo].[IQService_IOSUGCUpload](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](500) NULL,
	[Description] [varchar](max) NULL,
	[Keywords] [varchar](max) NULL,
	[StartTime] [varchar](10) NULL,
	[EndTime] [varchar](10) NULL,
	[FileName] [varchar](250) NULL,
	[UDID] [varchar](50) NULL,
	[CustomerGUID] [uniqueidentifier] NULL,
	[RecordfileGUID] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[Status] [tinyint] NULL
) ON [PRIMARY]