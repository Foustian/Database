CREATE TABLE [dbo].[IQCore_NM] (
    [ArticleID]    VARCHAR (50)  NOT NULL,
    [_RootPathID]  INT           NULL,
    [Location]     VARCHAR (255) NULL,
    [Url]          VARCHAR (MAX) NULL,
    [harvest_time] DATETIME      NULL,
    [Status]       VARCHAR (50)  NOT NULL,
    [LastModified] DATETIME      NULL,
	[MachineName]  VARCHAR(255)	 NULL
);

