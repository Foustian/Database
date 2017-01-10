ALTER TABLE [dbo].[PMGSearchLog]
    ADD CONSTRAINT [DF_SearchLog_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

