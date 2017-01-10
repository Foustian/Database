CREATE TABLE [dbo].[Type] (
    [TypeKey]      INT          IDENTITY (1, 1) NOT NULL,
    [TypeName]     VARCHAR (50) NULL,
    [CreatedBy]    VARCHAR (50) NULL,
    [ModifiedBy]   VARCHAR (50) NULL,
    [CreatedDate]  DATETIME     NULL,
    [ModifiedDate] DATETIME     NULL,
    [IsActive]     BIT          NULL
);

