CREATE TABLE [dbo].[OutboundReporting] (
    [OutboundReportingKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [Query_Name]           VARCHAR (150) NULL,
    [ServiceType]          VARCHAR (150) NULL,
    [FromEmailAddress]     VARCHAR (150) NULL,
    [ToEmailAddress]       VARCHAR (150) NULL,
    [MailContent]          XML           NULL,
    [CreatedBy]            VARCHAR (50)  NULL,
    [ModifiedBy]           VARCHAR (50)  NULL,
    [CreatedDate]          DATETIME      NULL,
    [ModifiedDate]         DATETIME      NULL,
    [IsActive]             BIT           NULL
);

