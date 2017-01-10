CREATE TABLE [dbo].[IQDataImport_SonyAgent](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_SearchRequestID] [bigint] NOT NULL,
	[_Artist_ID] [bigint] NOT NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQ3rdP_SonyAgent_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQ3rdP_SonyAgent_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQ3rdP_SonyAgent_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ3rdP_SonyAgent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IQDataImport_SonyAgent]  WITH CHECK ADD  CONSTRAINT [FK_IQ3rdP_SonyAgent_IQ3rdP_SonyArtist] FOREIGN KEY([_Artist_ID])
REFERENCES [dbo].[IQDataImport_SonyArtist] ([ID])
GO

ALTER TABLE [dbo].[IQDataImport_SonyAgent] CHECK CONSTRAINT [FK_IQ3rdP_SonyAgent_IQ3rdP_SonyArtist]
GO

ALTER TABLE [dbo].[IQDataImport_SonyAgent]  WITH CHECK ADD  CONSTRAINT [FK_IQ3rdP_SonyAgent_IQAgent_SearchRequest] FOREIGN KEY([_SearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO

ALTER TABLE [dbo].[IQDataImport_SonyAgent] CHECK CONSTRAINT [FK_IQ3rdP_SonyAgent_IQAgent_SearchRequest]
GO

