CREATE TABLE [dbo].[NIELSEN_LOCMTHLY] (
    [IQ_CC_KEY]        VARCHAR (28) NULL,
    [LOCAL_AIR_DATE]   DATETIME     NULL,
    [GMT_AIR_DATE]     DATETIME     NULL,
    [IQ_START_POINT]   FLOAT        NULL,
    [IQ_CLASS]         VARCHAR (13) NULL,
    [IQ_CLASS_NUM]     VARCHAR (2)  NULL,
    [MARKET_CODE]      INT          NULL,
    [DISTRIBUTOR_CODE] INT          NULL,
    [07TOTAL]          INT          NULL,
    [08TOTAL]          INT          NULL,
    [09TOTAL]          INT          NULL,
    [04TOTAL]          INT          NULL,
    [RATINGS_PT]       FLOAT        NULL,
    [DOW]              NCHAR (1)    NULL,
    [NIELSEN_FILENAME] VARCHAR (50) NULL,
    [CreatedDate]      DATETIME     NULL,
    [ModifiedDate]     DATETIME     NULL
);

