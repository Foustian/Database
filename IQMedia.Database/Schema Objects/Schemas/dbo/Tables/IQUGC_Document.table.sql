CREATE TABLE [dbo].[IQUGC_Document](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CategoryGUID] [uniqueidentifier] NOT NULL,
	[SubCategory1GUID] [uniqueidentifier] NULL,
	[SubCategory2GUID] [uniqueidentifier] NULL,
	[SubCategory3GUID] [uniqueidentifier] NULL,
	[Title] [varchar](2048) NOT NULL,
	[Keywords] [varchar](max) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[DocumentTimeZone] [varchar](3) NOT NULL,
	[CustomerGUID] [uniqueidentifier] NOT NULL,
	[_RootPathID] [int] NOT NULL,
	[Location] [varchar](500) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_IQUGC_Document] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]