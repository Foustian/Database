CREATE TABLE [dbo].[fliQ_ClientApplication](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[_FliqApplicationID] [bigint] NOT NULL,
	[FTPHost] [varchar](255) NOT NULL,
	[FTPPath] [varchar](255) NOT NULL,
	[FTPLoginID] [varchar](255) NOT NULL,
	[FTPPwd] [varchar](255) NOT NULL,
	[MaxVideoDuration] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[IsCategoryEnable] [bit] NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
	[DefaultCategory] [uniqueidentifier] NULL,
	[ForceLandscape] [bit] NOT NULL
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[fliQ_ClientApplication] ADD  CONSTRAINT [DF_fliQ_ClientApplication_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[fliQ_ClientApplication] ADD  CONSTRAINT [DF_fliQ_ClientApplication_DateModified]  DEFAULT (getdate()) FOR [DateModified]
GO

ALTER TABLE [dbo].[fliQ_ClientApplication] ADD CONSTRAINT [DF_fliQ_ClientApplication_ForceLandscape]  DEFAULT ((0)) FOR [ForceLandscape]
GO