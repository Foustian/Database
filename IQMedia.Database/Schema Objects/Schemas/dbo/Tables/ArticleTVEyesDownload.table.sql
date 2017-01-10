CREATE TABLE [dbo].[ArticleTVEyesDownload]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ArticleID] [varchar](50) NOT NULL,
	[CustomerGuid] [uniqueidentifier] NOT NULL,
	[DownloadStatus] [tinyint] NOT NULL,
	[DownloadLocation] [varchar](255) NULL,
	[DLRequestDateTime] [datetime] NULL,
	[DownLoadedDateTime] [datetime] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ArticleTVEyesDownload] ADD  CONSTRAINT [DF_ArticleTVEyesDownloadLRequestDateTime]  DEFAULT (getdate()) FOR [DLRequestDateTime]
GO

ALTER TABLE [dbo].[ArticleTVEyesDownload] ADD  CONSTRAINT [DF_ArticleTVEyesDownloadIsActive]  DEFAULT ((1)) FOR [IsActive]
GO