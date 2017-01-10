ALTER TABLE [dbo].[PMGSearchLog]
    ADD CONSTRAINT [DF_SearchLog_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

