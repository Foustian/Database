﻿ALTER TABLE [dbo].[Iq_Service_log]
    ADD CONSTRAINT [DF_Iq_Service_log_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

