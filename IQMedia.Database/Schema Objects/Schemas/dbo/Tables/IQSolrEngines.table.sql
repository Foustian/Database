CREATE TABLE [dbo].[IQSolrEngines](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IPAddress] [varchar](50) NOT NULL,
	[BaseUrl] [varchar](255) NULL,
	[ShardsUrl] [varchar](max) NULL,
	[MediaType] [varchar](2) NOT NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQSolrEngines_IsActive]  DEFAULT ((1)),
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQSolrEngines_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQSolrEngines_ModifiedDate]  DEFAULT (getdate()),
	[Requestor] [varchar](50) NULL,
	[CoreState] [varchar](16) NULL,
	[JBossPort] [varchar](50) NULL,
	[CoreName] [varchar](50) NULL,
 CONSTRAINT [PK_IQSolrEngine] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
