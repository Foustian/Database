CREATE TABLE [dbo].[IQAgentResults] (
    [IQAgentResultKey]   BIGINT           IDENTITY (1, 1) NOT NULL,
    [SearchRequestID]    BIGINT           NULL,
    [Title120]           VARCHAR (128)    NULL,
    [iq_cc_key]          VARCHAR (28)     NULL,
    [RL_VideoGUID]       UNIQUEIDENTIFIER NULL,
    [Rl_Station]         VARCHAR (150)    NULL,
    [RL_Date]            DATE             NULL,
    [RL_Time]            INT              NULL,
    [RL_Market]          VARCHAR (150)    NULL,
    [Number_Hits]        INT              NULL,
    [Communication_flag] BIT              NULL,
    [CreatedDate]        DATETIME         NULL,
    [ModifiedDate]       DATETIME         NULL,
    [CreatedBy]          VARCHAR (150)    NULL,
    [ModifiedBy]         VARCHAR (150)    NULL,
    [IsActive]           BIT              NULL,
	IQAgentResultUrl	 varchar(255)	  NULL
);
GO

