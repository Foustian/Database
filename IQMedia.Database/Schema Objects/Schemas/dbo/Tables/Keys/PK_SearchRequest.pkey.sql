﻿ALTER TABLE [dbo].[IQAgentSearchRequest]
    ADD CONSTRAINT [PK_SearchRequest] PRIMARY KEY CLUSTERED ([SearchRequestKey] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

