ALTER TABLE [dbo].[IQClient_StationSharing]
    ADD CONSTRAINT [DF_IQClient_StationSharing_DateModified] DEFAULT (getdate()) FOR [DateModified];