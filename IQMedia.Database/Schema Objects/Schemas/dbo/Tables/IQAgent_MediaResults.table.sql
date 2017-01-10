CREATE TABLE [dbo].[IQAgent_MediaResults](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](max) NULL,
	[_MediaID] [bigint] NOT NULL,
	[MediaType] [varchar](2) NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[HighlightingText] [nvarchar](max) NULL,
	[MediaDate] [datetime] NOT NULL,
	[_SearchRequestID] [bigint] NOT NULL,
	[PositiveSentiment] [tinyint] NULL,
	[NegativeSentiment] [tinyint] NULL,
	[IsActive] [bit] NOT NULL,
	[_ParentID] [bigint] NULL,
	[IsRead] [bit] NOT NULL CONSTRAINT [DF_IQAgent_MediaResults_IsRead]  DEFAULT ((0)),
	[v5MediaType] [varchar](2) NULL,
	[v5Category] [varchar](50) NULL,
 CONSTRAINT [PK_IQAgent_MediaResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]