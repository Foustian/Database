﻿ALTER TABLE [dbo].[ArchiveBLPMDownload]
    ADD CONSTRAINT [FK_ArchiveBLPMDownload_ArchiveBLPM] FOREIGN KEY ([ArchiveBLPMKey]) REFERENCES [dbo].[ArchiveBLPM] ([ArchiveBLPMKey]) ON DELETE NO ACTION ON UPDATE NO ACTION;