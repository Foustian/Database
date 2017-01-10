ALTER TABLE [dbo].[SSP_IQ_Cat]
    ADD CONSTRAINT [DF_SSP_IQ_Cat_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

