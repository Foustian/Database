ALTER TABLE [dbo].[IQAgentSearchRequest]
    ADD CONSTRAINT [DF_SearchRequest_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

