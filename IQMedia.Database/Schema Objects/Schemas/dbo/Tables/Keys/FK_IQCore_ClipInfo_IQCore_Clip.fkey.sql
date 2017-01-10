ALTER TABLE [dbo].[IQCore_ClipInfo]  WITH CHECK ADD  CONSTRAINT [FK_IQCore_ClipInfo_IQCore_Clip] FOREIGN KEY([_ClipGuid])
REFERENCES [dbo].[IQCore_Clip] ([Guid])
GO
ALTER TABLE [dbo].[IQCore_ClipInfo] CHECK CONSTRAINT [FK_IQCore_ClipInfo_IQCore_Clip]
GO