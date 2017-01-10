ALTER TABLE [dbo].[IQAgentSearchRequest]
    ADD CONSTRAINT [DF_SearchRequest_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

