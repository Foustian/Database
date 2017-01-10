CREATE TABLE [dbo].[IQGallery_Detail]
(
	[GUID] [uniqueidentifier] NOT NULL,
	[_ID] [bigint] NULL,
	[_ArchiveMediaID] [bigint] NULL,
	[Col] [int] NOT NULL,
	[Row] [int] NOT NULL,
	[_TypeID] [tinyint] NOT NULL,
	[MetaData] [varchar](max) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQGallery_Detail]  WITH CHECK ADD  CONSTRAINT [FK_IQGallery_Detail_IQGallery_ItemType] FOREIGN KEY([_TypeID])
REFERENCES [dbo].[IQGallery_ItemType] ([ID])
GO

ALTER TABLE [dbo].[IQGallery_Detail] CHECK CONSTRAINT [FK_IQGallery_Detail_IQGallery_ItemType]
GO

ALTER TABLE [dbo].[IQGallery_Detail]  WITH CHECK ADD  CONSTRAINT [FK_IQGallery_Detail_IQGallery_Master] FOREIGN KEY([_ID])
REFERENCES [dbo].[IQGallery_Master] ([ID])
GO

ALTER TABLE [dbo].[IQGallery_Detail] CHECK CONSTRAINT [FK_IQGallery_Detail_IQGallery_Master]
GO

ALTER TABLE [dbo].[IQGallery_Detail] ADD  CONSTRAINT [DF_IQGallery_Detail_GUID]  DEFAULT (newid()) FOR [GUID]
GO
