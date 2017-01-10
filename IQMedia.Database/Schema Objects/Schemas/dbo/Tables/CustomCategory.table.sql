CREATE TABLE [dbo].[CustomCategory] (
    [CategoryKey]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [ClientGUID]          UNIQUEIDENTIFIER NULL,
    [CategoryGUID]        UNIQUEIDENTIFIER ROWGUIDCOL NULL,
    [CategoryName]        VARCHAR (150)    NULL,
    [CategoryDescription] VARCHAR (2000)   NULL,
    [CreatedDate]         DATETIME         NULL,
    [ModifiedDate]        DATETIME         NULL,
    [IsActive]            BIT              NOT NULL,
	[CategoryRanking]	  INT			   NULL
);

