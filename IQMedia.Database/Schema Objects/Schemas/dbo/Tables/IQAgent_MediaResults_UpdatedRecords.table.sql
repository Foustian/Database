CREATE TABLE [dbo].[IQAgent_MediaResults_UpdatedRecords](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_MediaResultID] [bigint] NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[NoOfHits] [int] NULL,
	[HighlightingText] [xml] NULL,
	[SolrStatus] [tinyint] NULL,
	[LastModified] [datetime2](7) NOT NULL CONSTRAINT [DF_IQAgent_MediaResults_UpdatedRecords_LastModified]  DEFAULT (sysdatetime()),
	[IsRead] [bit] NULL,
	[UpdateType] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQAgent_MediaResults_UpdatedRecords_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQAgent_MediaResults_UpdatedRecords] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


