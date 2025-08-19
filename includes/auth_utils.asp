<%
Function GenerateToken(username)
    ' Token simples (pode trocar por algo mais robusto depois)
    GenerateToken = username & "_" & CStr(Timer)
End Function

Function ValidateAuth()
    Dim authHeader
    authHeader = Request.ServerVariables("HTTP_AUTHORIZATION")
    
    If authHeader = "" Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""error"":""Token ausente""}"
        Response.End
    End If
    
    ' Aqui você validaria contra banco ou sessão
    ' Por enquanto, aceita qualquer coisa enviada
    ValidateAuth = True
End Function

Function BinaryToString(Binary)
    Dim Stream
    Set Stream = Server.CreateObject("ADODB.Stream")
    Stream.Type = 1 'adTypeBinary
    Stream.Open
    Stream.Write Binary
    Stream.Position = 0
    Stream.Type = 2 'adTypeText
    Stream.Charset = "utf-8"
    BinaryToString = Stream.ReadText
    Stream.Close
    Set Stream = Nothing
End Function

%>
