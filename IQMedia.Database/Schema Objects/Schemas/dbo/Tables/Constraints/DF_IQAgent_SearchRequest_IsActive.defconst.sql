ALTER TABLE [dbo].[IQAgent_SearchRequest]
    ADD CONSTRAINT [DF_IQAgent_SearchRequest_IsActive] DEFAULT (1) FOR [IsActive];