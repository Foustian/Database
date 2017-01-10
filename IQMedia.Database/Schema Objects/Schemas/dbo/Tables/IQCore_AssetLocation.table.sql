CREATE TABLE [dbo].[IQCore_AssetLocation] (
    [_AssetGuid]   UNIQUEIDENTIFIER NOT NULL,
    [_AssetTypeID] INT              NOT NULL,
    [_RootPathID]  INT              NOT NULL,
    [Location]     VARCHAR (255)    NOT NULL
);

