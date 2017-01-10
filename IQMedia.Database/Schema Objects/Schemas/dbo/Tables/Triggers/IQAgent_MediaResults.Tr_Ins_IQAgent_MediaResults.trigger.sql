Create Trigger [dbo].[Tr_Ins_IQAgent_MediaResults] on [dbo].[IQAgent_MediaResults]
For Insert As
Begin
Insert into dbo.IQAgent_MediaResults_DirtyTable
(MediaResultsID,MediaID,_SearchRequestID,MediaType,Category,MediaDate,PositiveSentiment,NegativeSentiment,IsActive)
Select INSERTED.ID,INSERTED._MediaID,INSERTED._SearchRequestID, INSERTED.MediaType,INSERTED.Category,INSERTED.MediaDate,INSERTED.PositiveSentiment,INSERTED.NegativeSentiment,Inserted.IsActive From Inserted
End