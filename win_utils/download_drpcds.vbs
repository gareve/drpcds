Sub downloadFile(url,filename)
	' Set your settings
    strFileURL = url
    strHDLocation = filename

	' Fetch the file
	    Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")

	    objXMLHTTP.open "GET", strFileURL, false
	    objXMLHTTP.send()

	If objXMLHTTP.Status = 200 Then
		Set objADOStream = CreateObject("ADODB.Stream")
		objADOStream.Open
		objADOStream.Type = 1 'adTypeBinary

		objADOStream.Write objXMLHTTP.ResponseBody
		objADOStream.Position = 0    'Set the stream position to the start

		Set objFSO = Createobject("Scripting.FileSystemObject")
		If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile strHDLocation
		Set objFSO = Nothing

		objADOStream.SaveToFile strHDLocation
		objADOStream.Close
		Set objADOStream = Nothing
	End if

	Set objXMLHTTP = Nothing
End Sub

fileA = "unzip.exe"
fileB = "Ruby193.zip"
fileC = "drpcds.zip"
fileD = "hashcat-0.44.zip"
fileE = "client.config"
host = "http://192.168.2.111/distributed/"

Call downloadFile(host+fileA,fileA)
Call downloadFile(host+fileB,fileB)
Call downloadFile(host+fileC,fileC)
Call downloadFile(host+fileD,fileD)
Call downloadFile(host+fileE,fileE)


Dim objShell
Set objShell = WScript.CreateObject ("WScript.shell")
objShell.run "cmd /c unzip " + fileB + " && " + "unzip " + fileC + " && " + " unzip " + fileD + " && move client.config drpcds && cd drpcds && start_win_clients.bat"
Set objShell = Nothing