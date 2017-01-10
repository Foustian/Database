CREATE TABLE [dbo].[fliQ_Customer](
	[CustomerKey] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[LoginID] [varchar](300) NULL,
	[Email] [varchar](300) NULL,
	[CustomerPassword] [varchar](60) NULL,
	[ContactNo] [varchar](50) NULL,
	[CustomerComment] [varchar](300) NULL,
	[ClientID] [bigint] NOT NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[CustomerGUID] [uniqueidentifier] NULL,
	[MultiLogin] [bit] NULL,
	[DefaultPage] [varchar](50) NULL,
	[MasterCustomerID] [bigint] NULL,
	[UDID] [varchar](40) NULL,
	[HasMobileRegd] [bit] NULL,
	[DateMobileRegd] [datetime] NULL,
	[DefaultCategory] [uniqueidentifier] NULL,
	[_CustomerID]	bigint NULL,
	[PasswordAttempts] TINYINT NULL
 CONSTRAINT [PK_fliQ_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[fliQ_Customer]  WITH CHECK ADD  CONSTRAINT [FK_fliQ_Customer_fliQ_Client] FOREIGN KEY([ClientID])
REFERENCES [dbo].[fliQ_Client] ([ClientKey])
GO

ALTER TABLE [dbo].[fliQ_Customer] CHECK CONSTRAINT [FK_fliQ_Customer_fliQ_Client]
GO

ALTER TABLE [dbo].[fliQ_Customer] ADD  CONSTRAINT [fliQ_Customer_default1]  DEFAULT ('System') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[fliQ_Customer] ADD  CONSTRAINT [fliQ_Customer_default]  DEFAULT ('System') FOR [ModifiedBy]
GO

ALTER TABLE [dbo].[fliQ_Customer] ADD  CONSTRAINT [DF_fliQ_Customer_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[fliQ_Customer] ADD  CONSTRAINT [DF_fliQ_Customer_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[fliQ_Customer] ADD  CONSTRAINT [DF_fliQ_Customer_IsActive]  DEFAULT ((1)) FOR [IsActive]