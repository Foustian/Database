CREATE TABLE [dbo].[IQ3rdP_DataTypes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[_ClientGuid] [uniqueidentifier] NOT NULL,
	[DataType] [varchar](100) NOT NULL,
	[DisplayName] [varchar](100) NOT NULL,
	[YAxisID] [int] NOT NULL,
	[YAxisName] [varchar](100) NOT NULL,
	[SPName] [varchar](150) NOT NULL,
	[IsAgentSpecific] [bit] NOT NULL,
	[UseHourData] [bit] NOT NULL,
	[UseIDParam] [bit] NOT NULL CONSTRAINT [DF_IQ3rdP_DataTypes_UseIDParam]  DEFAULT ((0)),
	[SeriesLineType] [varchar](50) NOT NULL CONSTRAINT [DF_IQ3P_DataTypes_SeriesLineType]  DEFAULT ('solid'),
	[GroupID] [int] NULL,
	[GroupName] [varchar](100) NULL,
	[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ3rdP_DataTypes_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_IQ3rdP_DataTypes_ModifiedDate]  DEFAULT (getdate()),
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_IQ3P_DataTypes_IsActive]  DEFAULT ((1)),
	[_RoleKey] [bigint] NOT NULL,
 CONSTRAINT [PK_IQ3P_DataTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IQ3rdP_DataTypes]  WITH CHECK ADD  CONSTRAINT [FK_IQ3rdP_DataTypes_RoleID] FOREIGN KEY([_RoleKey])
REFERENCES [dbo].[Role] ([RoleKey])
GO

ALTER TABLE [dbo].[IQ3rdP_DataTypes] CHECK CONSTRAINT [FK_IQ3rdP_DataTypes_RoleID]
GO

ALTER TABLE [dbo].[IQ3rdP_DataTypes]  WITH CHECK ADD  CONSTRAINT [CK_IQ3rdP_DataTypes_SeriesLineType] CHECK  (([SeriesLineType]='longdashdotdot' OR [SeriesLineType]='longdashdot' OR [SeriesLineType]='dashdot' OR [SeriesLineType]='longdash' OR [SeriesLineType]='dash' OR [SeriesLineType]='dot' OR [SeriesLineType]='shortdashdotdot' OR [SeriesLineType]='shortdashdot' OR [SeriesLineType]='shortdot' OR [SeriesLineType]='shortdash' OR [SeriesLineType]='solid'))
GO

ALTER TABLE [dbo].[IQ3rdP_DataTypes] CHECK CONSTRAINT [CK_IQ3rdP_DataTypes_SeriesLineType]
GO

