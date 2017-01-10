ALTER TABLE [dbo].[RL_GUIDS1]
    ADD CONSTRAINT [DF_RL_GUIDS_ModifiedDate1] DEFAULT (getdate()) FOR [ModifiedDate];

