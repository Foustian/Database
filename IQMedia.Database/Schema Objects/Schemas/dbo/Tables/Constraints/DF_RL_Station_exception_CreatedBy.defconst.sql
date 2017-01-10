ALTER TABLE [dbo].[RL_Station_exception]
    ADD CONSTRAINT [DF_RL_Station_exception_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

