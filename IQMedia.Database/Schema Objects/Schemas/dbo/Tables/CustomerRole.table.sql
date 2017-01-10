CREATE TABLE [dbo].[CustomerRole] (
    [CustomerRoleKey] BIGINT       IDENTITY (1, 1) NOT NULL,
    [CustomerID]      BIGINT       NOT NULL,
    [RoleID]          BIGINT       NOT NULL,
    [IsAccess]        BIT          NULL,
    [CreatedBy]       VARCHAR (50) NULL,
    [ModifiedBy]      VARCHAR (50) NULL,
    [CreatedDate]     DATETIME     NULL,
    [ModifiedDate]    DATETIME     NULL,
    [IsActive]        BIT          NULL
);

