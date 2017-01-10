
CREATE TABLE [dbo].[RL_STATION](
	[RL_Station_ID] [varchar](14) NULL,
	[rl_format] [varchar](5) NULL,
	[station_call_sign] [varchar](23) NULL,
	[rl_station_active] [float] NULL,
	[time_zone] [char](3) NULL,
	[dma_name] [varchar](26) NULL,
	[dma_num] [varchar](3) NULL,
	[gmt_adj] [float] NULL,
	[dst_adj] [float] NULL,
	[iq_cluster] [float] NULL,
	[station_affil] [varchar](50) NULL,
	[station_affil_num] [varchar](4) NULL,
	[rl_icon] [varchar](18) NULL,
	[Colocation] [varchar](11) NULL,
	[RL_StationKey] [int] IDENTITY(1,1) NOT NULL,
	[iq_dma_lat] [float] NULL,
	[iq_dma_long] [float] NULL
) ON [PRIMARY]



