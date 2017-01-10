﻿CREATE TABLE [dbo].[NM_Genre] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Name]         VARCHAR (250) NOT NULL,
    [Label]        VARCHAR (50) NOT NULL,
    [Order_Number] INT           NOT NULL,
    [IsActive]     BIT           NOT NULL
);

