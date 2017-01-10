CREATE TABLE [dbo].[IQ_News](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Headline] [varchar](255) NOT NULL,
	[SubHead] [varchar](255) NULL,
	[Detail] [varchar](max) NOT NULL,
	[Url] [varchar](500) NOT NULL,
	[ReleaseDate] [date] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL
	)