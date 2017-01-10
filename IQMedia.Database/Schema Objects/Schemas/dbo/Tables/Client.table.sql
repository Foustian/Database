CREATE TABLE [dbo].[Client](
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
	[IsFliq] bit NULL,
	[_GroupID] [tinyint] NULL,
	[IQAgentGroup] [varchar](2) NULL,
	[AnewstipClientID] [bigint] NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[ClientKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Client] UNIQUE NONCLUSTERED 
(
	[ClientGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Client]  WITH NOCHECK ADD  CONSTRAINT [FK_Client_BillFrequency] FOREIGN KEY([BillFrequencyID])
REFERENCES [dbo].[BillFrequency] ([BillFrequencyKey])
GO

ALTER TABLE [dbo].[Client] NOCHECK CONSTRAINT [FK_Client_BillFrequency]
GO

ALTER TABLE [dbo].[Client]  WITH NOCHECK ADD  CONSTRAINT [FK_Client_BillType] FOREIGN KEY([BillTypeID])
REFERENCES [dbo].[BillType] ([BillTypeKey])
GO

ALTER TABLE [dbo].[Client] NOCHECK CONSTRAINT [FK_Client_BillType]
GO

ALTER TABLE [dbo].[Client]  WITH NOCHECK ADD  CONSTRAINT [FK_Client_Industry] FOREIGN KEY([IndustryID])
REFERENCES [dbo].[Industry] ([IndustryKey])
GO

ALTER TABLE [dbo].[Client] NOCHECK CONSTRAINT [FK_Client_Industry]
GO

ALTER TABLE [dbo].[Client]  WITH NOCHECK ADD  CONSTRAINT [FK_Client_PricingCode] FOREIGN KEY([PricingCodeID])
REFERENCES [dbo].[PricingCode] ([PricingCodeKey])
GO

ALTER TABLE [dbo].[Client] NOCHECK CONSTRAINT [FK_Client_PricingCode]
GO

ALTER TABLE [dbo].[Client]  WITH NOCHECK ADD  CONSTRAINT [FK_Client_State] FOREIGN KEY([StateID])
REFERENCES [dbo].[State] ([StateKey])
GO

ALTER TABLE [dbo].[Client] NOCHECK CONSTRAINT [FK_Client_State]
GO

