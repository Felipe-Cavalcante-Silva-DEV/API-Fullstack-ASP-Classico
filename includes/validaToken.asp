<%
' =========================
' validaToken.asp
' =========================

Dim token, rs, sql, authHeader

token = Request.QueryString("token")


If token = "" Then
    Response.Status = "401 Unauthorized"
    Response.Write "{""success"": false, ""message"": ""Token não fornecido""}"
    Response.End
End If

' Verifica token no banco usando a função fnValidarToken
sql = "SELECT dbo.fnValidarToken('" & Replace(token,"'","''") & "') AS isValid"
Set rs = conDB.Execute(sql)

If rs.EOF Or rs("isValid") = 0 Then
    Response.Status = "401 Unauthorized"
    Response.Write "{""success"": false, ""message"": ""Token inválido""}"
    rs.Close
    Set rs = Nothing
    Response.End
End If


rs.Close
Set rs = Nothing
' =========================
' Se chegou aqui, token é válido
%>
