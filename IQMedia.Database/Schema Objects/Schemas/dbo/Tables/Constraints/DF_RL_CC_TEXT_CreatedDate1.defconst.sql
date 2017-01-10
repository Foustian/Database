ALTER TABLE [dbo].[RL_CC_TEXT1]
    ADD CONSTRAINT [DF_RL_CC_TEXT_CreatedDate1] DEFAULT (getdate()) FOR [CreatedDate];

