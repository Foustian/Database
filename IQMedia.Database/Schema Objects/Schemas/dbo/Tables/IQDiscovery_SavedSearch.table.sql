CREATE TABLE [dbo].[IQDiscovery_SavedSearch](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](max) NOT NULL,
	[SearchTerm] [xml] NOT NULL,
	[FromDate] [date] NULL,
	[ToDate] [date] NULL,
	[Medium] [varchar](10) NULL,
	[AdvanceSearchSettings] xml NULL,
	[TVMarket] [varchar](255) NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[CustomerGUID] [uniqueidentifier] NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[IsActive] [bit] NOT NULL,
	[SearchID] [xml] NOT NULL,
	[AdvanceSearchSettingIDs] [varchar](max) NULL,
 CONSTRAINT [PK_IQDiscovery_SavedSearch] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]