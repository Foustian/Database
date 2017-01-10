CREATE TABLE [dbo].[IQReport_Feeds](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](255) NULL,
	[Keywords] [varchar](2048) NULL,
	[Description] [varchar](2048) NULL,
	[CategoryGuid] [uniqueidentifier] NULL,
	[MediaID] [xml] NULL,
	[ArchiveTracking] [xml] NULL,
	[Status] [varchar](20) NULL,
	[CustomerGuid] [uniqueidentifier] NULL,
	[ClientGuid] [uniqueidentifier] NULL,
	[ReportGUID] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[LastModified] [datetime] NULL,
	[GenerateMachineName] [varchar](255) NULL,
	[MetaDataMachineName] [varchar](255) NULL
)