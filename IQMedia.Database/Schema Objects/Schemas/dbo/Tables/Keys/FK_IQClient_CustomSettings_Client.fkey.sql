ALTER TABLE [dbo].[IQClient_CustomSettings]  WITH CHECK ADD  CONSTRAINT [FK_IQClient_CustomSettings_Client] FOREIGN KEY([_ClientGuid])
REFERENCES [dbo].[Client] ([ClientGUID])
GO
ALTER TABLE [dbo].[IQClient_CustomSettings] CHECK CONSTRAINT [FK_IQClient_CustomSettings_Client]
GO