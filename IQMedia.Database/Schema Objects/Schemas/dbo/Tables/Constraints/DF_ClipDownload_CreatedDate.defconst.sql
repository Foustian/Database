ALTER TABLE [dbo].[ClipDownload]
    ADD CONSTRAINT [DF_ClipDownload_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

