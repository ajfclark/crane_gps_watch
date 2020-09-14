#!/usr/bin/python3
import requests
from datetime import datetime
data = "\n-\n\aexpress\u0012\u0005de_DE\u001A\aWindows\"\u0012601 Service Pack 1\u0012\n\b\x8C\xB4\x93\xB8\u000E\u0012\u0000\u0018\u0000\u0018\u001C\"\u0000"
headers = {
	'Garmin-Client-Name':'CoreService',
	'Content-Type':'application/octet-stream',
	'Content-Length':'63'
}

response = requests.post('http://omt.garmin.com/Rce/ProtobufApi/EphemerisService/GetEphemerisData', data = data, headers = headers)

now = datetime.now()

with open('MTK7d.' + datetime.utcnow().isoformat() + '.EPO', 'wb') as outFile:
	for chunk in [response.content[i+3:i+2307] for i in range(0, len(response.content), 2307)]:
			for record in [chunk[i:i+72] for i in range(0, len(chunk), 72)]:
				outFile.write(record[:60])
