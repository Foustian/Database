CREATE TABLE [dbo].[IQ_Twitter_Settings](
	[TWTSettingsKey] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[UserTrackGUID] [uniqueidentifier] NOT NULL,
	[TwitterRule] [xml] NOT NULL,
	[RuleDisplayName] [varchar](100) NULL,
	[Comments] [varchar](1000) NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQ_Twitter_Settings_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQ_Twitter_Settings_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQ_Twitter_Settings_IsActive]  DEFAULT ((1)),
	[SRID] [bigint] NULL,
 CONSTRAINT [PK_Twitter_Settings] PRIMARY KEY CLUSTERED 
(
	[TWTSettingsKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_Twitter_Settings] UNIQUE NONCLUSTERED 
(
	[UserTrackGUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
