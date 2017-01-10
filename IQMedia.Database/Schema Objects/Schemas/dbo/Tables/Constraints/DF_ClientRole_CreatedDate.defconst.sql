ALTER TABLE [dbo].[ClientRole]
    ADD CONSTRAINT [DF_ClientRole_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

