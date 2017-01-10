CREATE TABLE [dbo].[IQ_Instagram](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstagramName] [varchar](100) NOT NULL,
	[IsInstagramTag] [bit] NOT NULL,
	[Userid] [bigint] NULL,
	[UserFullName] [varchar](50) NULL,
	[UserPicture] [varchar](250) NULL,
	[UserBio] [varchar](250) NULL,
	[UserWebsite] [varchar](250) NULL,
	[MediaCount] [bigint] NULL,
	[Followers] [bigint] NULL,
	[Following] [int] NULL,
	[IsVerified] [bit] NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_Instagram_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_Instagram_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ_Instagram_IsActive]  DEFAULT ((1)),
	[IsDefault] [bit] NULL,
	[_ClientGuid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_IQ_Instagram] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

