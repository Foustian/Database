CREATE TABLE [dbo].[IQDiscovery_ToFeeds](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MediaXml] [xml] NOT NULL,
	[Processed_DateTime] [datetime] NULL,
	[Processed_Flag] [int] NULL,
	[ClientGuid] [uniqueidentifier] NOT NULL,
	[CustomerGuid] [uniqueidentifier] NOT NULL,
	[_ReportID] [bigint] NULL,
	[_IQAgentSearchRequestID] [bigint] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_IQDiscovery_ToFeeds] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)ON [PRIMARY]
) ON [PRIMARY]
