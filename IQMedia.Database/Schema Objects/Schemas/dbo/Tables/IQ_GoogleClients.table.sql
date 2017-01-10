CREATE TABLE [dbo].[IQ_GoogleClients](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[_ClientGUID] [uniqueidentifier] NOT NULL,
	[GoogleAuthCode] [varchar](500) NULL,
	[GoogleAccessToken] [varchar](500) NULL,
	[LastUpdatedTokenDatetime] [datetime] NULL,
	[GoogleRefreshToken] [varchar](500) NULL,
	[LastGoogleFetchDatetime] [datetime] NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [IQ_GoogleClients_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [IQ_GoogleClients_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [IQ_GoogleSetup_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ_GoogleClients] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

