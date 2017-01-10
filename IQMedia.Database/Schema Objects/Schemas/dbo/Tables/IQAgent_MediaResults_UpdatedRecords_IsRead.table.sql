CREATE TABLE [dbo].[IQAgent_MediaResults_UpdatedRecords_IsRead](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_MediaResultID] [bigint] NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[IsRead] [bit] NULL,
	[SolrStatus] [tinyint] NULL,
	[SolrUpdateDate] [datetime2](7) NULL,
	[LastModified] [datetime2](7) NOT NULL CONSTRAINT [DF_IQAgent_MediaResults_UpdatedReadRecords_LastModified]  DEFAULT (sysdatetime()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQAgent_MediaResults_UpdatedReadRecords_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQAgent_MediaResults_UpdatedReadRecords] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


