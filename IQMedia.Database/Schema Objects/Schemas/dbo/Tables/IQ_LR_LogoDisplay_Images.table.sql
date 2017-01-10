CREATE TABLE [dbo].[IQ_LR_LogoDisplay_Images](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[logo_thumbs] [varchar](250) NULL,
	[filepath] [varchar](250) NOT NULL,
	[RPID] [smallint] NULL,
	[IsActive] [smallint] NOT NULL CONSTRAINT [DF_IQ_LR_LogoDisplay_Images_IsActive]  DEFAULT ((1)),
	[Company_ID] [bigint] NULL,
 CONSTRAINT [PK_IQ_LR_LogoDisplay_Images] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
