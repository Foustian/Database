ALTER TABLE [dbo].[IQClient_CustomSettings_old]
    ADD CONSTRAINT [DF_IQClient_CustomSettings_IsActive] DEFAULT ((1)) FOR [IsActive];

