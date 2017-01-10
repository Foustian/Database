ALTER TABLE [dbo].[Iq_Service_log]
    ADD CONSTRAINT [DF_Iq_Service_log_IsActive] DEFAULT ((1)) FOR [IsActive];

