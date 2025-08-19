<%
Function ValidarToken()
    Dim token, rs, sql
    token = Trim(Request.QueryString("token"))
    
    ' Inicializa como inválido
    ValidarToken = False
    
    ' Token não fornecido
    If token = "" Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""success"": false, ""message"": ""Token não fornecido""}"
        Response.End
    End If

    ' Consulta a função no banco
    sql = "SELECT dbo.fnValidarToken('" & Replace(token,"'","''") & "') AS Valido"
    Set rs = conDB.Execute(sql)

    ' Token inválido
    If rs.EOF Or rs("Valido") = 0 Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""success"": false, ""message"": ""Token inválido""}"
        rs.Close
        Set rs = Nothing
        Response.End
    End If

    ' Se chegou aqui, token é válido
    ValidarToken = True

    rs.Close
    Set rs = Nothing
End Function
%>
