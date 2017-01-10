CREATE TABLE [dbo].[IQAgent_TVEyesResults](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SearchRequestID] [bigint] NULL,
	[_QueryVersion] [int] NULL,
	[StationID] [varchar](50) NULL,
	[StationName] [varchar](150) NULL,
	[Market] [varchar](150) NULL,
	[DMARank] [varchar](5) NULL,
	[LocalDateTime] [datetime] NULL,
	[UTCDateTime] [datetime] NULL,
	[TimeZone] [varchar](10) NULL,
	[PlayerUrl] [varchar](255) NULL,
	[TranscriptUrl] [varchar](255) NULL,
	[StationIDNum] [varchar](50) NULL,
	[Duration] [int] NULL,
	[CC_Highlight] [xml] NULL,
	[Sentiment] [xml] NULL,
	[FileLocation] [varchar](255) NULL,
	[h_comm_flag] [bit] NULL,
	[i_Comm_flag] [bit] NULL,
	[d_Comm_flag] [bit] NULL,
	[w_Comm_flag] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_IQAgent_TVEyesResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IQAgent_TVEyesResults]  WITH CHECK ADD  CONSTRAINT [FK_IQAgent_TVEyesResults_IQAgent_SearchRequest] FOREIGN KEY([SearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO
ALTER TABLE [dbo].[IQAgent_TVEyesResults] CHECK CONSTRAINT [FK_IQAgent_TVEyesResults_IQAgent_SearchRequest]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesResults] ADD  CONSTRAINT [DF_IQAgent_TVEyesResults_h_Comm_flag]  DEFAULT ((0)) FOR [h_comm_flag]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesResults] ADD  CONSTRAINT [DF_IQAgent_TVEyesResults_i_Comm_flag]  DEFAULT ((0)) FOR [i_Comm_flag]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesResults] ADD  CONSTRAINT [DF_IQAgent_TVEyesResults_d_Comm_flag]  DEFAULT ((0)) FOR [d_Comm_flag]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesResults] ADD  CONSTRAINT [DF_IQAgent_TVEyesResults_w_Comm_flag]  DEFAULT ((0)) FOR [w_Comm_flag]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesResults] ADD  CONSTRAINT [DF_IQAgent_TVEyesResults_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesResults] ADD  CONSTRAINT [DF_IQAgent_TVEyesResults_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesResults] ADD  CONSTRAINT [DF_IQAgent_TVEyesResults_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO