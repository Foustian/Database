ALTER TABLE [dbo].[ArchiveBLPMDownload]  WITH CHECK ADD  CONSTRAINT [FK_ArchiveBLPMDownload_ArchiveBLPM] FOREIGN KEY([MediaID])
REFERENCES [dbo].[ArchiveBLPM] ([ArchiveBLPMKey])
GO
ALTER TABLE [dbo].[ArchiveBLPMDownload] CHECK CONSTRAINT [FK_ArchiveBLPMDownload_ArchiveBLPM]
GO