ALTER TABLE [dbo].[State]
    ADD CONSTRAINT [DF_State_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];

