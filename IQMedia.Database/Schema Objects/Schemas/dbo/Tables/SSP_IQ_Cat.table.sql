CREATE TABLE [dbo].[SSP_IQ_Cat] (
    [SSP_IQ_CatKey] INT          IDENTITY (1, 1) NOT NULL,
    [IQ_Cat_Num]    VARCHAR (2)  NULL,
    [IQ_Cat]        VARCHAR (8)  NOT NULL,
    [CreatedDate]   DATETIME     NULL,
    [ModifiedDate]  DATETIME     NULL,
    [CreatedBy]     VARCHAR (50) NULL,
    [ModifiedBy]    VARCHAR (50) NULL,
    [IsActive]      BIT          NULL
);

