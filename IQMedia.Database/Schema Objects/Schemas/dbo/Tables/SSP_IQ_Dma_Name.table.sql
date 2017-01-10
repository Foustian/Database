CREATE TABLE [dbo].[SSP_IQ_Dma_Name] (
    [SSP_IQ_Dma_NameKey] INT          IDENTITY (1, 1) NOT NULL,
    [IQ_Dma_Num]         VARCHAR (3)  NOT NULL,
    [IQ_Dma_Name]        VARCHAR (47) NOT NULL,
    [RegionID]           INT          NULL,
    [CreatedDate]        DATETIME     NULL,
    [ModifiedDate]       DATETIME     NULL,
    [CreatedBy]          VARCHAR (50) NULL,
    [ModifiedBy]         VARCHAR (50) NULL,
    [IsActive]           BIT          NULL
);

