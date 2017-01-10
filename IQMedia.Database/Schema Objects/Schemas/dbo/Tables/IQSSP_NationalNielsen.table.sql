CREATE TABLE [dbo].[IQSSP_NationalNielsen](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[DatabaseKey] [varchar](10) NOT NULL,
	[Title120] [varchar](100) NOT NULL,
	[LocalDate] [date] NULL,
	[Audience] [bigint] NULL,
	[MediaValue] [decimal](18, 2) NULL,
	[IsActual] [bit] NULL,
	[Station_Affil] [varchar](13) NULL,
 CONSTRAINT [PK_IQSSP_NationalNielsen] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]