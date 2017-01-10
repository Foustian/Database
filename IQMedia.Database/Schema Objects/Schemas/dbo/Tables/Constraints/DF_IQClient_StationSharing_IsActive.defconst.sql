ALTER TABLE [dbo].[IQClient_StationSharing]
    ADD CONSTRAINT [DF_IQClient_StationSharing_IsActive] DEFAULT ((1)) FOR [IsActive];