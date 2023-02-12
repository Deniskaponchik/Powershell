# https://www.winhelponline.com/blog/error-0x80070015-in-windows-update-microsoft-store-and-defender/

  eventvwr.msc

  Get-EventLog System -Newest 10000 |

# Reboot events
# Where-Object EventId -in 41,1074,1076,6005,6006,6008,6009,6013 |

# Doesn't work
# Where-Object TimeGenerated.Hour -ge 1 -and TimeGenerated.Hour -lt 2 |

  Format-Table TimeGenerated,EventId,UserName,Message -AutoSize -wrap
