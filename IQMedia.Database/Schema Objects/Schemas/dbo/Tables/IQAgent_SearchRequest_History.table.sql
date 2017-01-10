CREATE TABLE [dbo].[IQAgent_SearchRequest_History](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_SearchRequestID] [bigint] NOT NULL,
	[Version] [int] NOT NULL,
	[SearchRequest] [xml] NOT NULL,
	[Name] [varchar](150) NOT NULL,
	[DateCreated] [datetime] NOT NULL CONSTRAINT [DF_IQAgent_SearchRequest_History_DateCreated]  DEFAULT (getdate()),
	[v4SearchRequest] [xml] NULL,
 CONSTRAINT [PK_IQAgent_SearchRequest_History] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
