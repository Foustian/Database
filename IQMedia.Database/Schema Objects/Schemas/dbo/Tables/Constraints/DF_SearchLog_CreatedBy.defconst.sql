ALTER TABLE [dbo].[PMGSearchLog]
    ADD CONSTRAINT [DF_SearchLog_CreatedBy] DEFAULT ('System') FOR [CreatedBy];

