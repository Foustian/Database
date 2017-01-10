ALTER TABLE [dbo].[SSP_IQ_Cat]
    ADD CONSTRAINT [DF_SSP_IQ_Cat_ModifiedDate] DEFAULT (getdate()) FOR [ModifiedDate];

