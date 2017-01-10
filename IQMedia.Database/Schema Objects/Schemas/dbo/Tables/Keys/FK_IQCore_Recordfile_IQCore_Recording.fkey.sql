ALTER TABLE [dbo].[IQCore_Recordfile]  WITH CHECK ADD  CONSTRAINT [FK_IQCore_Recordfile_IQCore_Recording] FOREIGN KEY([_RecordingID])
REFERENCES [dbo].[IQCore_Recording] ([ID])
GO
ALTER TABLE [dbo].[IQCore_Recordfile] CHECK CONSTRAINT [FK_IQCore_Recordfile_IQCore_Recording]
GO