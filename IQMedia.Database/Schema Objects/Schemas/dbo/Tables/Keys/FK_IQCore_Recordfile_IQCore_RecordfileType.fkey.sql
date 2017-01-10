ALTER TABLE [dbo].[IQCore_Recordfile]  WITH CHECK ADD  CONSTRAINT [FK_IQCore_Recordfile_IQCore_RecordfileType] FOREIGN KEY([_RecordfileTypeID])
REFERENCES [dbo].[IQCore_RecordfileType] ([ID])
GO
ALTER TABLE [dbo].[IQCore_Recordfile] CHECK CONSTRAINT [FK_IQCore_Recordfile_IQCore_RecordfileType]
GO