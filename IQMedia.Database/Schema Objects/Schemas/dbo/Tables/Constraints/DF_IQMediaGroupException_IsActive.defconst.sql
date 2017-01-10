ALTER TABLE [dbo].[IQMediaGroupException]
    ADD CONSTRAINT [DF_IQMediaGroupException_IsActive] DEFAULT ((1)) FOR [IsActive];

