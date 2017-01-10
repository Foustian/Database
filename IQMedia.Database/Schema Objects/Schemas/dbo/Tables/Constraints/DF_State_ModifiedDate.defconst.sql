ALTER TABLE [dbo].[State]
    ADD CONSTRAINT [DF_State_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

