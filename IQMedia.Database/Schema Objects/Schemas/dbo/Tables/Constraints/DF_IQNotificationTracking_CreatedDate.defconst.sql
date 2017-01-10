ALTER TABLE [dbo].[IQNotificationTracking]
    ADD CONSTRAINT [DF_IQNotificationTracking_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

