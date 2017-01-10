CREATE TABLE [dbo].[IQCore_RootPath](
	[ID] [int] NOT NULL,
	[Comment] [varchar](255) NOT NULL,
	[StoragePath] [varchar](255) NOT NULL,
	[StreamSuffixPath] [varchar](255) NOT NULL,
	[AppName] [varchar](255) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[_RootPathTypeID] [int] NOT NULL
) ON [PRIMARY]