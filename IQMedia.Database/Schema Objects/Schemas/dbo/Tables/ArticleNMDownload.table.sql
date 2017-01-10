CREATE TABLE [dbo].[ArticleNMDownload]
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
ALTER TABLE ArticleNMDownload
            ADD CONSTRAINT DF_ArticleNMDownloadDLRequestDateTime
            DEFAULT (getdate()) FOR [DLRequestDateTime]

GO
ALTER TABLE ArticleNMDownload
            ADD CONSTRAINT DF_ArticleNMDownloadIsActive
            DEFAULT (1) FOR [IsActive]