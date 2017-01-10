CREATE TABLE [dbo].[IQService_TwitterSettings](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[CustomerGUID] [uniqueidentifier] NULL,
	[_SearchRequestID] [bigint] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQService_TwitterRule_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQService_TwitterRule_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQService_TwitterRule_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQService_TwitterRule] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
