CREATE TABLE [dbo].[IQ_Report_ItemPositions](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_ReportGUID] [uniqueidentifier] NOT NULL,
	[GroupTier1Value] [varchar](max) NOT NULL,
	[GroupTier2Value] [varchar](max) NULL,
	[_ArchiveMediaID] [bigint] NOT NULL,
	[Position] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_Report_SortOrders_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_Report_ItemPositions_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ_Report_SortOrders_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ_Report_ItemPositions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQ_Report_ItemPositions]  WITH CHECK ADD  CONSTRAINT [FK_IQ_Report_ItemPositions_ArchiveMediaID] FOREIGN KEY([_ArchiveMediaID])
REFERENCES [dbo].[IQArchive_Media] ([ID])
GO

ALTER TABLE [dbo].[IQ_Report_ItemPositions] CHECK CONSTRAINT [FK_IQ_Report_ItemPositions_ArchiveMediaID]
GO


