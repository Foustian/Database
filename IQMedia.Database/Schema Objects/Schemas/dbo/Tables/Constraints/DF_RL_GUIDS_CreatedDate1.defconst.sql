ALTER TABLE [dbo].[RL_GUIDS1]
    ADD CONSTRAINT [DF_RL_GUIDS_CreatedDate1] DEFAULT (getdate()) FOR [CreatedDate];

