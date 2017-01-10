CREATE TABLE [dbo].[IQ_Analytics_ActiveElements](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ActivePage] [varchar](50) NOT NULL,
	[ElementSelector] [varchar](50) NULL,
	[ElementSelectorID] [varchar](50) NULL,
	[ActiveTabs] [varchar](500) NULL,
	[IsActiveWithPESH] bit NULL,
	[IsActiveWithMaps] bit NULL,
	[IsActiveWithLineCharts] bit NULL,
	[IsActiveWithOtherCharts] bit NULL,
	[HiddenTabs] [varchar](500) NULL
)