<%

Dim conDB
Set conDB = Server.CreateObject("ADODB.Connection")

On Error Resume Next
conDB.Open "Provider=SQLOLEDB;Data Source=LOCALHOST;Initial Catalog=BANCO_DE_DADOS;User ID=sa;Password=******;"

If Err.Number <> 0 Then
    Response.Write "Erro ao conectar: " & Err.Description
    Response.End
End If
On Error GoTo 0
%>
