ALTER TABLE [dbo].[IQService_CdnTransfer]
    ADD CONSTRAINT [FK_IQService_CdnTransfer_IQCore_Recordfile] FOREIGN KEY ([RecordfileGuid]) REFERENCES [dbo].[IQCore_Recordfile] ([Guid]) ON DELETE NO ACTION ON UPDATE NO ACTION;

