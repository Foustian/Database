﻿ALTER TABLE [dbo].[RL_CC_TEXT1]
    ADD CONSTRAINT [IX_RL_CC_TEXT1] UNIQUE NONCLUSTERED ([RL_CC_TEXTKey] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF) ON [PRIMARY];

