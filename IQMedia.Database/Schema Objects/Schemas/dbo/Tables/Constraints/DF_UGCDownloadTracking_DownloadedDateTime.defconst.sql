ALTER TABLE [dbo].[UGCDownloadTracking]
    ADD CONSTRAINT [DF_UGCDownloadTracking_DownloadedDateTime] DEFAULT (getdate()) FOR [DownloadedDateTime];

