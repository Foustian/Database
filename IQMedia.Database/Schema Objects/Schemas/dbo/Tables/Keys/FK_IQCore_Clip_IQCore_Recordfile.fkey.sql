ALTER TABLE [dbo].[IQCore_Clip]
    ADD CONSTRAINT [FK_IQCore_Clip_IQCore_Recordfile] FOREIGN KEY ([_RecordfileGuid]) REFERENCES [dbo].[IQCore_Recordfile] ([Guid]) ON DELETE NO ACTION ON UPDATE NO ACTION;

