ALTER TABLE [dbo].[SSP_IQ_Dma_Name]
    ADD CONSTRAINT [DF_SSP_IQ_Dma_Name_IsActive] DEFAULT ((1)) FOR [IsActive];

