﻿ALTER TABLE [dbo].[IQCustomer_DefaultSettings]
    ADD CONSTRAINT [PK_IQCustomer_DefaultSettings] PRIMARY KEY CLUSTERED ([_CustomerGuid] ASC, [Field] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

