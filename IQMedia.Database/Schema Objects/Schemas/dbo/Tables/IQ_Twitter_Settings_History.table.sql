CREATE TABLE [dbo].[IQ_Twitter_Settings_History](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_TWTSettingsKey] [bigint] NOT NULL,
	[TwitterRule] [xml] NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_Twitter_Settings_History_CreatedDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_IQ_Twitter_Settings_History] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
