CREATE TABLE [dbo].[IQ_LR_Search_Images](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Raw_Logo_filename] [varchar](250) NOT NULL,
	[process_filename] [varchar](250) NULL,
	[Score_Threshold] [smallint] NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_LR_Search_Images_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ_LR_Search_Images_ModifiedDate]  DEFAULT (getdate()),
	[Brand_ID] [bigint] NOT NULL,
	[ClientGUID] [uniqueidentifier] NULL,
	[filepath] [varchar](250) NULL,
	[RPID] [smallint] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ_LR_Search_Images_IsActive]  DEFAULT ((1)),
	[DisplayFileName] [varchar](200) NULL,
	[ParentID] [bigint] NULL,
 CONSTRAINT [PK_IQ_LR_Search_Images] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IQ_LR_Search_Images_LR_LogoDisplay_ImageID] ON [dbo].[IQ_LR_Search_Images]
(
	[Brand_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

