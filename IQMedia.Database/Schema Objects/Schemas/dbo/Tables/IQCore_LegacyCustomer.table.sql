CREATE TABLE [dbo].[IQCore_LegacyCustomer](
	[Guid] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[Password] [nvarchar](128) NOT NULL,
	[Email] [nvarchar](256) NOT NULL,
	[FullName] [nvarchar](256) NULL,
	[FirstName] [nvarchar](128) NULL,
	[LastName] [nvarchar](128) NULL,
	[IsLockedOut] [bit] NOT NULL,
	[_ClientGuid] [uniqueidentifier] NOT NULL,
	[Comment] [ntext] NULL,
	[CreatedBy] [nvarchar](128) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [nvarchar](128) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[CustomerName] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]