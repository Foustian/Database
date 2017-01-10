CREATE TABLE [dbo].[IQTimeshift_SavedSearch](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[SearchTerm] [xml] NOT NULL,
	[ClientGuid] [uniqueidentifier] NOT NULL,
	[CustomerGuid] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedDate] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[Component][varchar](5) NOT NULL
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[IQTimeshift_SavedSearch] ADD  CONSTRAINT [DF_IQTimeshift_SavedSearch_IsActive]  DEFAULT ((0)) FOR [IsActive]