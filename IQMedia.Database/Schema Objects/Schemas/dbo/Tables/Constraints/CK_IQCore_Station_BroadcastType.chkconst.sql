ALTER TABLE [dbo].[IQCore_Source]  WITH CHECK ADD  CONSTRAINT [CK_IQCore_Station_BroadcastType] CHECK  (([BroadcastType]='VIDEO' OR [BroadcastType]='AUDIO'))
GO
ALTER TABLE [dbo].[IQCore_Source] CHECK CONSTRAINT [CK_IQCore_Station_BroadcastType]
GO