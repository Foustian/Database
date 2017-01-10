CREATE TABLE [dbo].[IQClient_UGCMap] (
    [IQClient_UGCMapKey] BIGINT           IDENTITY (1, 1) NOT NULL,
    [ClientGUID]         UNIQUEIDENTIFIER NOT NULL,
    [SourceGUID]         UNIQUEIDENTIFIER NOT NULL,
    [AutoClip_Status]    BIT              NOT NULL,
    [CreatedDate]        DATETIME         NULL,
    [ModifiedDate]       DATETIME         NULL,
    [CreatedBy]          VARCHAR (50)     NULL,
    [ModifiedBy]         VARCHAR (50)     NULL,
    [IsActive]           BIT              NULL
);

