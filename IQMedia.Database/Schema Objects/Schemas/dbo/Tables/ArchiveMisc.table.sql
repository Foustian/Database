CREATE TABLE [dbo].[ArchiveMisc](
	[ArchiveMiscKey] [bigint] IDENTITY(1,1) NOT NULL,
	[UGCGUID] [uniqueidentifier] NOT NULL,
	[CategoryGUID] [uniqueidentifier] NOT NULL,
	[SubCategoryGUID1] [uniqueidentifier] NULL,
	[SubCategoryGUID2] [uniqueidentifier] NULL,
	[SubCategoryGUID3] [uniqueidentifier] NULL,
	[CustomerGUID] [uniqueidentifier] NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[Title] [varchar](2048) NOT NULL,
	[Keywords] [varchar](2048) NOT NULL,
	[Description] [varchar](2048) NOT NULL,
	[_RootPathID] [int] NULL,
	[Location] [varchar](500) NULL,
	[_FileTypeID] [int] NULL,
	[CreateDT] [datetime] NOT NULL,
	[CreateDTTimeZone] [varchar](3) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[v5SubMediaType] [varchar](50) NULL,
 CONSTRAINT [PK_ArchiveMisc] PRIMARY KEY CLUSTERED 
(
	[ArchiveMiscKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


