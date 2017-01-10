CREATE TABLE [dbo].[ArchiveTVEyes](
	[ArchiveTVEyesKey] [bigint] IDENTITY(1,1) NOT NULL,
	[TMGuid] [uniqueidentifier] NULL,
	[_IQAgentID] [bigint] NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[CustomerGUID] [uniqueidentifier] NOT NULL,
	[CategoryGuid] [uniqueidentifier] NOT NULL,
	[SubCategory1Guid] [uniqueidentifier] NULL,
	[SubCategory2Guid] [uniqueidentifier] NULL,
	[SubCategory3Guid] [uniqueidentifier] NULL,
	[Title] [varchar](255) NULL,
	[Keywords] [varchar](2048) NULL,
	[Description] [varchar](2048) NULL,
	[Rating] [tinyint] NULL,
	[StationID] [varchar](50) NULL,
	[Market] [varchar](150) NULL,
	[DMARank] [varchar](5) NULL,
	[StationIDNum] [varchar](50) NULL,
	[Duration] [int] NULL,
	[Transcript] [nvarchar](max) NULL,
	[UTCDateTime] [datetime] NULL,
	[LocalDateTime] [datetime] NULL,
	[TimeZone] [varchar](10) NULL,
	[PositiveSentiment] [tinyint] NULL,
	[NegativeSentiment] [tinyint] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[Status] [varchar](50) NULL,
	[IsDownLoaded] [bit] NULL,
	[Response] [xml] NULL,
	[Media] [varchar](255) NULL,
	[Package] [varchar](255) NULL,
	[_RootPathID] [bigint] NULL,
	[Location] [varchar](255) NULL,
	[AudioFile] [varchar](50) NULL,
	[TranscriptFile] [varchar](50) NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_ArchiveTVEyes] PRIMARY KEY CLUSTERED 
(
	[ArchiveTVEyesKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ArchiveTVEyes] ADD  CONSTRAINT [DF_ArchiveTVEyes_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[ArchiveTVEyes] ADD  CONSTRAINT [DF_ArchiveTVEyes_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [dbo].[ArchiveTVEyes] ADD  CONSTRAINT [DF_ArchiveTVEyes_IsDownLoaded]  DEFAULT ((0)) FOR [IsDownLoaded]
GO


