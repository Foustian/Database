ALTER TABLE [dbo].[Iq_Service_log]
    ADD CONSTRAINT [DF_Iq_Service_log_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

