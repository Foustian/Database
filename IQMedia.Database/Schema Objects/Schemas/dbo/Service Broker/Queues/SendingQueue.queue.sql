﻿CREATE QUEUE [dbo].[SendingQueue]
    WITH STATUS = ON, RETENTION = OFF, POISON_MESSAGE_HANDLING(STATUS = OFF), ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dbo].[usp_TableLockTest], MAX_QUEUE_READERS = 5, EXECUTE AS N'dbo');

