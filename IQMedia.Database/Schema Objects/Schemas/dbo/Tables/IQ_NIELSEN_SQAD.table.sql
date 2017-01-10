CREATE TABLE [dbo].[IQ_NIELSEN_SQAD] (
    [IQ_CC_KEY]        VARCHAR (28) NULL,
    [LOCAL_AIR_DATE]   DATETIME     NULL,
    [GMT_AIR_DATE]     DATETIME     NULL,
    [IQ_START_POINT]   FLOAT        NULL,
    [IQ_CLASS]         VARCHAR (13) NULL,
    [IQ_CLASS_NUM]     VARCHAR (2)  NULL,
    [MARKET_CODE]      INT          NULL,
    [DISTRIBUTOR_CODE] INT          NULL,
    [AUDIENCE]         INT          NULL,
    [UNIVERSE]         INT          NULL,
    [RATINGS_PT]       FLOAT        NULL,
    [DOW]              NCHAR (1)    NULL,
    [NIELSEN_FILENAME] VARCHAR (50) NULL,
    [CreatedDate]      DATETIME     NULL,
    [ModifiedDate]     DATETIME     NULL,
    [DAYPARTID]        INT          NULL,
    [SQAD_SHAREVALUE]  FLOAT        NULL,
    [SQADMARKETID]     FLOAT        NULL
);

