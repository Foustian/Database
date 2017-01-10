CREATE TABLE [dbo].[IQAgent_ExcludeSkippedLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SP] [varchar](255) NULL,
	[Message] [varchar](max) NULL,
 CONSTRAINT [PK_IQAgentExcludeSkippedLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)
) ON [PRIMARY]