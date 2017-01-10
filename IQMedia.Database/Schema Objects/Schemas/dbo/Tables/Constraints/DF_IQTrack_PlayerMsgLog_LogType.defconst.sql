ALTER TABLE [dbo].[IQTrack_PlayerMsgLog]
    ADD CONSTRAINT [DF_IQTrack_PlayerMsgLog_LogType] DEFAULT ('ERROR') FOR [LogType];

