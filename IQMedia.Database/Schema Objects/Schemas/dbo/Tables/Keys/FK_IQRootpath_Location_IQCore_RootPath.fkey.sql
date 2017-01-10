ALTER TABLE [dbo].[IQRootpath_Location]  WITH CHECK ADD  CONSTRAINT [FK_IQRootpath_Location_IQCore_RootPath] FOREIGN KEY([_RootPathID])
REFERENCES [dbo].[IQCore_RootPath] ([ID])
GO
ALTER TABLE [dbo].[IQRootpath_Location] CHECK CONSTRAINT [FK_IQRootpath_Location_IQCore_RootPath]
GO