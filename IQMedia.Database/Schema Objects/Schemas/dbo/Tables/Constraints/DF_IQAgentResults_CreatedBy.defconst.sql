ALTER TABLE [dbo].[IQAgentResults]
    ADD CONSTRAINT [DF_IQAgentResults_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

