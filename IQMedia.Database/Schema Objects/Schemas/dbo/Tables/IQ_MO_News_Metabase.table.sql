CREATE TABLE [dbo].[IQ_MO_News_Metabase](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[FileLocation] [varchar](250) NOT NULL,
	[LastArticleID] [varchar](50) NULL,
	[ConversionStatus] [bit] NULL,
	[IngestStatus] [varchar](10) NULL,
	[IngestDate] [datetime] NULL,
	[DateCreated] [datetime] NOT NULL,
	[DateModified] [datetime] NULL,
 CONSTRAINT [PK_IQ_MO_News_Metabase] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


ALTER TABLE [dbo].[IQ_MO_News_Metabase] ADD  CONSTRAINT [DF_IQ_MO_News_Metabase_ConversionStatus]  DEFAULT ((0)) FOR [ConversionStatus]
GO


