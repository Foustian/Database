ALTER TABLE [dbo].[IQCore_RootPath]
    ADD CONSTRAINT [FK_IQCore_RootPath_IQCore_RootPathType] FOREIGN KEY ([_RootPathTypeID]) REFERENCES [dbo].[IQCore_RootPathType] ([ID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

