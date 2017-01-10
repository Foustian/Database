CREATE TABLE [dbo].[SM_SourceType] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [Lable]        VARCHAR (50) NOT NULL,
    [Value]        VARCHAR (50) NOT NULL,
    [Order_Number] INT          NOT NULL,
    [IsActive]     BIT          NOT NULL
);

