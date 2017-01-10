ALTER TABLE [dbo].[State]
    ADD CONSTRAINT [DF_State_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

