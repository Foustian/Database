﻿ALTER TABLE [dbo].[IQAgent_TwitterResults] ADD  CONSTRAINT [DF_IQAgentTwitterResult_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]