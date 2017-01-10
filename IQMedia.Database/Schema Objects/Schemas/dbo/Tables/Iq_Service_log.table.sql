CREATE TABLE [dbo].[Iq_Service_log] (
    [Iq_Service_logKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ModuleName]        VARCHAR (50)  NULL,
    [CreatedDatetime]   DATETIME      NULL,
    [ServiceCode]       VARCHAR (150) NULL,
    [ConfigRequest]     XML           NULL,
    [CreatedBy]         VARCHAR (50)  NULL,
    [ModifiedBy]        VARCHAR (50)  NULL,
    [CreatedDate]       DATETIME      NULL,
    [ModifiedDate]      DATETIME      NULL,
    [IsActive]          BIT           NULL
);

