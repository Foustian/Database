CREATE TABLE [dbo].[ClipDownload] (
    [IQ_ClipDownload_Key]    BIGINT           IDENTITY (1, 1) NOT NULL,
    [ClipID]                 UNIQUEIDENTIFIER NOT NULL,
    [CustomerGUID]           UNIQUEIDENTIFIER NOT NULL,
    [ClipDownloadStatus]     TINYINT          NOT NULL,
    [ClipDLRequestDateTime]  DATETIME         NULL,
    [ClipDLFormat]           VARCHAR (50)     NULL,
    [ClipFileLocation]       VARCHAR (150)    NULL,
    [ClipDownLoadedDateTime] DATETIME         NULL,
	[CCDownloadStatus]		 BIT			  NULL,
	[CCDownloadedDateTime]	 DATETIME2(7)	  NULL,
    [CreatedBy]              VARCHAR (50)     NULL,
    [ModifiedBy]             VARCHAR (50)     NULL,
    [CreatedDate]            DATETIME         NOT NULL,
    [ModifiedDate]           DATETIME         NOT NULL,
    [IsActive]               BIT              NOT NULL
);

