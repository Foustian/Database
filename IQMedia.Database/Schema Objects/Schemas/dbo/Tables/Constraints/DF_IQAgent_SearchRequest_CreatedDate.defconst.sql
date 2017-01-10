ALTER TABLE [dbo].[IQAgent_SearchRequest]
    ADD CONSTRAINT [DF_IQAgent_SearchRequest_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];