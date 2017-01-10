ALTER TABLE [dbo].[PMGSearchLog]
    ADD CONSTRAINT [DF_SearchLog_ModifiedBy] DEFAULT ('System') FOR [ModifiedBy];

