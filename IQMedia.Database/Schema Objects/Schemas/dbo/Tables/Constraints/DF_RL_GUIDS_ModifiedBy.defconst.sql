ALTER TABLE [dbo].[RL_GUIDS]
    ADD CONSTRAINT [DF_RL_GUIDS_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

