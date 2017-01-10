CREATE TABLE [dbo].[IQ_LR_Station_Control](
	[ID] [bigint] NOT NULL,
	[StationID] [varchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_LR_Station_Control_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_LR_Station_Control_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [smallint] NOT NULL CONSTRAINT [DF_IQ_LR_Station_Control_IsActive]  DEFAULT ((1)),
	[ProcessServerIP] [varchar](25) NULL,
 CONSTRAINT [PK_IQ_LR_Station_Control] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQ_LR_Station_Control]  WITH CHECK ADD  CONSTRAINT [FK_IQ_LR_Station_Control_StationID] FOREIGN KEY([StationID])
REFERENCES [dbo].[IQ_Station] ([IQ_Station_ID])
GO

ALTER TABLE [dbo].[IQ_LR_Station_Control] CHECK CONSTRAINT [FK_IQ_LR_Station_Control_StationID]
GO

