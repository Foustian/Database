ALTER TABLE [dbo].[ClipDownloadSettings]
    ADD CONSTRAINT [DF_ClipDownloadSettings_AudioFormat] DEFAULT ('mp3') FOR [AudioFormat];

