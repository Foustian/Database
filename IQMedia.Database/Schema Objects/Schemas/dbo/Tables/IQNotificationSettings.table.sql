CREATE TABLE [dbo].[IQNotificationSettings](
	[IQNotificationKey] [bigint] IDENTITY(1,1) NOT NULL,
	[SearchRequestList] [xml] NULL,
	[TypeofEntry] [varchar](10) NULL,
	[ClientGuid] [uniqueidentifier] NULL,
	[Notification_Address] [xml] NULL,
	[Frequency] [varchar](25) NULL,
	[_ReportTypeID] [int] NULL,
	[_ReportImageID] [bigint] NULL,
	[DayOfWeek] [tinyint] NULL,
	[Time] [time](7) NULL,
	[CreatedDate] [datetime] NULL CONSTRAINT [DF_IQNotificationSettings_CreatedDate]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_IQNotificationSettings_ModifiedDate]  DEFAULT (getdate()),
	[CreatedBy] [varchar](150) NULL CONSTRAINT [DF_IQNotificationSettings_CreatedBy]  DEFAULT ('System'),
	[ModifiedBy] [varchar](150) NULL CONSTRAINT [DF_IQNotificationSettings_ModifiedBy]  DEFAULT ('System'),
	[IsActive] [bit] NULL CONSTRAINT [DF_IQNotificationSettings_IsActive]  DEFAULT ((1)),
	[MediaType] [xml] NULL,
	[UseRollup] [bit] NULL CONSTRAINT [DF_IQNotificationSettings_UseRollup]  DEFAULT ((0)),
 CONSTRAINT [PK_IQNotificationSettings] PRIMARY KEY CLUSTERED 
(
	[IQNotificationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[IQNotificationSettings]  WITH CHECK ADD  CONSTRAINT [FK_IQNotificationSettings_IQ_ReportType] FOREIGN KEY([_ReportTypeID])
REFERENCES [dbo].[IQ_ReportType] ([ID])
GO

ALTER TABLE [dbo].[IQNotificationSettings] CHECK CONSTRAINT [FK_IQNotificationSettings_IQ_ReportType]
GO