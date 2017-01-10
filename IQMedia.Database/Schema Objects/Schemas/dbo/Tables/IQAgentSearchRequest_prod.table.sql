CREATE TABLE [dbo].[IQAgentSearchRequest_prod] (
    [SearchRequestKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ClientID]         BIGINT        NULL,
    [IQ_Agent_UserID]  BIGINT        NULL,
    [Query_Name]       VARCHAR (100) NULL,
    [Query_Version]    INT           NULL,
    [SearchTerm]       XML           NULL,
    [CreatedDate]      DATETIME      NULL,
    [ModifiedDate]     DATETIME      NULL,
    [CreatedBy]        VARCHAR (150) NULL,
    [ModifiedBy]       VARCHAR (150) NULL,
    [IsActive]         BIT           NULL
);

