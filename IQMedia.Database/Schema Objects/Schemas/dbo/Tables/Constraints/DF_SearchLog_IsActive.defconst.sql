ALTER TABLE [dbo].[PMGSearchLog]
    ADD CONSTRAINT [DF_SearchLog_IsActive] DEFAULT ((1)) FOR [IsActive];

