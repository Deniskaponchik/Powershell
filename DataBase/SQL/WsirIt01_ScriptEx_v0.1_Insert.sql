--Declare @SRnumber NVARCHAR(50) = ''

INSERT INTO ScriptExecute (
	--id,
	  DateStart0
	, DateEnd0
	, AdminLogin
	, AdminFIO
	, ScriptName
	, FeedBack
	)
VALUES (
	--NULL,
	  (case @DateStart0 when '' then NULL ELSE @DateStart0 END)     --'SR06014477'
	, (case @DateEnd0 when '' then NULL ELSE @DateEnd0 END)         --@SRlink
	, (case @AdminLogin when '' then NULL ELSE @AdminLogin END) --@AdminLogin --'admin.ws.tirskikh'
	, (case @AdminFIO when '' then NULL ELSE @AdminFIO END)     --@AdminFIO   --'������� ����� ����������'
	, (case @ScriptName when '' then NULL ELSE @ScriptName END)       --@Comment    --NULL
	, (case @FeedBack when '' then NULL ELSE @FeedBack END)     --@IncidentType --'������������� ����� �� ����� C:'
	);
--select * from ScriptExecute order by id DESC
