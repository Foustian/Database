ALTER TABLE [dbo].[SSP_IQ_Dma_Name]
    ADD CONSTRAINT [DF_SSP_IQ_Dma_Name_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

