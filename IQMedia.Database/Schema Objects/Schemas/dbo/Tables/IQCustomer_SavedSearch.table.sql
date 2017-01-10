CREATE TABLE [dbo].[IQCustomer_SavedSearch] (
    [ID]                     BIGINT           IDENTITY (1, 1) NOT NULL,
    [CustomerGuid]           UNIQUEIDENTIFIER NOT NULL,
    [IQPremiumSearchRequest] XML              NOT NULL,
    [Title]                  VARCHAR (150)    NOT NULL,
    [Description]            VARCHAR (500)    NULL,
    [CategoryGuid]           UNIQUEIDENTIFIER NOT NULL,
	IsIQAgent				 BIT			  NULL,
    [CreatedDate]            DATETIME         NULL,
    [ModifiedDate]           DATETIME         NULL,
    [IsActive]               BIT              NOT NULL
);


