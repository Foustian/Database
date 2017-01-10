CREATE TABLE [dbo].[Industry] (
    [IndustryKey]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [IndustryCode]         VARCHAR (10)  NULL,
    [Industry_Description] VARCHAR (100) NULL,
    [CreatedDate]          DATETIME      NULL,
    [CreatedBy]            VARCHAR (50)  NULL,
    [ModifiedDate]         DATETIME      NULL,
    [ModifiedBy]           VARCHAR (50)  NULL,
    [IsActive]             BIT           NULL
);

