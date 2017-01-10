ALTER TABLE [dbo].[IQAgentSearchRequest]
    ADD CONSTRAINT [DF_SearchRequest_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

