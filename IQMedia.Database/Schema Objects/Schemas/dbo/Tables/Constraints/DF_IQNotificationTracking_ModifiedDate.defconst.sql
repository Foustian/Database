ALTER TABLE [dbo].[IQNotificationTracking]
    ADD CONSTRAINT [DF_IQNotificationTracking_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

