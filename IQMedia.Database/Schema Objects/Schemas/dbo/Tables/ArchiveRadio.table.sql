CREATE TABLE [dbo].[ArchiveRadio](
	[ArchiveRadioKey] [bigint] IDENTITY(1,1) NOT NULL,
	[ClipGuid] [uniqueidentifier] NOT NULL,
	[Title] [varchar](250) NULL,
	[IQ_CC_Key] [varchar](28) NULL,
	[GMTDatetime] [datetime2](7) NULL,
	[LocalDatetime] [datetime2](7) NULL,
	[Number_Hits] [int] NULL,
	[StartOffset] [int] NULL,
	[ClosedCaption] [xml] NULL,
	[HighlightingText] [nvarchar](max) NULL,
	[v5SubMediaType] [varchar](50) NOT NULL,
	[PositiveSentiment] [tinyint] NULL,
	[NegativeSentiment] [tinyint] NULL,
	[Keywords] [varchar](2048) NULL,
	[Description] [varchar](2048) NULL,
	[FirstName] [varchar](150) NULL,
	[LastName] [varchar](150) NULL,
	[CustomerGuid] [uniqueidentifier] NOT NULL,
	[ClientGuid] [uniqueidentifier] NOT NULL,
	[CategoryGuid] [uniqueidentifier] NOT NULL,
	[SubCategory1Guid] [uniqueidentifier] NULL,
	[SubCategory2Guid] [uniqueidentifier] NULL,
	[SubCategory3Guid] [uniqueidentifier] NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_ArchiveRadio] PRIMARY KEY CLUSTERED 
(
	[ArchiveRadioKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ArchiveRadio] ADD  CONSTRAINT [DF_ArchiveRadio_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[ArchiveRadio] ADD  CONSTRAINT [DF_ArchiveRadio_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[ArchiveRadio] ADD  CONSTRAINT [DF_ArchiveRadio_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [dbo].[ArchiveRadio]  WITH CHECK ADD  CONSTRAINT [FK_ArchiveRadio_ClipGuid] FOREIGN KEY([ClipGuid])
REFERENCES [dbo].[IQCore_Clip] ([Guid])
GO

ALTER TABLE [dbo].[ArchiveRadio] CHECK CONSTRAINT [FK_ArchiveRadio_ClipGuid]
GO

