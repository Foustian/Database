ALTER TABLE [dbo].[ClipDownload]
    ADD CONSTRAINT [DF_ClipDownload_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

