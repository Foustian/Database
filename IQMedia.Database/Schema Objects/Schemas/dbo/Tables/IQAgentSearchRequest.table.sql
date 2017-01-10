CREATE TABLE [dbo].[IQAgentSearchRequest] (
    [SearchRequestKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ClientID]         BIGINT        NULL,
    [Query_Name]       VARCHAR (100) NULL,
    [Query_Version]    INT           NULL,
    [SearchTerm]       XML           NULL,
	[_CustomerSavedSearchID]	BIGINT	NULL,
    [CreatedDate]      DATETIME      NULL,
    [ModifiedDate]     DATETIME      NULL,
    [CreatedBy]        VARCHAR (150) NULL,
    [ModifiedBy]       VARCHAR (150) NULL,
    [IsActive]         BIT           NULL
);

GO
ALTER TABLE IQAgentSearchRequest
ADD CONSTRAINT FK_IQAgentSearchRequest_CustomerSavedSearchID_IQCustomer_SavedSearchID FOREIGN KEY (_CustomerSavedSearchID)
REFERENCES IQCustomer_SavedSearch
(ID)