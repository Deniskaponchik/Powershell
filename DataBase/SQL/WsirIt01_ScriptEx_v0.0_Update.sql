--Declare @SRnumber NVARCHAR(50) = ''

Update ScriptExecute

SET
	  --DateStart = (case @DateStart when '' then NULL ELSE @DateStart END),

	  --DateEnd = (case @DateEnd when '' then NULL ELSE @DateEnd END) 
	    DateEnd = isnull(DateEnd, @DateEnd)

	--, AdminLogin = (case @AdminLogin when '' then NULL ELSE @AdminLogin END) 
	  , AdminLogin = isnull(AdminLogin, @AdminLogin)

	--, AdminFIO = (case @AdminFIO when '' then NULL ELSE @AdminFIO END) 
	  , AdminFIO = isnull(AdminFIO, @AdminFIO)
	
	--, ScriptName = (case @ScriptName when '' then NULL ELSE @ScriptName END)
	  , ScriptName = isnull(ScriptName, @ScriptName) 
	
	--, FeedBack = (case @FeedBack when '' then NULL ELSE @FeedBack END)
	  , FeedBack = isnull(FeedBack, @FeedBack) 

WHERE DateStart = @DateStart

--select * from ScriptExecute order by id DESC
--select Get-Date
