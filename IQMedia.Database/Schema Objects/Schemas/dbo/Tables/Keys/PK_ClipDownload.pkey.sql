﻿ALTER TABLE [dbo].[ClipDownload]
    ADD CONSTRAINT [PK_ClipDownload] PRIMARY KEY CLUSTERED ([IQ_ClipDownload_Key] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

