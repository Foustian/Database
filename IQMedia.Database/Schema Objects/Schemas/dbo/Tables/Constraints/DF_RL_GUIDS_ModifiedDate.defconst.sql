ALTER TABLE [dbo].[RL_GUIDS]
    ADD CONSTRAINT [DF_RL_GUIDS_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

