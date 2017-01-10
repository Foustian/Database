CREATE TABLE [dbo].[IQAgent_DeleteControl](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[clientGUID] [uniqueidentifier] NOT NULL,
	[statusUpdateData] [xml] NULL,
	[createdDate] [datetime] NOT NULL,
	[isDBUpdated] [varchar](10) NULL,
	[dbUpdateDate] [datetime] NULL,
	[isSolrUpdated] [varchar](10) NULL,
	[solrUpdateDate] [datetime] NULL,
	[searchRequestID] [bigint] NULL,
	[modifiedDate] [datetime] NULL,
	[customerGUID] [uniqueidentifier] NULL,
 CONSTRAINT [PK_IQAgent_DeleteControl] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQAgent_DeleteControl] ADD  CONSTRAINT [DF_IQAgent_DeleteControl_isDBUpdated]  DEFAULT ('QUEUED') FOR [isDBUpdated]
GO

ALTER TABLE [dbo].[IQAgent_DeleteControl] ADD  CONSTRAINT [DF_IQAgent_DeleteControl_isSolrUpdated]  DEFAULT ('QUEUED') FOR [isSolrUpdated]
GO

