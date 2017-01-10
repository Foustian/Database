CREATE TABLE [dbo].[IQGallery_Master]
(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](MAX) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](255) NOT NULL,
	[CustomerGUID] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_IQGallery_Master] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQGallery_Master] ADD  CONSTRAINT [DF_IQGallery_Master_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[IQGallery_Master] ADD  CONSTRAINT [DF_IQGallery_Master_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[IQGallery_Master] ADD  CONSTRAINT [DF_IQGallery_Master_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
