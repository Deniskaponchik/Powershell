Get-EventLog System -Newest 10000 |
Where-Object EventId -in 41,1074,1076,6005,6006,6008,6009,6013 |
Format-Table TimeGenerated,EventId,UserName,Message -AutoSize -wrap