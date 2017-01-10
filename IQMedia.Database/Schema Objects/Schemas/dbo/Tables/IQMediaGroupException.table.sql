CREATE TABLE [dbo].[IQMediaGroupException] (
    [IQMediaGroupExceptionKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ExceptionStackTrace]      VARCHAR (MAX) NULL,
    [ExceptionMessage]         VARCHAR (MAX) NULL,
    [ExceptionDate]            DATETIME      NULL,
    [CreatedBy]                VARCHAR (50)  NULL,
    [ModifiedBy]               VARCHAR (50)  NULL,
    [CreatedDate]              DATETIME      NULL,
    [ModifiedDate]             DATETIME      NULL,
    [IsActive]                 BIT           NULL
);

