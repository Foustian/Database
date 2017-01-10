CREATE TABLE [dbo].[FeedsSearchLog](
	[FeedsSearchLogKey] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[SearchType] [varchar](50) NULL,
	[RequestXML] [xml] NULL,
	[ErrorResponseXML] [xml] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_FeedsSearchLog] PRIMARY KEY CLUSTERED 
(
	[FeedsSearchLogKey] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[FeedsSearchLog] ADD  CONSTRAINT [DF_FeedsSearchLog_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[FeedsSearchLog] ADD  CONSTRAINT [DF_FeedsSearchLog_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[FeedsSearchLog] ADD  CONSTRAINT [DF_FeedsSearchLog_CreatedBy]  DEFAULT ('System') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[FeedsSearchLog] ADD  CONSTRAINT [DF_FeedsSearchLog_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO

ALTER TABLE [dbo].[FeedsSearchLog] ADD  CONSTRAINT [DF_FeedsSearchLog_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

