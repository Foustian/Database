ALTER TABLE [dbo].[ClipDownloadSettings]
    ADD CONSTRAINT [DF_ClipDownloadSettings_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

