CREATE TABLE [dbo].[IQService_DiscoveryExport]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerGuid] [uniqueidentifier] NOT NULL,
	[IsSelectAll] [bit] NOT NULL,
	[SearchCriteria] [xml] NULL,
	[ArticleXml] [xml] NULL,
	[Status] [varchar](50) NOT NULL,
	[DownloadPath] [varbinary](255) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_IQService_DiscoveryExport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]