ALTER TABLE [dbo].[ClientRole]
    ADD CONSTRAINT [DF_ClientRole_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

