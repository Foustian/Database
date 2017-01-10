Create Trigger [dbo].[Tr_Upd_IQAgent_MediaResults] on [dbo].[IQAgent_MediaResults]
For Update As

If (Update(IsActive))
   Begin
  	 Update dbo.IQAgent_NMResults set IsActive=i.IsActive,ModifiedDate = GETDATE() From dbo.IQAgent_NMResults tv , inserted i where tv.ID=i._MediaID and i.MediaType='NM'
	 If @@ERROR <> 0
	    RollBack Tran
	
	 Update dbo.IQAgent_SMResults set IsActive=i.IsActive,ModifiedDate = GETDATE() From dbo.IQAgent_SMResults tv , inserted i where tv.ID=i._MediaID and i.MediaType='SM'
	 If @@ERROR <> 0
	    RollBack Tran
	
	 Update dbo.IQAgent_TVResults set IsActive=i.IsActive,ModifiedDate = GETDATE() From dbo.IQAgent_TVResults tv , inserted i where tv.ID=i._MediaID and i.MediaType='TV'
	 If @@ERROR <> 0
		RollBack Tran
	 
	 Update dbo.IQAgent_TwitterResults set IsActive=i.IsActive,ModifiedDate = GETDATE() From dbo.IQAgent_TwitterResults tv , inserted i where tv.ID=i._MediaID and i.MediaType='TW'
	 If @@ERROR <> 0
		RollBack Tran
	
	 Update dbo.IQAgent_TVEyesResults set IsActive=i.IsActive,ModifiedDate = GETDATE() From dbo.IQAgent_TVEyesResults tv , inserted i where tv.ID=i._MediaID and i.MediaType='TM'
	 If @@ERROR <> 0 
	   RollBack Tran
  
     Update dbo.IQAgent_BLPMResults set IsActive=i.IsActive,ModifiedDate = GETDATE() From dbo.IQAgent_BLPMResults tv , inserted i where tv.ID=i._MediaID and i.MediaType='PM'
     If @@ERROR <> 0 
	   RollBack Tran
  
     Update dbo.IQAgent_PQResults set IsActive=i.IsActive,ModifiedDate = GETDATE() From dbo.IQAgent_PQResults tv , inserted i where tv.ID=i._MediaID and i.MediaType='PQ'
     If @@ERROR <> 0 
	   RollBack Tran

	   Insert into dbo.IQAgent_MediaResults_DirtyTable
    (MediaResultsID,MediaID,_SearchRequestID,MediaType,Category,MediaDate,PositiveSentiment,NegativeSentiment,IsActive)
    Select INSERTED.ID,INSERTED._MediaID,INSERTED._SearchRequestID, INSERTED.MediaType,INSERTED.Category,INSERTED.MediaDate,
    INSERTED.PositiveSentiment,INSERTED.NegativeSentiment,INSERTED.IsActive From INSERTED
 If @@ERROR <> 0 
	   RollBack Tran
		  
   End
