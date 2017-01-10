ALTER TABLE [dbo].[UGC_Upload_Log]
    ADD CONSTRAINT [DF_UGC_upload_log_IsActive] DEFAULT ((1)) FOR [IsActive];

