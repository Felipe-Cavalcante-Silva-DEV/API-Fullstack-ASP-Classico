<%
Function ValidarToken()
    Dim token, rs, sql
    token = Trim(Request.QueryString("token"))

    ' Inicializa como inválido
    ValidarToken = False

    If token = "" Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""success"": false, ""message"": ""Token não fornecido""}"
        Response.End
    End If

    sql = "SELECT dbo.fnValidarToken('" & Replace(token,"'","''") & "') AS Valido"
    Set rs = conDB.Execute(sql)

    If rs.EOF Or rs("Valido") = 0 Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""success"": false, ""message"": ""Token inválido""}"
        rs.Close
        Set rs = Nothing
        Response.End
    End If

    ValidarToken = True ' Retorna verdadeiro se válido

    rs.Close
    Set rs = Nothing
End Function

%>
