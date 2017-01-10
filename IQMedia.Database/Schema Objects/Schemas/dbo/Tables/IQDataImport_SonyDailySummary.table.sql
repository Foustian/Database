CREATE TABLE [dbo].[IQDataImport_SonyDailySummary](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Report_Date] [date] NULL,
	[_Artist_ID] [bigint] NULL,
	[SourceType] [char](1) NULL,
	[DailyCount] [bigint] NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQ3rdP_SonyDailySummary_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQ3rdP_IQ3rdP_SonyDailySummary_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQ3rdP_IQ3rdP_SonyDailySummary_IsActive]  DEFAULT ((1)),
	[Album] [nvarchar](300) NULL,
	[Album_ArtistID] [bigint] NULL,
	[Track] [nvarchar](300) NULL,
	[_Album_ID] [bigint] NULL,
	[AlbumTrackCd] [char](1) NULL,
 CONSTRAINT [PK_IQ3rdP_SonyDaySummary] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQDataImport_SonyDailySummary]  WITH CHECK ADD  CONSTRAINT [FK_IQ3rdP_SonyDailySummary_IQ3rdP_SonyAlbum] FOREIGN KEY([_Album_ID])
REFERENCES [dbo].[IQDataImport_SonyAlbum] ([ID])
GO

ALTER TABLE [dbo].[IQDataImport_SonyDailySummary] CHECK CONSTRAINT [FK_IQ3rdP_SonyDailySummary_IQ3rdP_SonyAlbum]
GO

ALTER TABLE [dbo].[IQDataImport_SonyDailySummary]  WITH CHECK ADD  CONSTRAINT [FK_IQ3rdP_SonyDailySummary_IQ3rdP_SonyArtist] FOREIGN KEY([_Artist_ID])
REFERENCES [dbo].[IQDataImport_SonyArtist] ([ID])
GO

ALTER TABLE [dbo].[IQDataImport_SonyDailySummary] CHECK CONSTRAINT [FK_IQ3rdP_SonyDailySummary_IQ3rdP_SonyArtist]
GO

