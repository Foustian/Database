ALTER TABLE [dbo].[UGC_Upload_Log]
    ADD CONSTRAINT [DF_UGC_upload_log_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

