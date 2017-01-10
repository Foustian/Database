CREATE TABLE [dbo].[BillFrequency] (
    [BillFrequencyKey]           BIGINT       IDENTITY (1, 1) NOT NULL,
    [Bill_Frequency]             VARCHAR (3)  NULL,
    [Bill_Frequency_Description] VARCHAR (50) NULL,
    [CreatedDate]                DATETIME     NULL,
    [CreatedBy]                  VARCHAR (50) NULL,
    [ModifiedDate]               DATETIME     NULL,
    [ModifiedBy]                 VARCHAR (50) NULL,
    [IsActive]                   BIT          NULL
);

