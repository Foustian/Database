CREATE TABLE [dbo].[State] (
    [StateKey]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [StateName]    VARCHAR (150) NULL,
    [CreatedDate]  DATETIME      NULL,
    [CreatedBy]    VARCHAR (50)  NULL,
    [ModifiedDate] DATETIME      NULL,
    [ModifiedBy]   VARCHAR (50)  NULL,
    [IsActive]     BIT           NULL
);

