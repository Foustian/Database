ALTER TABLE [dbo].[RL_Station_exception]
    ADD CONSTRAINT [DF_RL_Station_exception_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

