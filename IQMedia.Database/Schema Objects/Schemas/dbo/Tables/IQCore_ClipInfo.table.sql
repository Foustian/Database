CREATE TABLE [dbo].[IQCore_ClipInfo](
	[_ClipGuid] [uniqueidentifier] NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[Category] [varchar](255) NOT NULL,
	[Keywords] [varchar](max) NOT NULL
) ON [PRIMARY]