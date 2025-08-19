<%@ LANGUAGE="VBSCRIPT" %>
<!--#include virtual="/includes/conexao.asp" -->

<%
Response.ContentType = "application/json"
Response.Charset = "UTF-8"

Dim rs, sql, first
Set rs = Server.CreateObject("ADODB.Recordset")

sql = "SELECT Id, Acao, Tabela, RegistroId, DataLog FROM Logs ORDER BY DataLog DESC"
rs.Open sql, conDB, 3, 3

Response.Write "["

first = True
If Not rs.EOF Then
    Do Until rs.EOF
        If Not first Then Response.Write ","
        Response.Write "{"
        Response.Write """Id"":" & rs("Id") & ","
        Response.Write """Acao"":""" & rs("Acao") & ""","
        Response.Write """Tabela"":""" & rs("Tabela") & ""","
        Response.Write """RegistroId"":" & rs("RegistroId") & ","
        Response.Write """DataLog"":""" & rs("DataLog") & """"
        Response.Write "}"
        first = False
        rs.MoveNext
    Loop
End If

Response.Write "]"

rs.Close
Set rs = Nothing
%>
