ALTER TABLE [dbo].[IQMediaGroupException]
    ADD CONSTRAINT [DF_IQMediaGroupException_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

