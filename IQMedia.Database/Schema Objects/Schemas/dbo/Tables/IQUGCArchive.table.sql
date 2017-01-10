﻿CREATE TABLE [dbo].[IQUGCArchive](
	[IQUGCArchiveKey] [bigint] IDENTITY(1,1) NOT NULL,
	[UGCGUID] [uniqueidentifier] NOT NULL,
	[CategoryGUID] [uniqueidentifier] NOT NULL,
	[SubCategory1GUID] [uniqueidentifier] NULL,
	[SubCategory2GUID] [uniqueidentifier] NULL,
	[SubCategory3GUID] [uniqueidentifier] NULL,
	[Title] [varchar](2048) NOT NULL,
	[Keywords] [varchar](max) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[CreateDT] [datetime] NOT NULL,
	[CreateDTTimeZone] [varchar](3) NOT NULL,
	[DateUploaded] [datetime] NULL,
	[CustomerGUID] [uniqueidentifier] NOT NULL,
	[ClientGUID] [uniqueidentifier] NOT NULL,
	[SourceID] [uniqueidentifier] NOT NULL,
	[ThumbnailImage] [varchar](500) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[AirDate] [datetime] NULL
) ON [PRIMARY]

