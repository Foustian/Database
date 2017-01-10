ALTER TABLE [dbo].[IQAgentResults]
    ADD CONSTRAINT [DF_IQAgentResults_IsActive] DEFAULT ((1)) FOR [IsActive];

