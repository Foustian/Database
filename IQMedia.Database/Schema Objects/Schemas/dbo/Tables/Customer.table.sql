CREATE TABLE [dbo].[Customer](
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
	[PasswordAttempts] [tinyint] NULL,
	[LastPwdChangedDate] [datetime2] NULL,
	[RsetPwdEmailCount] [tinyint] NULL,
	[LastPwdRsetDate] [datetime2] NULL,
	[AnewstipUserID] [varchar](300) NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Client] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Client] ([ClientKey])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_Client]
GO
