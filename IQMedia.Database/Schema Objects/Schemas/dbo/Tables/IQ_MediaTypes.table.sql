CREATE TABLE [dbo].[IQ_MediaTypes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MediaType] [varchar](2) NOT NULL,
	[SubMediaType] [varchar](50) NULL,
	[DisplayName] [varchar](200) NULL,
	[_RoleKey] [bigint] NOT NULL,
	[_ParentRoleKey] [bigint] NOT NULL,
	[TypeLevel] [tinyint] NOT NULL,
	[HasSubMediaTypes] [bit] NOT NULL,
	[DataModelType] [varchar](10) NULL,
	[AnalyticsDataType] [varchar](20) NULL,
	[DiscChartSearchMethod] [varchar](200) NULL,
	[DiscResultsSearchMethod] [varchar](200) NULL,
	[DiscRptGenSearchMethod] [varchar](200) NULL,
	[DiscExportSearchMethod] [varchar](200) NULL,
	[FeedsResultView] [varchar](50) NULL,
	[FeedsChildResultView] [varchar](50) NULL,
	[DiscoveryResultView] [varchar](50) NULL,
	[MediaIconPath] [varchar](100) NULL,
	[EmailMediaIconPath] [varchar](100) NULL,
	[UseAudience] [bit] NOT NULL CONSTRAINT [DF_IQ_MediaTypes_UseAudience]  DEFAULT ((0)),
	[UseMediaValue] [bit] NOT NULL CONSTRAINT [DF_IQ_MediaTypes_UseMediaValue]  DEFAULT ((0)),
	[SortOrder] [smallint] NULL,
	[IsActiveDiscovery] [bit] NOT NULL CONSTRAINT [DF_IQ_MediaTypes_IsActiveDiscovery]  DEFAULT ((0)),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ_MediaTypes_IsActive]  DEFAULT ((1)),
	[RequireNielsenAccess] [bit] NOT NULL CONSTRAINT [DF_IQ_MediaTypes_RequireNielsenAccess]  DEFAULT ((0)),
	[RequireCompeteAccess] [bit] NOT NULL CONSTRAINT [DF_IQ_MediaTypes_RequireCompeteAccess]  DEFAULT ((0)),
	[DashboardData] [varchar](2048) NULL,
	[UseHighlightingText] [bit] NOT NULL CONSTRAINT [DF_IQ_MediaTypes_UseHighlightingText]  DEFAULT ((1)),
	[v4MediaType] [varchar](2) NULL,
	[v4SubMediaType] [varchar](50) NULL,
	[AgentNodeName] [varchar](50) NULL,
	[SourceTypes] [varchar](200) NULL,
	[AgentType] [smallint] NULL,
	[IsArchiveOnly] [bit] NOT NULL,
	[SolrMediaType] [varchar](2) NULL,
	[ExternalPlayerUrlSvc] [varchar](300) NULL,
 CONSTRAINT [PK_IQ_MediaTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IQ_MediaTypes]  WITH CHECK ADD  CONSTRAINT [FK_IQ_MediaTypes_ParentRoleKey] FOREIGN KEY([_ParentRoleKey])
REFERENCES [dbo].[Role] ([RoleKey])
GO

ALTER TABLE [dbo].[IQ_MediaTypes] CHECK CONSTRAINT [FK_IQ_MediaTypes_ParentRoleKey]
GO

ALTER TABLE [dbo].[IQ_MediaTypes]  WITH CHECK ADD  CONSTRAINT [FK_IQ_MediaTypes_RoleKey] FOREIGN KEY([_RoleKey])
REFERENCES [dbo].[Role] ([RoleKey])
GO

ALTER TABLE [dbo].[IQ_MediaTypes] CHECK CONSTRAINT [FK_IQ_MediaTypes_RoleKey]
GO

