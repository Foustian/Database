CREATE TABLE [dbo].[IQService_FeedsExport](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerGuid] [uniqueidentifier] NOT NULL,
	[IsSelectAll] [bit] NOT NULL,
	[SearchCriteria] [xml] NULL,
	[ArticleXml] [xml] NULL,
	[SortType] [varchar](20) NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[_RootPathID] [int] NULL,
	[DownloadPath] [varchar](255) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[MachineName] [varchar](255) NULL,
	[Title] [varchar](255) NULL,
	[GetTVUrl] [bit] NULL CONSTRAINT [DF_IQService_FeedsExport_GetTVUrl]  DEFAULT ((1)),
	[TVUrlXml] [xml] NULL,
	[NumPasses] [int] NULL CONSTRAINT [DF_IQService_FeedsExport_NumPasses]  DEFAULT ((0)),
 CONSTRAINT [PK_IQService_FeedsExport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
