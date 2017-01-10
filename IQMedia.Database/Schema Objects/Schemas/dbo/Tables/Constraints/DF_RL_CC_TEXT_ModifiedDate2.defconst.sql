ALTER TABLE [dbo].[RL_CC_TEXT2]
    ADD CONSTRAINT [DF_RL_CC_TEXT_ModifiedDate2] DEFAULT (getdate()) FOR [ModifiedDate];

