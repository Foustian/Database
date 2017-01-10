CREATE TABLE [dbo].[PMGSearchLog] (
    [PMGSearchLogKey]  BIGINT       IDENTITY (1, 1) NOT NULL,
    [CustomerID]       INT          NULL,
    [SearchType]       VARCHAR (50) NULL,
    [RequestXML]       XML          NULL,
    [ErrorResponseXML] XML          NULL,
    [CreatedDate]      DATETIME     NULL,
    [ModifiedDate]     DATETIME     NULL,
    [CreatedBy]        VARCHAR (50) NULL,
    [ModifiedBy]       VARCHAR (50) NULL,
    [IsActive]         BIT          NULL
);

