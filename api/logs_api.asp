<%@ LANGUAGE="VBSCRIPT" %>
<!--#include virtual="/includes/conexao.inc" -->
<!--#include virtual="/includes/validaToken.inc" -->

<%
Response.ContentType = "application/json"
Response.Charset = "UTF-8"

Dim action
action = Request("action")

' ========================
' Função para listar logs
' ========================
Function ListarLogs()
    Dim rs, sql, json, first
    Set rs = Server.CreateObject("ADODB.Recordset")

    sql = "SELECT Id, Acao, Tabela, RegistroId, DataLog FROM Logs ORDER BY DataLog DESC"
    rs.Open sql, conDB, 3, 3

    json = "["
    first = True

    If Not rs.EOF Then
        Do Until rs.EOF
            If Not first Then json = json & ","
            json = json & "{"
            json = json & """Id"":" & rs("Id") & ","
            json = json & """Acao"":""" & rs("Acao") & ""","
            json = json & """Tabela"":""" & rs("Tabela") & ""","
            json = json & """RegistroId"":" & rs("RegistroId") & ","
            json = json & """DataLog"":""" & rs("DataLog") & """"
            json = json & "}"
            first = False
            rs.MoveNext
        Loop
    End If

    json = json & "]"

    rs.Close
    Set rs = Nothing

    ListarLogs = json
End Function

' ========================
' Dispatcher das ações
' ========================
Select Case action
    Case "list"
        Response.Write ListarLogs()

    Case Else
        Response.Status = "400 Bad Request"
        Response.Write "{""success"":false,""message"":""Ação inválida""}"
End Select

conDB.Close
%>
