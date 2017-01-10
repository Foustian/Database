CREATE TABLE [dbo].[IQReport_Discovery](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](255) NULL,
	[Keywords] [varchar](2048) NULL,
	[Description] [varchar](2048) NULL,
	[CategoryGUID] [uniqueidentifier] NULL,
	[MediaID] [xml] NULL,
	[ArchiveTracking] [xml] NULL,
	[Status] [varchar](20) NULL,
	[CustomerGUID] [uniqueidentifier] NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[ReportGUID] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[LastModified] [datetime] NULL,
	[GenerateMachineName] [varchar](255) NULL,
	[MetaDataMachineName] [varchar](255) NULL,
	[JobTypeID] [bigint] NULL,
	[NumMetaDataPasses] [smallint] NOT NULL CONSTRAINT [DF_IQReport_Discovery_NumMetaDataPasses]  DEFAULT ((0)),
	[v4MediaID] [xml] NULL,
 CONSTRAINT [PK_IQReport_Discovery] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQReport_Discovery] ADD  CONSTRAINT [DF_IQReport_Discovery_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[IQReport_Discovery] ADD  CONSTRAINT [DF_IQReport_Discovery_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [dbo].[IQReport_Discovery] ADD  CONSTRAINT [DF_IQReport_Discovery_LastModified]  DEFAULT (getdate()) FOR [LastModified]
GO

