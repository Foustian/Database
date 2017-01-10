ALTER TABLE [dbo].[IQNotificationTracking]  WITH CHECK ADD  CONSTRAINT [FK_IQNotificationTracking_IQAgent_SearchRequest] FOREIGN KEY([SearchRequestID])
REFERENCES [dbo].[IQAgent_SearchRequest] ([ID])
GO
ALTER TABLE [dbo].[IQNotificationTracking] CHECK CONSTRAINT [FK_IQNotificationTracking_IQAgent_SearchRequest]
GO
