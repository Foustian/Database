CREATE TABLE [dbo].[IQ_FBProfile](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[FBPageID] [bigint] NOT NULL,
	[FBPageName] [varchar](100) NULL,
	[FBLikes] [bigint] NULL,
	[FBLink] [varchar](250) NOT NULL,
	[FBCategory] [varchar](100) NULL,
	[FBIsVerified] [bit] NULL,
	[FBPicture] [varchar](250) NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_FBProfile_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_FBProfile_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ_FBProfile_IsActive]  DEFAULT ((1)),
	[IsDefault] [bit] NULL,
 CONSTRAINT [PK_IQ_FB_Setup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


