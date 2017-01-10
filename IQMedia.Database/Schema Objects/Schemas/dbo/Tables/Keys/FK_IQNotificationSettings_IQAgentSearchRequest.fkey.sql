ALTER TABLE [dbo].[IQNotificationSettings]  WITH NOCHECK ADD  CONSTRAINT [FK_IQNotificationSettings_IQAgent_SearchRequest] FOREIGN KEY([SearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO
ALTER TABLE [dbo].[IQNotificationSettings] CHECK CONSTRAINT [FK_IQNotificationSettings_IQAgent_SearchRequest]
GO