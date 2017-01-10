CREATE TABLE [dbo].[IQReport_Folder](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_ClientGUID] [uniqueidentifier] NOT NULL,
	[Name] [varchar](255) NULL,
	[Description] [varchar](max) NULL,
	[_ParentID] [bigint] NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IQReport_Folder] ADD  CONSTRAINT [DF_IQReport_Folder_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[IQReport_Folder] ADD  CONSTRAINT [DF_IQReport_Folder_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[IQReport_Folder] ADD  CONSTRAINT [DF_IQReport_Folder_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO