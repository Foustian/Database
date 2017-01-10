CREATE TABLE [dbo].[fliQ_Client](
	[ClientKey] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientName] [varchar](100) NULL,
	[AuthorizedVersion] [tinyint] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[PricingCodeID] [bigint] NULL,
	[BillFrequencyID] [bigint] NULL,
	[BillTypeID] [bigint] NULL,
	[IndustryID] [bigint] NULL,
	[StateID] [bigint] NULL,
	[Address1] [varchar](max) NULL,
	[Address2] [varchar](max) NULL,
	[City] [varchar](50) NULL,
	[Zip] [varchar](5) NULL,
	[Attention] [varchar](50) NULL,
	[Phone] [varchar](15) NULL,
	[MasterClient] [varchar](50) NULL,
	[NoOfUser] [int] NULL,
	[CDNUpload] [bit] NULL,
	[PlayerLogo] [varchar](500) NULL,
	[IsActivePlayerLogo] [bit] NULL,
	[UGCFtpUploadLocation] [varchar](255) NULL,
	[TimeZone] [varchar](3) NULL,
	[dst] [decimal](18, 2) NULL,
	[gmt] [decimal](18, 2) NULL,
	[MCID] [int] NULL,
 CONSTRAINT [PK_fliQ_Client] PRIMARY KEY CLUSTERED 
(
	[ClientKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_fliQ_Client] UNIQUE NONCLUSTERED 
(
	[ClientGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[fliQ_Client]  WITH CHECK ADD  CONSTRAINT [FK_fliQ_Client_BillFrequency] FOREIGN KEY([BillFrequencyID])
REFERENCES [dbo].[BillFrequency] ([BillFrequencyKey])
GO

ALTER TABLE [dbo].[fliQ_Client] CHECK CONSTRAINT [FK_fliQ_Client_BillFrequency]
GO

ALTER TABLE [dbo].[fliQ_Client]  WITH CHECK ADD  CONSTRAINT [FK_fliQ_Client_BillType] FOREIGN KEY([BillTypeID])
REFERENCES [dbo].[BillType] ([BillTypeKey])
GO

ALTER TABLE [dbo].[fliQ_Client] CHECK CONSTRAINT [FK_fliQ_Client_BillType]
GO

ALTER TABLE [dbo].[fliQ_Client]  WITH CHECK ADD  CONSTRAINT [FK_fliQ_Client_Industry] FOREIGN KEY([IndustryID])
REFERENCES [dbo].[Industry] ([IndustryKey])
GO

ALTER TABLE [dbo].[fliQ_Client] CHECK CONSTRAINT [FK_fliQ_Client_Industry]
GO

ALTER TABLE [dbo].[fliQ_Client]  WITH CHECK ADD  CONSTRAINT [FK_fliQ_Client_PricingCode] FOREIGN KEY([PricingCodeID])
REFERENCES [dbo].[PricingCode] ([PricingCodeKey])
GO

ALTER TABLE [dbo].[fliQ_Client] CHECK CONSTRAINT [FK_fliQ_Client_PricingCode]
GO

ALTER TABLE [dbo].[fliQ_Client]  WITH CHECK ADD  CONSTRAINT [FK_fliQ_Client_State] FOREIGN KEY([StateID])
REFERENCES [dbo].[State] ([StateKey])
GO

ALTER TABLE [dbo].[fliQ_Client] CHECK CONSTRAINT [FK_fliQ_Client_State]
GO

ALTER TABLE [dbo].[fliQ_Client] ADD  CONSTRAINT [DF_fliQ_Client_CreatedBy]  DEFAULT ('System') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[fliQ_Client] ADD  CONSTRAINT [DF_fliQ_Client_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO

ALTER TABLE [dbo].[fliQ_Client] ADD  CONSTRAINT [DF_fliQ_Client_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[fliQ_Client] ADD  CONSTRAINT [DF_fliQ_Client_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[fliQ_Client] ADD  CONSTRAINT [DF_fliQ_Client_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [dbo].[fliQ_Client] ADD  CONSTRAINT [DF_fliQ_Client_CDNUpload]  DEFAULT ((0)) FOR [CDNUpload]