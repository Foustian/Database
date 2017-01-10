ALTER TABLE [dbo].[IQAgentResults]
    ADD CONSTRAINT [DF_IQAgentResults_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

