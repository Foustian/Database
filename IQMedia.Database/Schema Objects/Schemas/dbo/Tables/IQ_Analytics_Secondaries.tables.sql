CREATE TABLE [dbo].[IQ_Analytics_Secondaries](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MainTabs] [varchar](200) NULL,
	[GroupBy] [varchar](50) NOT NULL,
	[ColumnHeaders] [varchar](500) NULL,
	[ColumnHeadersLR] [varchar](500) NULL,
	[ColumnHeadersAds] [varchar](500) NULL,
	[ColumnHeadersAdsLR] [varchar](500) NULL,
	[GroupByHeader] [varchar](50) NULL,
	[GroupByDisplay] [varchar](50) NULL,
	[TabDisplay] [varchar](50) NULL,
	[PageType] [varchar](50) NULL,
 CONSTRAINT [PK__IQ_Analy__3214EC272464915B] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]