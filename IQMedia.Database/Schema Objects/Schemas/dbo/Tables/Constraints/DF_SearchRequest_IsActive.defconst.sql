ALTER TABLE [dbo].[IQAgentSearchRequest]
    ADD CONSTRAINT [DF_SearchRequest_IsActive] DEFAULT ((1)) FOR [IsActive];

