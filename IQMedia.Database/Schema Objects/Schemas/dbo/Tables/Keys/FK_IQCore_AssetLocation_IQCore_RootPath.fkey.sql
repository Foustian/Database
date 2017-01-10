ALTER TABLE [dbo].[IQCore_AssetLocation]
    ADD CONSTRAINT [FK_IQCore_AssetLocation_IQCore_RootPath] FOREIGN KEY ([_RootPathID]) REFERENCES [dbo].[IQCore_RootPath] ([ID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

