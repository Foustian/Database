CREATE TABLE [dbo].[ClientRole] (
    [ClientRoleKey] BIGINT       IDENTITY (1, 1) NOT NULL,
    [ClientID]      BIGINT       NULL,
    [RoleID]        BIGINT       NULL,
    [IsAccess]      BIT          NULL,
    [CreatedBy]     VARCHAR (50) NULL,
    [ModifiedBy]    VARCHAR (50) NULL,
    [CreatedDate]   DATETIME     NULL,
    [ModifiedDate]  DATETIME     NULL,
    [IsActive]      BIT          NULL
);

