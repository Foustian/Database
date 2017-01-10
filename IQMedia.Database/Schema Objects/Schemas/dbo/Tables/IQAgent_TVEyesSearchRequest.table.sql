CREATE TABLE [dbo].[IQAgent_TVEyesSearchRequest](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[TVEyesSearchGUID] [uniqueidentifier] NULL,
	[Query_Name] [varchar](max) NULL,
	[SearchTerm] [xml] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [varchar](150) NULL,
	[ModifiedBy] [varchar](150) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_IQAgent_TVEyesSearchRequest] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) 
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[IQAgent_TVEyesSearchRequest] ADD  CONSTRAINT [DF_IQAgent_TVEyesSearchRequest_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesSearchRequest] ADD  CONSTRAINT [DF_IQAgent_TVEyesSearchRequest_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesSearchRequest] ADD  CONSTRAINT [DF_IQAgent_TVEyesSearchRequest_CreatedBy]  DEFAULT ('System') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesSearchRequest] ADD  CONSTRAINT [DF_IQAgent_TVEyesSearchRequest_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO

ALTER TABLE [dbo].[IQAgent_TVEyesSearchRequest] ADD  CONSTRAINT [DF_IQAgent_TVEyesSearchRequest_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
