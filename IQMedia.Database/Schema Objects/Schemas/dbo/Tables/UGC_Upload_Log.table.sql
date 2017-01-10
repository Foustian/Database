CREATE TABLE [dbo].[UGC_Upload_Log] (
    [UGC_Upload_LogKey] BIGINT           IDENTITY (1, 1) NOT NULL,
    [CustomerGUID]      UNIQUEIDENTIFIER NOT NULL,
    [UGCContentXml]     XML              NOT NULL,
    [FileName]          VARCHAR (100)    NOT NULL,
    [UploadedDateTime]  DATETIME         NOT NULL,
    [CreatedDate]       DATETIME         NULL,
    [ModifiedDate]      DATETIME         NULL,
    [CreatedBy]         VARCHAR (50)     NULL,
    [ModifiedBy]        VARCHAR (50)     NULL,
    [IsActive]          BIT              NULL
);

