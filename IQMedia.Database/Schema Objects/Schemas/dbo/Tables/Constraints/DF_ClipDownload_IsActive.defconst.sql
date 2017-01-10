ALTER TABLE [dbo].[ClipDownload]
    ADD CONSTRAINT [DF_ClipDownload_IsActive] DEFAULT ((1)) FOR [IsActive];

