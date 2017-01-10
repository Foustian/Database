CREATE TABLE [dbo].[fliQ_Application](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Application] [varchar](max) NOT NULL,
	[Version] [varchar](20) NOT NULL,
	[Path] [varchar](512) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NOT NULL,
 CONSTRAINT [PK_fliQ_Application] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[fliQ_Application] ADD  CONSTRAINT [DF_fliQ_Application_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[fliQ_Application] ADD  CONSTRAINT [DF_fliQ_Application_DateModified]  DEFAULT (getdate()) FOR [DateModified]