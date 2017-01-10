USE [IQMediaGroup]
GO

/****** Object:  Table [dbo].[IQAgent_AnalyticsHourSummary]    Script Date: 12/20/2016 09:18:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[IQAgent_AnalyticsHourSummary](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_ClientGuid] [uniqueidentifier] NOT NULL,
	[_SearchRequestID] [bigint] NOT NULL,
	[GMTHourDateTime] [datetime] NOT NULL,
	[MediaType] [varchar](20) NOT NULL,
	[SubMediaType] [varchar](20) NOT NULL,
	[Market] [varchar](150) NULL,
	[LocalHourDateTime] [datetime] NULL,
	[NumberOfDocs] [int] NULL,
	[NumberOfHits] [bigint] NULL,
	[AM18_20] [bigint] NULL,
	[AM21_24] [bigint] NULL,
	[AM25_34] [bigint] NULL,
	[AM35_49] [bigint] NULL,
	[AM50_54] [bigint] NULL,
	[AM55_64] [bigint] NULL,
	[AM65_Plus] [bigint] NULL,
	[AF18_20] [bigint] NULL,
	[AF21_24] [bigint] NULL,
	[AF25_34] [bigint] NULL,
	[AF35_49] [bigint] NULL,
	[AF50_54] [bigint] NULL,
	[AF55_64] [bigint] NULL,
	[AF65_Plus] [bigint] NULL,
	[TotalAudiences] [bigint] NULL,
	[IQMediaValue] [decimal](18, 2) NULL,
	[PositiveSentiment] [int] NULL,
	[NegativeSentiment] [int] NULL,
	[Seen_Earned] [bigint] NULL,
	[Seen_Paid] [bigint] NULL,
	[Heard_Earned] [bigint] NULL,
	[Heard_Paid] [bigint] NULL,
	[UndeterminedHits]  AS ((((isnull([NumberOfHits],(0))-isnull([Seen_Earned],(0)))-isnull([Seen_Paid],(0)))-isnull([Heard_Earned],(0)))-isnull([Heard_Paid],(0))) PERSISTED,
	[LastUpdated] [datetime] NULL,
	[NonUSANationalDMA_NumberOfDocs] [bigint] NULL,
	[NonUSANationalDMA_NumberOfHits] [bigint] NULL,
	[Heard_Inprogram] [int] NULL,
	[Seen_Inprogram] [int] NULL,
 CONSTRAINT [PK_IQAgent_AnalyticsHourSummary] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


