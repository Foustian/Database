CREATE TABLE [dbo].[IQAgent_MissingArticles](
	[ID] [bigint] IDENTITY(5000000,1) NOT NULL,
	[_SearchRequestID] [bigint] NOT NULL,
	[_CustomerGUID] [uniqueidentifier] NOT NULL,
	[Url] [varchar](255) NULL,
	[Title] [nvarchar](max) NULL,
	[harvest_time] [datetime] NOT NULL,
	[Content] [nvarchar](max) NULL,
	[Category] [varchar](50) NOT NULL,
	[Request_datetime] [datetime] NOT NULL,
	[Processed_flag] [bit] NULL,
	[Processed_datetime] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[AddToLibrary] [bit] NOT NULL CONSTRAINT [DF_IQAgent_MissingArticles_AddToLibrary]  DEFAULT ((0)),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQAgent_MissingArticles_IsActive]  DEFAULT ((1)),
	[LibraryCategory] uniqueidentifier NULL,
 CONSTRAINT [PK_IQAgent_MissingArticles] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]