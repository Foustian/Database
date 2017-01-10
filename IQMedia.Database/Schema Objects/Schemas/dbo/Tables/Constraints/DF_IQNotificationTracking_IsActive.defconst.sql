ALTER TABLE [dbo].[IQNotificationTracking]
    ADD CONSTRAINT [DF_IQNotificationTracking_IsActive] DEFAULT ((1)) FOR [IsActive];

