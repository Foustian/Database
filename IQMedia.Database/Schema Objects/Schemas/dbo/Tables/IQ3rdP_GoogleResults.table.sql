CREATE TABLE [dbo].[IQ3rdP_GoogleResults](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[_ClientGUID] [uniqueidentifier] NOT NULL,
	[GoogleViewID] [varchar](10) NULL,
	[GoogleLocalDateTime] [datetime] NOT NULL,
	[Sessions] [int] NULL,
	[Users] [int] NULL,
	[Bounces] [int] NULL,
	[SessionDuration] [float] NULL,
	[AvgSessionDuration] [float] NULL,
	[OrganicSearches] [int] NULL,
	[PageViews] [int] NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [IQ_GoogleResults_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [IQ_GoogleResults_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [IQ_GoogleResults_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ_GoogleResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

