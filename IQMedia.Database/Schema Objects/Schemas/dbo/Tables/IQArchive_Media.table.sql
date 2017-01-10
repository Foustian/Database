CREATE TABLE [dbo].[IQArchive_Media](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_ArchiveMediaID] [bigint] NOT NULL,
	[MediaType] [varchar](2) NOT NULL,
	[Title] [nvarchar](max) NULL,
	[SubMediaType] [varchar](50) NULL,
	[CategoryGUID] [uniqueidentifier] NULL,
	[SubCategory1GUID] [uniqueidentifier] NULL,
	[SubCategory2GUID] [uniqueidentifier] NULL,
	[SubCategory3GUID] [uniqueidentifier] NULL,
	[HighlightingText] [nvarchar](max) NULL,
	[MediaDate] [datetime] NOT NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[CustomerGUID] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[PositiveSentiment] [tinyint] NULL,
	[NegativeSentiment] [tinyint] NULL,
	[_ParentID] [bigint] NULL,
	[Content] [nvarchar](max) NULL,
	[DisplayDescription] [bit] NULL CONSTRAINT [DF_IQArchive_Media_DisplayDescription]  DEFAULT ((0)),
	[v5MediaType] [varchar](2) NOT NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_IQArchive_Media] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_IQArchive_Media_ArchiveMediaID_MediaType] UNIQUE NONCLUSTERED 
(
	[_ArchiveMediaID] ASC,
	[MediaType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[IQArchive_Media]  WITH CHECK ADD  CONSTRAINT [FK_IQArchive_Media_IQArchive_Media] FOREIGN KEY([ID])
REFERENCES [dbo].[IQArchive_Media] ([ID])
GO
ALTER TABLE [dbo].[IQArchive_Media] CHECK CONSTRAINT [FK_IQArchive_Media_IQArchive_Media]
GO