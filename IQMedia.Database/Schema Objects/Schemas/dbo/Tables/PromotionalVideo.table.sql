CREATE TABLE [dbo].[PromotionalVideo] (
    [PromotionalVideoKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [FilePath]            VARCHAR (200) NULL,
    [IsDisplay]           BIT           NULL,
    [Position]            VARCHAR (50)  NULL,
    [DisplayPageName]     VARCHAR (50)  NULL,
    [SrcPath]             VARCHAR (100) NULL,
    [MoviePath]           VARCHAR (100) NULL,
    [CreatedBy]           VARCHAR (50)  NULL,
    [ModifiedBy]          VARCHAR (50)  NULL,
    [CreatedDate]         DATETIME      NULL,
    [ModifiedDate]        DATETIME      NULL,
    [IsActive]            BIT           NULL
);

