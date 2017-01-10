ALTER TABLE [dbo].[IQClient_UGCMap]
    ADD CONSTRAINT [DF_IQClient_UGCMap_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

