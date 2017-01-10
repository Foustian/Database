ALTER TABLE [dbo].[RL_GUIDS2]
    ADD CONSTRAINT [DF_RL_GUIDS_CreatedDate2] DEFAULT (getdate()) FOR [CreatedDate];

