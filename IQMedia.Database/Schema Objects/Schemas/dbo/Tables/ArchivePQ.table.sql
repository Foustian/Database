CREATE TABLE [dbo].[ArchivePQ](
	[ArchivePQKey] [bigint] IDENTITY(1,1) NOT NULL,
	[ProQuestID] [varchar](25) NULL,
	[Title] [varchar](255) NULL,
	[Publication] [varchar](250) NULL,
	[Author] [xml] NULL,
	[MediaCategory] [varchar](50) NULL,
	[Content] [varchar](max) NULL,
	[ContentHTML] [varchar](max) NULL,
	[HighlightingText] [varchar](max) NULL,
	[AvailableDate] [date] NULL,
	[MediaDate] [date] NULL,
	[LanguageNum] [smallint] NULL,
	[Copyright] [varchar](250) NULL,
	[CategoryGUID] [uniqueidentifier] NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[CustomerGUID] [uniqueidentifier] NULL,
	[SubCategory1GUID] [uniqueidentifier] NULL,
	[SubCategory2GUID] [uniqueidentifier] NULL,
	[SubCategory3GUID] [uniqueidentifier] NULL,
	[PositiveSentiment] [tinyint] NULL,
	[NegativeSentiment] [tinyint] NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ArchivePQ_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ArchivePQ_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_ArchivePQ_IsActive]  DEFAULT ((1)),
	[Keywords] [varchar](2048) NULL,
	[Description] [varchar](2048) NULL,
	[Number_Hits] [tinyint] NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_ArchivePQ] PRIMARY KEY CLUSTERED 
(
	[ArchivePQKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

