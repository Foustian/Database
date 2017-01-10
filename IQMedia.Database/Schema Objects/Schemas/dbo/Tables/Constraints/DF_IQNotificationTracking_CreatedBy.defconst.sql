ALTER TABLE [dbo].[IQNotificationTracking]
    ADD CONSTRAINT [DF_IQNotificationTracking_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

