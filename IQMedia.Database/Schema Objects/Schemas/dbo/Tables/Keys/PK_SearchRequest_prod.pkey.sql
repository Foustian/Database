﻿ALTER TABLE [dbo].[IQAgentSearchRequest_prod]
    ADD CONSTRAINT [PK_SearchRequest_prod] PRIMARY KEY CLUSTERED ([SearchRequestKey] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);
