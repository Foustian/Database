CREATE TABLE [dbo].[ArticleRadioDownload](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClipGuid] [uniqueidentifier] NOT NULL,
	[CustomerGUID] [uniqueidentifier] NOT NULL,
	[ClipDownloadStatus] [tinyint] NOT NULL,
	[ClipDLRequestDateTime] [datetime] NULL,
	[ClipDLFormat] [varchar](50) NULL,
	[ClipFileLocation] [varchar](150) NULL,
	[ClipDownLoadedDateTime] [datetime] NULL,
	[CCDownloadStatus] [bit] NULL,
	[CCDownloadedDateTime] [datetime2](7) NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ArticleRadioDownload_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ArticleRadioDownload_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_ArticleRadioDownload_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_ArticleRadioDownload] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO