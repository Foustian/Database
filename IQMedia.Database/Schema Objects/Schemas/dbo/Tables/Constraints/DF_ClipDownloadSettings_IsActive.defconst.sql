ALTER TABLE [dbo].[ClipDownloadSettings]
    ADD CONSTRAINT [DF_ClipDownloadSettings_IsActive] DEFAULT ((1)) FOR [IsActive];

