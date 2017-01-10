CREATE TABLE [dbo].[IQCore_Clip] (
    [Guid]            UNIQUEIDENTIFIER NOT NULL,
    [StartOffset]     INT              NOT NULL,
    [EndOffset]       INT              NOT NULL,
    [DateCreated]     DATETIME         NOT NULL,
    [_RecordfileGuid] UNIQUEIDENTIFIER NOT NULL,
    [_UserGuid]       UNIQUEIDENTIFIER NOT NULL
);

