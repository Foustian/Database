ALTER TABLE [dbo].[ClipDownloadSettings]
    ADD CONSTRAINT [DF_ClipDownloadSettings_VideoFormat] DEFAULT ('mp4') FOR [VideoFormat];

