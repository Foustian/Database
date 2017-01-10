ALTER TABLE [dbo].[IQAgent_SearchRequest]
    ADD CONSTRAINT [DF_IQAgent_SearchRequest_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];