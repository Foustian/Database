﻿ALTER TABLE [dbo].[SSP_IQ_Dma_Name]
    ADD CONSTRAINT [FK_SSP_IQ_Dma_Name_IQRegion] FOREIGN KEY ([RegionID]) REFERENCES [dbo].[IQRegion] ([ID]) ON DELETE NO ACTION ON UPDATE NO ACTION;

