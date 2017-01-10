CREATE TABLE [dbo].[IQ_InstagramClients](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[_ClientGUID] [uniqueidentifier] NOT NULL,
	[InstagramAuthCode] [varchar](500) NULL,
	[InstagramAuthToken] [varchar](200) NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [IQ_InstagramClients_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [IQ_InstagramClients_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [IQ_InstagramSetup_IsActive]  DEFAULT ((1)),
	[IsTokenExpired] [bit] NOT NULL CONSTRAINT [DF_IQ_InstagramClients_IsTokenExpired]  DEFAULT ((0)),
 CONSTRAINT [PK_IQ_InstagramClients] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
