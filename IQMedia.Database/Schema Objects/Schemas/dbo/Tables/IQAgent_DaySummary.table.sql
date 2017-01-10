CREATE TABLE [dbo].[IQAgent_DaySummary]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientGuid] [uniqueidentifier] NOT NULL,
	[DayDate] [date] NOT NULL,
	[MediaType] [varchar](20) NOT NULL,
	[_SearchRequestID] [bigint] NULL,
	[NoOfDocs] [int] NOT NULL,
	[NoOfHits] [bigint] NOT NULL,
	[Audience] [bigint] NOT NULL,
	[IQMediaValue] [decimal](18, 2) NOT NULL,
	[SubMediaType] [varchar](20) NULL,
	[PositiveSentiment] [int] NULL,
	[NegativeSentiment] [int] NULL,
	[NoOfDocsLD] [int] NULL,
	[NoOfHitsLD] [bigint] NULL,
	[AudienceLD] [bigint] NULL,
	[IQMediaValueLD] [decimal](18, 2) NULL,
	[PositiveSentimentLD] [int] NULL,
	[NegativeSentimentLD] [int] NULL
)
