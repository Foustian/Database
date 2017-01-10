CREATE TABLE [dbo].[IQ_LR_Results](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IQ_CC_Key] [varchar](50) NOT NULL,
	[StationID] [varchar](20) NULL,
	[RecordFileGUID] [uniqueidentifier] NULL,
	[StationDT] [datetime] NULL,
	[iQClass] [varchar](20) NULL,
	[Title120] [varchar](100) NULL,
	[_SearchLogoID] [bigint] NOT NULL,
	[Hits] [xml] NOT NULL,
	[Hit_Count] [smallint] NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_LR_Results_CreatedDate]  DEFAULT (getdate()),
	[IsActive] [smallint] NOT NULL CONSTRAINT [DF_IQ_LR_Results_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ_LR_Results] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IQ_LR_Results_IQ_CC_Key_LogogID] ON [dbo].[IQ_LR_Results]
(
	[IQ_CC_Key] ASC,
	[_SearchLogoID] ASC
)
INCLUDE ( 	[ID],
	[StationID],
	[RecordFileGUID],
	[StationDT],
	[iQClass],
	[Title120],
	[Hit_Count],
	[IsActive]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IQ_LR_Results_logoID] ON [dbo].[IQ_LR_Results]
(
	[_SearchLogoID] ASC
)
INCLUDE ( 	[IQ_CC_Key]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_IQ_LR_Results_StationID] ON [dbo].[IQ_LR_Results]
(
	[StationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

