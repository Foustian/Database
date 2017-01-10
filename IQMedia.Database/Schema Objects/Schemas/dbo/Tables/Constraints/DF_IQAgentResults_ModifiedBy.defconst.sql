ALTER TABLE [dbo].[IQAgentResults]
    ADD CONSTRAINT [DF_IQAgentResults_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

