CREATE TABLE [dbo].[SocialMedia] (
    [ID]                          BIGINT        IDENTITY (1, 1) NOT NULL,
    [NewsMetabaseFilePath]        VARCHAR (MAX) NULL,
    [SocialMediaMetabaseFilePath] VARCHAR (MAX) NULL,
    [NewsImportedDate]            DATETIME      NULL,
    [SocialMediaImportedDate]     DATETIME      NULL
);

