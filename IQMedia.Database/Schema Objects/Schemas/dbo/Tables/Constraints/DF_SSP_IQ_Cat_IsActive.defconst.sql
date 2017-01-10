ALTER TABLE [dbo].[SSP_IQ_Cat]
    ADD CONSTRAINT [DF_SSP_IQ_Cat_IsActive] DEFAULT ((1)) FOR [IsActive];

