CREATE TABLE [dbo].[MediaCategory] (
    [MediaCategoryKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [CategoryName]     VARCHAR (100) NULL,
    [CategoryCode]     VARCHAR (20)  NULL,
    [CreatedBy]        VARCHAR (50)  NULL,
    [ModifiedBy]       VARCHAR (50)  NULL,
    [CreatedDate]      DATETIME      NULL,
    [ModifiedDate]     DATETIME      NULL,
    [IsActive]         BIT           NULL
);

