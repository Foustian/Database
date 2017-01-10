ALTER TABLE [dbo].[IQCore_ClipMeta]
    ADD CONSTRAINT [FK_IQCore_ClipMeta_IQCore_Clip] FOREIGN KEY ([_ClipGuid]) REFERENCES [dbo].[IQCore_Clip] ([Guid]) ON DELETE NO ACTION ON UPDATE NO ACTION;

