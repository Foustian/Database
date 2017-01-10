CREATE TABLE [dbo].[IQDataImport_SonyArtist](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Artist_Name] [varchar](100) NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQ3rdP_SonyArtist_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQ3rdP_SonyArtist_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQ3rdP_SonyArtist_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_IQ3rdP_SonyArtist] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

