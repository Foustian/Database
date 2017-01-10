ALTER TABLE [dbo].[IQNotificationSettings]  WITH CHECK ADD  CONSTRAINT [FK_IQNotificationSettings_IQ_ReportType] FOREIGN KEY([_ReportTypeID])
REFERENCES [dbo].[IQ_ReportType] ([ID])
GO
ALTER TABLE [dbo].[IQNotificationSettings] CHECK CONSTRAINT [FK_IQNotificationSettings_IQ_ReportType]
GO