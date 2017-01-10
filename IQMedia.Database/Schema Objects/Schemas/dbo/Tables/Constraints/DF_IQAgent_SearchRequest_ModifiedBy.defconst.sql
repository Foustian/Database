ALTER TABLE [dbo].[IQAgent_SearchRequest]
    ADD CONSTRAINT [DF_IQAgent_SearchRequest_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];