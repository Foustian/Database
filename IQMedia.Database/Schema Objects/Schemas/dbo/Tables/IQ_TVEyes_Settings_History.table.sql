CREATE TABLE [dbo].[IQ_TVEyes_Settings_History](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[_TVESettingsKey] [bigint] NOT NULL,
	[TVESearchTerm] [varchar](max) NOT NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_TVEyes_Settings_History_CreatedDate_1]  DEFAULT (getdate()),
 CONSTRAINT [PK_IQ_TVEyes_Settings_History_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
