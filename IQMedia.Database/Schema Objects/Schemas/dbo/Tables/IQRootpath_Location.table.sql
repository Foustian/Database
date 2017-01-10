CREATE TABLE [dbo].[IQRootpath_Location](
	[IQRpLocKey] [bigint] IDENTITY(1,1) NOT NULL,
	[_RootPathID] [int] NULL,
	[Remote_SvcUrl] [varchar](250) NULL,
	[RPSiteID] [varchar](50) NULL
) ON [PRIMARY]
