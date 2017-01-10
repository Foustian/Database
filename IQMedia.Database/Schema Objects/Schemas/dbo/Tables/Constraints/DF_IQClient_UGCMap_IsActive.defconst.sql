ALTER TABLE [dbo].[IQClient_UGCMap]
    ADD CONSTRAINT [DF_IQClient_UGCMap_IsActive] DEFAULT ((1)) FOR [IsActive];

