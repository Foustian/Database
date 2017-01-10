CREATE TABLE [dbo].[fliQ_CustomCategory](
	[CategoryKey] [bigint] IDENTITY(1,1) NOT NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[CategoryGUID] [uniqueidentifier] ROWGUIDCOL  NULL,
	[CategoryName] [varchar](150) NULL,
	[CategoryDescription] [varchar](2000) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_fliQ_CustomCategory] PRIMARY KEY CLUSTERED 
(
	[CategoryKey] ASC
)
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[fliQ_CustomCategory] ADD  CONSTRAINT [DF_fliQ_CustomCategory_CategoryGUID]  DEFAULT (newid()) FOR [CategoryGUID]
GO

ALTER TABLE [dbo].[fliQ_CustomCategory] ADD  CONSTRAINT [DF_fliQ_CustomCategory_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO


