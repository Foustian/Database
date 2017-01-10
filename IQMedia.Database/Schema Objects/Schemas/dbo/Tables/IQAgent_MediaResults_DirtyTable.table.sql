CREATE TABLE [dbo].[IQAgent_MediaResults_DirtyTable](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MediaResultsID] [bigint] NOT NULL,
	[MediaID] [bigint] NOT NULL,
	[_SearchRequestID] [bigint] NOT NULL,
	[MediaType] [varchar](2) NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[MediaDate] [datetime] NOT NULL,
	[_ParentID] [bigint] NULL,
	[Number_Hits] [int] NULL,
	[Compete_Value] [bigint] NULL,
	[IQAdShareValue] [float] NULL,
	[PositiveSentiment] [tinyint] NULL,
	[NegativeSentiment] [tinyint] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO