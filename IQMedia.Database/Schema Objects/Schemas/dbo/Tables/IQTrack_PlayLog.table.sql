CREATE TABLE [dbo].[IQTrack_PlayLog] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [_AssetGuid] UNIQUEIDENTIFIER NOT NULL,
    [PlayDate]   DATETIME         NOT NULL,
    [IPAddress]  VARCHAR (16)     NULL,
    [Referrer]   VARCHAR (2048)   NULL,
    [_UserGuid]  UNIQUEIDENTIFIER NULL
);

