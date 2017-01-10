CREATE TABLE [dbo].[TypeValue] (
    [TypeValueKey] INT          IDENTITY (1, 1) NOT NULL,
    [TypeID]       INT          NULL,
    [ValueName]    VARCHAR (50) NULL,
    [CreatedBy]    VARCHAR (50) NULL,
    [ModifiedBy]   VARCHAR (50) NULL,
    [CreatedDate]  DATETIME     NULL,
    [ModifiedDate] DATETIME     NULL,
    [IsActive]     BIT          NULL
);

