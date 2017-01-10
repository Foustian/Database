CREATE TABLE [dbo].[IQDataImport_SonyAlbum](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Album_Name] [nvarchar](300) NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQ3rdP_SonyAlbum_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQ3rdP_SonyAlbum_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQ3rdP_SonyAlbum_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ3rdP_SonyAlbum] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

