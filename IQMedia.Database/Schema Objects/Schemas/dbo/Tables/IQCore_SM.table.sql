CREATE TABLE [dbo].[IQCore_SM]
(
	[ArticleID] [varchar](50) NOT NULL,
	[_RootPathID] [int] NULL,
	[Location] [varchar](255) NULL,
	[Url] [varchar](max) NULL,
	[harvest_time] [datetime] NULL,
	[Status] [varchar](50) NOT NULL,
	[LastModified] [datetime] NULL,
	[MachineName]  VARCHAR(255)	 NULL
	CONSTRAINT [PK_IQCore_Sm] PRIMARY KEY(ArticleID)
)
GO



ALTER TABLE IQCore_SM
ADD CONSTRAINT FK_IQCore_Sm_IQCore_RootPath FOREIGN KEY([_RootPathID])REFERENCES IQCore_RootPath(ID)
GO


ALTER TABLE IQCore_SM
            ADD CONSTRAINT DF_IQCore_SM_LastModified
            DEFAULT (getdate()) FOR [LastModified]
GO
