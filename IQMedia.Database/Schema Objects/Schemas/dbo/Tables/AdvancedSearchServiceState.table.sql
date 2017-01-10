CREATE TABLE [dbo].[AdvancedSearchServiceState] (
    [AdvancedSearchServiceStateKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [SearchCriteria]                VARCHAR (MAX) NOT NULL,
    [SessionID]                     VARCHAR (MAX) NOT NULL,
    [SSPPageNo]                     INT           NOT NULL,
    [IQCCKeyServed]                 VARCHAR (MAX) NOT NULL,
    [PMGPageNo]                     INT           NOT NULL,
    [PageNo]                        INT           NOT NULL,
    [RequestedDate]                 DATETIME      NOT NULL,
    [IsSamePMGPage]                 BIT           NOT NULL,
    [PMGPageEndIndex]               INT           NOT NULL
);

