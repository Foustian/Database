CREATE TABLE [dbo].[InboundReporting] (
    [InboundReportingKey] BIGINT       IDENTITY (1, 1) NOT NULL,
    [RequestCollection]   XML          NULL,
    [CreatedBy]           VARCHAR (50) NULL,
    [ModifiedBy]          VARCHAR (50) NULL,
    [CreatedDate]         DATETIME     NULL,
    [ModifiedDate]        DATETIME     NULL,
    [IsActive]            BIT          NULL
);

