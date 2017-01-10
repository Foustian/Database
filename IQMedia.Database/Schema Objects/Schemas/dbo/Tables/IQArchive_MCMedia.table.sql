CREATE TABLE [dbo].[IQArchive_MCMedia](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MasterClientGUID] [uniqueidentifier] NOT NULL,
	[ArchiveID] [bigint] NOT NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQArchive_MCMedia_IsActive]  DEFAULT ((1)),
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQArchive_MCMedia_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQArchive_MCMedia_ModifiedDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_IQArchive_MCMedia] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

