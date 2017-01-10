ALTER TABLE [dbo].[IQClient_StationSharing]
    ADD CONSTRAINT [DF_IQClient_StationSharing_DateCreated] DEFAULT (getdate()) FOR [DateCreated];