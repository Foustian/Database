ALTER TABLE [dbo].[RL_GUIDS]
    ADD CONSTRAINT [DF_RL_GUIDS_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

