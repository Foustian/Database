CREATE TABLE [dbo].[IQCTSMSResults](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerPhoneNo] [varchar](11) NULL,
	[ReceivedDateTime] [datetime] NULL,
	[MsgText] [varchar](50) NULL,
	[IsProcessed] [bit] NULL,
	[ProcessedDatetime] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[MessageID] [varchar](50) NULL,
 CONSTRAINT [PK_IQCTSMSResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)ON [PRIMARY]
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[IQCTSMSResults] ADD  CONSTRAINT [DF_IQCTSMSResults_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO