CREATE TABLE [dbo].[ArchiveSM](
	[ArchiveSMKey] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](max) NOT NULL,
	[Keywords] [varchar](2048) NULL,
	[Description] [varchar](2048) NULL,
	[FirstName] [varchar](150) NULL,
	[LastName] [varchar](150) NULL,
	[CustomerGuid] [uniqueidentifier] NOT NULL,
	[ClientGuid] [uniqueidentifier] NOT NULL,
	[CategoryGuid] [uniqueidentifier] NOT NULL,
	[SubCategory1Guid] [uniqueidentifier] NULL,
	[SubCategory2Guid] [uniqueidentifier] NULL,
	[SubCategory3Guid] [uniqueidentifier] NULL,
	[ArticleID] [varchar](50) NOT NULL,
	[ArticleContent] [nvarchar](max) NULL,
	[Url] [varchar](max) NULL,
	[Harvest_Time] [datetime] NULL,
	[CompeteURL] [varchar](255) NULL,
	[HomeLink] [varchar](255) NULL,
	[Source_Category] [varchar](50) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Rating] [tinyint] NULL,
	[HighlightingText] [varchar](max) NULL,
	[Compete_Audience] [int] NULL,
	[IQAdShareValue] [decimal](18, 2) NULL,
	[Compete_Result] [varchar](1) NULL,
	[PositiveSentiment] [tinyint] NULL,
	[NegativeSentiment] [tinyint] NULL,
	[Number_Hits] [tinyint] NULL,
	[ThumbUrl] [varchar](max) NULL,
	[ArticleStats] [xml] NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_ArchiveSM] PRIMARY KEY CLUSTERED 
(
	[ArchiveSMKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO



