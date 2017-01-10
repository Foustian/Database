ALTER TABLE [dbo].[ClipDownloadSettings]
    ADD CONSTRAINT [DF_ClipDownloadSettings_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

