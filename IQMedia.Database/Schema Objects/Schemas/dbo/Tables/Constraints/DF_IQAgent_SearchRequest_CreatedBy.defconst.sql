ALTER TABLE [dbo].[IQAgent_SearchRequest]
    ADD CONSTRAINT [DF_IQAgent_SearchRequest_CreatedBy] DEFAULT ('System') FOR [CreatedBy];