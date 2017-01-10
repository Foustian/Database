CREATE TABLE [dbo].[ArchiveBLPMDownload](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MediaID] [bigint] NULL,
	[CustomerGuid] [uniqueidentifier] NULL,
	[DownloadStatus] [tinyint] NULL,
	[DownloadLocation] [varchar](255) NULL,
	[DLRequestDateTime] [datetime] NULL,
	[DownloadedDatetime] [datetime] NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]
