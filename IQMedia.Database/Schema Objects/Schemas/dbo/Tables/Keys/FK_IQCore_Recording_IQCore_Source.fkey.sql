ALTER TABLE [dbo].[IQCore_Recording]  WITH CHECK ADD  CONSTRAINT [FK_IQCore_Recording_IQCore_Source] FOREIGN KEY([_SourceGuid])
REFERENCES [dbo].[IQCore_Source] ([Guid])
GO
ALTER TABLE [dbo].[IQCore_Recording] CHECK CONSTRAINT [FK_IQCore_Recording_IQCore_Source]
GO