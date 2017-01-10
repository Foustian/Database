USE [IQMediaGroup]
GO

/****** Object:  Table [dbo].[IQAgent_RadioResults]    Script Date: 12/19/2016 2:01:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[IQAgent_RadioResults](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IQAgentSearchRequestID] [bigint] NOT NULL,
	[_QueryVersion] [int] NULL,
	[Title] [varchar](250) NULL,
	[IQ_CC_Key] [varchar](28) NULL,
	[Guid] [uniqueidentifier] NULL,
	[GMTDatetime] [datetime2](7) NULL,
	[LocalDatetime] [datetime2](7) NULL,
	[_StationID] [varchar](150) NULL,
	[Market] [varchar](150) NULL,
	[_IQDMAID] [int] NULL,
	[Number_Hits] [int] NULL,
	[HighlightingText] [xml] NULL,
	[Sentiment] [xml] NULL,
	[IQAgentResultUrl] [varchar](255) NULL,
	[v5SubMediaType] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQAgent_RadioResults_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQAgent_RadioResults_ModifiedDate]  DEFAULT (getdate()),
	[CreatedBy] [varchar](150) NULL CONSTRAINT [DF_IQAgent_RadioResults_CreatedBy]  DEFAULT ('System'),
	[ModifiedBy] [varchar](150) NULL CONSTRAINT [DF_IQAgent_RadioResults_ModifiedBy]  DEFAULT ('System'),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQAgent_RadioResults_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQAgent_RadioResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQAgent_RadioResults]  WITH CHECK ADD  CONSTRAINT [FK_IQAgent_RadioResults_IQAgentSearchRequestID] FOREIGN KEY([IQAgentSearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO

ALTER TABLE [dbo].[IQAgent_RadioResults] CHECK CONSTRAINT [FK_IQAgent_RadioResults_IQAgentSearchRequestID]
GO

ALTER TABLE [dbo].[IQAgent_RadioResults]  WITH CHECK ADD  CONSTRAINT [FK_IQAgent_RadioResults_IQDMAID] FOREIGN KEY([_IQDMAID])
REFERENCES [dbo].[IQDMA] ([ID])
GO

ALTER TABLE [dbo].[IQAgent_RadioResults] CHECK CONSTRAINT [FK_IQAgent_RadioResults_IQDMAID]
GO


