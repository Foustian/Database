CREATE TABLE [dbo].[ArticleSMDownload]
(
	[ID]					 BIGINT           IDENTITY (1, 1) NOT NULL,
    [ArticleID]              varchar(50) NOT NULL,
    [CustomerGuid]           UNIQUEIDENTIFIER NOT NULL,
    [DownloadStatus]         TINYINT          NOT NULL,
	[DownloadLocation]		 varchar(255)	  NULL,
    [DLRequestDateTime]      DATETIME         NULL,        
    [DownLoadedDateTime]     DATETIME         NULL,
    [IsActive]               BIT              NOT NULL
)

GO
ALTER TABLE [ArticleSMDownload]
            ADD CONSTRAINT DF_ArticleSMDownloadDLRequestDateTime
            DEFAULT (getdate()) FOR [DLRequestDateTime]

GO
ALTER TABLE [ArticleSMDownload]
            ADD CONSTRAINT DF_ArticleSMDownloadIsActive
            DEFAULT (1) FOR [IsActive]