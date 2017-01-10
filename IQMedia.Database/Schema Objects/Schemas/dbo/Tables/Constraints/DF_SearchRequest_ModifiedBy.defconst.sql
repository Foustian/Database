ALTER TABLE [dbo].[IQAgentSearchRequest]
    ADD CONSTRAINT [DF_SearchRequest_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

