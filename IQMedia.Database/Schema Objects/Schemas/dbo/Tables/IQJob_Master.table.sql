CREATE TABLE [dbo].[IQJob_Master](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_RequestID] [bigint] NOT NULL,
	[_TypeID] [bigint] NOT NULL,
	[_CustomerGuid] [uniqueidentifier] NOT NULL,
	[_Title] [varchar](255) NULL,
	[_RequestedDateTime] [datetime] NOT NULL,
	[_CompletedDateTime] [datetime] NULL,
	[_DownloadPath] [varchar](255) NULL,
	[Status] [varchar](50) NOT NULL,
	[_RootPathID] [int] NULL
) ON [PRIMARY]
