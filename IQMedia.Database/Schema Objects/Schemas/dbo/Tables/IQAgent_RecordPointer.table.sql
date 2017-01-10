CREATE TABLE [dbo].[IQAgent_RecordPointer]
(
	[ID] [bigint] NOT NULL,
	[_SearchRequestID] [bigint] NOT NULL,
	[_MediaID] [bigint] NOT NULL,
	[MediaType] [varchar](15) NOT NULL,
	[DateCreated] [datetime] NOT NULL
) ON [PRIMARY]
