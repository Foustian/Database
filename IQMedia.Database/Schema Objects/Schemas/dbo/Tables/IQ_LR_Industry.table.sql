CREATE TABLE [dbo].[IQ_LR_Industry](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Industry] [varchar](100) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ_LR_Industry_IsActive]  DEFAULT ((1)),
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_LR_Industry_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_LR_Industry_ModifiedDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_IQ_LR_Industry] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

