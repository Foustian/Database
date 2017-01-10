CREATE TABLE [dbo].[IQ_Station](
	[IQ_Station_ID] [varchar](255) NOT NULL,
	[_CategoryID] [int] NULL,
	[_RegionID] [int] NULL,
	[Format] [varchar](255) NOT NULL,
	[TimeZone] [char](3) NULL,
	[UNIVERSE] [int] NULL,
	[SQADMARKETID] [float] NULL,
	[Station_Call_Sign] [varchar](255) NOT NULL,
	[Dma_Name] [varchar](255) NOT NULL,
	[Dma_Num] [varchar](255) NOT NULL,
	[Station_Affil] [varchar](13) NOT NULL,
	[Station_Affil_Num] [varchar](2) NOT NULL,
	[Station_Affil_Cat_Num] [int] NULL,
	[Station_Affil_Cat_Name] [varchar](50) NULL,
	[gmt_adj] [float] NULL,
	[dst_adj] [float] NULL,
	[IsActive] [bit] NOT NULL,
	[iq_dma_lat] [float] NULL,
	[iq_dma_long] [float] NULL,
	[IsSharing] [bit] NULL
) ON [PRIMARY]
GO