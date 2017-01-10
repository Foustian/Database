CREATE TABLE [dbo].[RL_CC_TEXT2] (
    [RL_CC_TEXTKey]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [RL_Station_ID]       VARCHAR (50)  NULL,
    [RL_Station_Date]     DATE          NULL,
    [RL_Station_Time]     INT           NULL,
    [RL_Time_Zone]        VARCHAR (150) NULL,
    [RL_CC_FileName]      VARCHAR (150) NULL,
    [RL_CC_File_Location] VARCHAR (250) NULL,
    [GMT_Date]            DATE          NULL,
    [GMT_Time]            INT           NULL,
    [IQ_CC_Key]           VARCHAR (150) NULL,
    [CC_File_Status]      VARCHAR (50)  NULL,
    [CC_Ingest_Date]      DATETIME      NULL,
    [CreatedBy]           VARCHAR (50)  NULL,
    [ModifiedBy]          VARCHAR (50)  NULL,
    [CreatedDate]         DATETIME      NULL,
    [ModifiedDate]        DATETIME      NULL,
    [IsActive]            BIT           NULL
);

