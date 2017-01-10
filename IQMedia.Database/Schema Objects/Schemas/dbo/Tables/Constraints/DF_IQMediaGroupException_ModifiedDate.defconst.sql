ALTER TABLE [dbo].[IQMediaGroupException]
    ADD CONSTRAINT [DF_IQMediaGroupException_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

