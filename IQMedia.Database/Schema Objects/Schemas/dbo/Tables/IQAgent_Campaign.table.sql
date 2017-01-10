CREATE TABLE [dbo].[IQAgent_Campaign](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](250) NULL,
	[_SearchRequestID] [bigint] NULL,
	[Query_Name] [varchar](max) NULL,
	[StartDatetime] [datetime] NULL,
	[EndDatetime] [datetime] NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQAgent_Campaign_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQAgent_Campaign_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [tinyint] NULL CONSTRAINT [DF_IQAgent_Campaign_IsActive]  DEFAULT ((1)),
	[Query_Version] [int] NULL,
	[StartDatetimeGMT] [datetime] NULL,
	[EndDatetimeGMT] [datetime] NULL,
 CONSTRAINT [PK_IQAgent_Campaign] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQAgent_Campaign]  WITH CHECK ADD  CONSTRAINT [FK_IQAgent_Campaign_SearchRequestID] FOREIGN KEY([_SearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO

ALTER TABLE [dbo].[IQAgent_Campaign] CHECK CONSTRAINT [FK_IQAgent_Campaign_SearchRequestID]
GO

