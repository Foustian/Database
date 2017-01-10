CREATE TABLE [dbo].[IQAgent_BLPMResults]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_ArchiveBLPMID] [bigint] NOT NULL,
	[SearchRequestID] [bigint] NULL,
	[_QueryVersion] [int] NULL,
	[BLID] [varchar](50) NULL,
	[Headline] [varchar](255) NULL,
	[PubDate] [datetime] NULL,
	[Author] [varchar](50) NULL,
	[Pub_State] [varchar](50) NULL,
	[Pub_Name] [varchar](250) NULL,
	[Pub_freq] [varchar](10) NULL,
	[Pub_ed_office] [varchar](250) NULL,
	[DMA] [int] NULL,
	[Text] [varchar](max) NULL,
	[BLPMxml] [xml] NULL,
	[FileLocation] [varchar](250) NULL,
	[Circulation] [int] NULL,
	[RPID] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_IQAgent_BLPMResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]