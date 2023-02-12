--Declare @SRnumber NVARCHAR(50) = ''

INSERT INTO ScriptExecute (
	--id,
	  DateStart
	--, DateEnd
	, AdminLogin
	, AdminFIO
	, ScriptName
	, FeedBack
	)
VALUES (
	--NULL,
	  (case @DateStart when '' then NULL ELSE @DateStart END)     --'SR06014477'
  --, (case @DateEnd when '' then NULL ELSE @DateEnd END)
	, (case @AdminLogin when '' then NULL ELSE @AdminLogin END) --@AdminLogin --'admin.ws.tirskikh'
	, (case @AdminFIO when '' then NULL ELSE @AdminFIO END)     --@AdminFIO   --'Тирских Денис Алексеевич'
	, (case @ScriptName when '' then NULL ELSE @ScriptName END)       --@Comment    --NULL
	, (case @FeedBack when '' then NULL ELSE @FeedBack END)     --@IncidentType --'Заканчивается место на диске C:'
	);
--select * from ScriptExecute order by id DESC
