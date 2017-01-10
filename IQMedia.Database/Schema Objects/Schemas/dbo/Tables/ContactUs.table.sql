CREATE TABLE [dbo].[ContactUs] (
    [ContactUsKey]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [FirstName]     VARCHAR (50)  NULL,
    [LastName]      VARCHAR (50)  NULL,
    [Email]         VARCHAR (300) NULL,
    [CompanyName]   VARCHAR (50)  NULL,
    [Title]         VARCHAR (50)  NULL,
    [Comments]      VARCHAR (500) NULL,
    [TelephoneNo]   VARCHAR (50)  NULL,
    [CreatedBy]     VARCHAR (50)  NULL,
    [ModifiedBy]    VARCHAR (50)  NULL,
    [CreatedDate]   DATETIME      NULL,
    [ModifiedDate]  DATETIME      NULL,
    [IsActive]      BIT           NULL,
    [ContactUsText] VARCHAR (MAX) NULL,
    [ContactUsInfo] XML           NULL
);

