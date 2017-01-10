CREATE TABLE [dbo].[IQJob_Type](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](300) NULL,
	[Description] [varchar](300) NULL,
	[IsActive] [bit] NULL,
	[CanReset] [bit] NOT NULL,
	[ResetProcedureName] [varchar](100) NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IQJob_Type] ADD  CONSTRAINT [DF_IQJob_Type_CanReset]  DEFAULT ((0)) FOR [CanReset]
GO
