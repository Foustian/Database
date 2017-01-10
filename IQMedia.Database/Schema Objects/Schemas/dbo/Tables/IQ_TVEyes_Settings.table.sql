CREATE TABLE [dbo].[IQ_TVEyes_Settings](
	[TVESettingsKey] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[SRID] [int] NOT NULL,
	[TVESearchGUID] [uniqueidentifier] NULL,
	[TVESearchTerm] [varchar](max) NOT NULL,
	[SearchDisplayName] [varchar](100) NULL,
	[Comments] [varchar](1000) NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQ_TVEyes_Settings_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQ_TVEyes_Settings_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQ_TVEyes_Settings_IsActive]  DEFAULT ((1)),
 CONSTRAINT [PK_TVEyes_Settings] PRIMARY KEY CLUSTERED 
(
	[TVESettingsKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_TVEyesSettings_TVESearchGUID] ON [dbo].[IQ_TVEyes_Settings]
(
	[TVESearchGUID] ASC
)
WHERE ([TVESearchGUID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
