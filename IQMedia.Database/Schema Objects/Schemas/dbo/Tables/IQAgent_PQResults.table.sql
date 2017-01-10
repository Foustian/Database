CREATE TABLE [dbo].[IQAgent_PQResults](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IQAgentSearchRequestID] [bigint] NOT NULL,
	[_QueryVersion] [int] NULL,
	[ProQuestID] [varchar](50) NOT NULL,
	[Publication] [varchar](255) NULL,
	[Title] [nvarchar](max) NULL,
	[AvailableDate] [datetime] NOT NULL,
	[MediaDate] [datetime] NOT NULL,
	[MediaCategory] [varchar](250) NOT NULL,
	[Number_Hits] [int] NULL,
	[LanguageNum] [smallint] NULL,
	[Authors] [xml] NULL,
	[Copyright] [varchar](250) NULL,
	[ContentHTML] [varchar](max) NULL,
	[HighlightingText] [xml] NULL,
	[Sentiment] [xml] NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQAgent_PQResults_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQAgent_PQResults_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQAgent_PQResults_IsActive]  DEFAULT ((1)),
	[i_comm_flag] [bit] NULL CONSTRAINT [DF_IQAgent_PQResults_i_Comm_flag]  DEFAULT ((0)),
	[h_comm_flag] [bit] NULL CONSTRAINT [DF_IQAgent_PQResults_h_Comm_flag]  DEFAULT ((0)),
	[d_comm_flag] [bit] NULL CONSTRAINT [DF_IQAgent_PQResults_d_Comm_flag]  DEFAULT ((0)),
	[w_comm_flag] [bit] NULL CONSTRAINT [DF_IQAgent_PQResults_w_Comm_flag]  DEFAULT ((0)),
	[IQProminence] [decimal](18, 6) NULL,
	[IQProminenceMultiplier] [decimal](18, 6) NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_IQAgent_PQResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQAgent_PQResults]  WITH CHECK ADD  CONSTRAINT [FK_IQAgent_PQResults_IQAgentSearchRequestID] FOREIGN KEY([IQAgentSearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO

ALTER TABLE [dbo].[IQAgent_PQResults] CHECK CONSTRAINT [FK_IQAgent_PQResults_IQAgentSearchRequestID]
GO

