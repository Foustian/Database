ALTER TABLE [dbo].[IQCore_AssetLocation]
    ADD CONSTRAINT [FK_IQCore_AssetLocation_IQCore_AssetType] FOREIGN KEY ([_AssetTypeID]) REFERENCES [dbo].[IQCore_AssetType] ([ID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

