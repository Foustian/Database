CREATE TABLE [dbo].[IQClient_CustomSettings_old] (
    [IQCustom_ClientID] BIGINT           IDENTITY (1, 1) NOT NULL,
    [ClientGUID]        UNIQUEIDENTIFIER NOT NULL,
    [IQAdvanceSettings] XML              NULL,
    [SearchSettings]    XML              NULL,
    [IsActive]          BIT              NULL
);

