CREATE TABLE [dbo].[IQTrack_PlayerMsgLog] (
    [ID]             INT              IDENTITY (1, 1) NOT NULL,
    [LogDate]        DATETIME         NOT NULL,
    [IPAddress]      VARCHAR (16)     NULL,
    [LogType]        VARCHAR (50)     NOT NULL,
    [Message]        VARCHAR (2048)   NOT NULL,
    [AdditionalData] VARCHAR (2048)   NULL,
    [Referrer]       VARCHAR (2048)   NULL,
    [_AssetGuid]     UNIQUEIDENTIFIER NULL,
    [_UserGuid]      UNIQUEIDENTIFIER NULL
);

