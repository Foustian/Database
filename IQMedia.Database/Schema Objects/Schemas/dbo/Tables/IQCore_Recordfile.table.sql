CREATE TABLE [dbo].[IQCore_Recordfile](
	[Guid] [uniqueidentifier] NOT NULL,
	[Location] [varchar](2048) NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[StartOffset] [int] NOT NULL,
	[EndOffset] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[LastModified] [datetime] NOT NULL,
	[_RecordingID] [int] NOT NULL,
	[_RecordfileTypeID] [int] NOT NULL,
	[_RootPathID] [int] NOT NULL,
	[_ParentGuid] [uniqueidentifier] NULL
) ON [PRIMARY]