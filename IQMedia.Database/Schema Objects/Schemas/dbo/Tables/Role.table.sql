CREATE TABLE [dbo].[Role] (
	[RoleKey] [bigint] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](50) NULL,
	[CreatedBy] [varchar](50) NULL CONSTRAINT [DF_Role_CreatedBy]  DEFAULT ('System'),
	[ModifiedBy] [varchar](50) NULL CONSTRAINT [DF_Role_ModifiedBy]  DEFAULT ('System'),
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_Role_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_Role_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [DF_Role_IsActive]  DEFAULT ((1)),
	[UIName] [varchar](50) NULL,
	[Description] [varchar](500) NULL,
	[IsEnabledInSetup] [bit] NOT NULL CONSTRAINT [DF_Role_IsEnabledInSetup]  DEFAULT ((1)),
	[GroupName] [varchar](100) NULL,
	[EnabledCustomerIDs] [varchar](max) NULL,
	[HasDefaultAccess] [bit] NOT NULL CONSTRAINT [DF_Role_HasDefaultAccess]  DEFAULT ((1)),
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[RoleKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

