ALTER TABLE [dbo].[IQNotificationTracking]
    ADD CONSTRAINT [DF_IQNotificationTracking_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

