CREATE TABLE [dbo].[RL_Station_exception] (
    [RL_Station_exceptionKey] BIGINT        IDENTITY (1, 1) NOT NULL,
    [RL_Station_ID]           VARCHAR (150) NULL,
    [RL_Station_Date]         DATE          NULL,
    [RL_Station_Time]         INT           NULL,
    [Time_zone]               VARCHAR (150) NULL,
    [GMT_Adj]                 VARCHAR (150) NULL,
    [DST_Adj]                 VARCHAR (150) NULL,
    [IQ_Process]              VARCHAR (MAX) NULL,
    [Pass_count]              VARCHAR (50)  NULL,
    [CreatedBy]               VARCHAR (50)  NULL,
    [ModifiedBy]              VARCHAR (50)  NULL,
    [CreatedDate]             DATETIME      NULL,
    [ModifiedDate]            DATETIME      NULL,
    [IsActive]                BIT           NULL,
    [RQ_Converted_Date]       DATE          NULL,
    [RQ_Converted_Time]       INT           NULL
);

