CREATE TABLE [dbo].[IQAgentiFrame]
(
	[Guid] [uniqueidentifier] NOT NULL,
	[RawMediaGuid] [uniqueidentifier] NULL,
	[Expiry_Date] [datetime] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IQAgentResultID] [bigint] NULL,
	[DataModelType] [varchar](10) NULL CONSTRAINT [DF_IQAgentiFrame_DataModelType]  DEFAULT ('TV'),
 CONSTRAINT [PK_IQAgentiFrame] PRIMARY KEY CLUSTERED 
 (
	[Guid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
)
