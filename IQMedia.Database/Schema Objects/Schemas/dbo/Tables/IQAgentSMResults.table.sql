CREATE TABLE [dbo].[IQAgent_SMResults](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IQAgentSearchRequestID] [bigint] NOT NULL,
	[_QueryVersion] [int] NULL,
	[SeqID] [varchar](50) NOT NULL,
	[link] [varchar](max) NOT NULL,
	[homelink] [varchar](255) NULL,
	[description] [nvarchar](max) NULL,
	[itemHarvestDate_DT] [datetime] NOT NULL,
	[feedCategories] [varchar](max) NULL,
	[feedClass] [varchar](50) NOT NULL,
	[feedRank] [int] NULL,
	[Number_Hits] [int] NULL,
	[HighlightingText] [xml] NULL,
	[Sentiment] [xml] NULL,
	[Compete_Audience] [int] NULL,
	[IQAdShareValue] [float] NULL,
	[Compete_Result] [char](1) NULL,
	[CompeteURL] [varchar](255) NULL,
	[Communication_flag] [bit] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[h_comm_flag] [bit] NULL,
	[i_comm_flag] [bit] NULL,
	[d_comm_flag] [bit] NULL,
	[w_comm_flag] [bit] NULL,
	[iqprominence] [decimal(18,6)] NULL,
	[iqprominencemultiplier] [decimal(18,6)] NULL,
	[ThumbUrl] [varchar(max)] NULL,
	[ArticleStats] [xml] NULL,
	[v5SubMediaType] [varchar](50) NULL
) ON [PRIMARY]


GO
ALTER TABLE [dbo].[IQAgent_SMResults]  WITH CHECK ADD  CONSTRAINT [FK_IQAgent_SMResults_IQAgent_SearchRequest] FOREIGN KEY([IQAgentSearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])