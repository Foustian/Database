ALTER TABLE [dbo].[State]
    ADD CONSTRAINT [DF_State_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

