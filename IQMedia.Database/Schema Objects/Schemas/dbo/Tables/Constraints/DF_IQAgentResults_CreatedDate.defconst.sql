ALTER TABLE [dbo].[IQAgentResults]
    ADD CONSTRAINT [DF_IQAgentResults_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

