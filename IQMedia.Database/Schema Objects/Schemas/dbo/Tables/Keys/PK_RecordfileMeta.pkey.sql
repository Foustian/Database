﻿ALTER TABLE [dbo].[IQCore_RecordfileMeta]
    ADD CONSTRAINT [PK_RecordfileMeta] PRIMARY KEY CLUSTERED ([_RecordfileGuid] ASC, [Field] ASC) WITH (ALLOW_PAGE_LOCKS = ON, ALLOW_ROW_LOCKS = ON, PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF, STATISTICS_NORECOMPUTE = OFF);

