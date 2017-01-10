ALTER TABLE [dbo].[IQCore_NM]
    ADD CONSTRAINT [DF_IQCore_Nm_LastModified] DEFAULT (getdate()) FOR [LastModified];

