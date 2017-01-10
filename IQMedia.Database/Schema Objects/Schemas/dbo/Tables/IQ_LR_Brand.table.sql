CREATE TABLE [dbo].[IQ_LR_Brand](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Brand] [varchar](100) NULL,
	[Forbes100_Brands] [smallint] NULL,
	[Company_ID] [bigint] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ_LR_Brand_IsActive]  DEFAULT ((1)),
	[logo_thumbs] [varchar](250) NULL,
	[filepath] [varchar](250) NULL,
	[RPID] [smallint] NULL,
	[_IndustryID] [bigint] NULL,
 CONSTRAINT [PK_IQ_LR_Brand] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IQ_LR_Brand]  WITH CHECK ADD  CONSTRAINT [FK_IQ_LR_Brand_IndustryID] FOREIGN KEY([_IndustryID])
REFERENCES [dbo].[IQ_LR_Industry] ([ID])
GO

ALTER TABLE [dbo].[IQ_LR_Brand] CHECK CONSTRAINT [FK_IQ_LR_Brand_IndustryID]
GO