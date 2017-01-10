CREATE TABLE [dbo].[RL_GUIDS] (
    [RL_GUIDSKey]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [RL_Station_ID]   VARCHAR (50)  NULL,
    [RL_Station_Date] DATE          NULL,
    [RL_Station_Time] INT           NULL,
    [RL_Time_zone]    VARCHAR (150) NULL,
    [RL_GUID]         VARCHAR (150) NULL,
    [GMT_Date]        DATE          NULL,
    [GMT_Time]        INT           NULL,
    [IQ_CC_Key]       VARCHAR (150)  NULL,
    [GUID_Status]     BIT           NULL,
    [CreatedBy]       VARCHAR (50)  NULL,
    [ModifiedBy]      VARCHAR (50)  NULL,
    [CreatedDate]     DATETIME      NULL,
    [ModifiedDate]    DATETIME      NULL,
    [IsActive]        BIT           NULL
);

