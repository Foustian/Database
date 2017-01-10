ALTER TABLE [dbo].[IQClient_UGCMap]
    ADD CONSTRAINT [DF_IQClient_UGCMap_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

