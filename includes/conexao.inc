<%

Dim conDB
Set conDB = Server.CreateObject("ADODB.Connection")

On Error Resume Next
conDB.Open "Provider=SQLOLEDB;Data Source=DESKTOP-BKMKT08\SQLEXPRESS;Initial Catalog=api;User ID=sa;Password=Felipe123789qwe@;"

If Err.Number <> 0 Then
    Response.Write "Erro ao conectar: " & Err.Description
    Response.End
End If
On Error GoTo 0
%>
