CREATE TABLE [dbo].[BillType] (
    [BillTypeKey]           BIGINT       IDENTITY (1, 1) NOT NULL,
    [Bill_Type]             VARCHAR (3)  NULL,
    [Bill_Type_Description] VARCHAR (50) NULL,
    [CreatedDate]           DATETIME     NULL,
    [CreatedBy]             VARCHAR (50) NULL,
    [ModifiedDate]          DATETIME     NULL,
    [ModifiedBy]            VARCHAR (50) NULL,
    [IsActive]              BIT          NULL
);

