CREATE TABLE [dbo].[ArchiveTweets](
	[ArchiveTweets_Key] [bigint] IDENTITY(1,1) NOT NULL,
	[Tweet_ID] [bigint] NOT NULL,
	[Actor_DisplayName] [nvarchar](50) NULL,
	[Actor_PreferredUserName] [nvarchar](50) NULL,
	[Tweet_Body] [nvarchar](max) NOT NULL,
	[Actor_FollowersCount] [bigint] NULL,
	[Actor_FriendsCount] [bigint] NULL,
	[Actor_Image] [varchar](max) NULL,
	[Actor_link] [varchar](max) NULL,
	[gnip_Klout_Score] [bigint] NULL,
	[Tweet_PostedDateTime] [datetime] NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[CustomerGUID] [uniqueidentifier] NOT NULL,
	[CategoryGuid] [uniqueidentifier] NOT NULL,
	[SubCategory1Guid] [uniqueidentifier] NULL,
	[SubCategory2Guid] [uniqueidentifier] NULL,
	[SubCategory3Guid] [uniqueidentifier] NULL,
	[Title] [varchar](250) NULL,
	[Keywords] [varchar](2048) NULL,
	[Description] [varchar](2048) NULL,
	[Rating] [tinyint] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[NegativeSentiment] [tinyint] NULL,
	[PositiveSentiment] [tinyint] NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_ArchiveTweets] PRIMARY KEY CLUSTERED 
(
	[ArchiveTweets_Key] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ArchiveTweets] ADD  CONSTRAINT [DF_ArchiveTweets_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[ArchiveTweets] ADD  CONSTRAINT [DF_ArchiveTweets_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO


