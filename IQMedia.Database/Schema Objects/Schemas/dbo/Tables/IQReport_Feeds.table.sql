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
	[MetaDataMachineName] [varchar](255) NULL,
	[JobTypeID] [bigint] NULL,
	[SubCategory1Guid] [uniqueidentifier] NULL,
	[SubCategory2Guid] [uniqueidentifier] NULL,
	[SubCategory3Guid] [uniqueidentifier] NULL,
	[FailedClipXml] [xml] NULL,
	[NumMetaDataPasses] [smallint] NOT NULL CONSTRAINT [DF_IQReport_Feeds_NumMetaDataPasses]  DEFAULT ((0)),
 CONSTRAINT [PK_IQReport_Feeds] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQReport_Feeds] ADD  CONSTRAINT [DF_IQReport_Feeds_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[IQReport_Feeds] ADD  CONSTRAINT [DF_IQReport_Feeds_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [dbo].[IQReport_Feeds] ADD  CONSTRAINT [DF_IQReport_Feeds_LastModified]  DEFAULT (getdate()) FOR [LastModified]
GO

