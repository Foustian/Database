CREATE TABLE [dbo].[IQAgent_HourSummary]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientGuid] [uniqueidentifier] NOT NULL,
	[HourDateTime] [datetime] NOT NULL,
	[MediaType] [varchar](20) NOT NULL,
	[_SearchRequestID] [bigint] NULL,
	[NoOfDocs] [int] NOT NULL,
	[NoOfHits] [bigint] NOT NULL,
	[Audience] [bigint] NOT NULL,
	[IQMediaValue] [decimal](18, 2) NOT NULL,
	[PositiveSentiment] [int] NULL,
	[NegativeSentiment] [int] NULL,
	[SubMediaType] [varchar](20) NULL
)
