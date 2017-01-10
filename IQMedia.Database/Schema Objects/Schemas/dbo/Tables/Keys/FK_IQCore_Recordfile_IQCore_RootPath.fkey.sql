ALTER TABLE [dbo].[IQCore_Recordfile]  WITH CHECK ADD  CONSTRAINT [FK_IQCore_Recordfile_IQCore_RootPath] FOREIGN KEY([_RootPathID])
REFERENCES [dbo].[IQCore_RootPath] ([ID])
GO
ALTER TABLE [dbo].[IQCore_Recordfile] CHECK CONSTRAINT [FK_IQCore_Recordfile_IQCore_RootPath]
GO