<%@ Language="VBScript" %>
<!--#include virtual="/includes/conexao.asp" -->
<!--#include virtual="/includes/geraToken.asp" -->
<!--#include virtual="/includes/json.asp" -->

<%
Dim action, nome, email, senhahash, rs, cmd, sql, token, rawJSON, objJSON
action = Request("action")
token  = Request("token") ' pode vir via querystring ou header

 Function JsonEscape(str)
            str = Replace(str, "\", "\\")
            str = Replace(str, """", "\""")
            str = Replace(str, vbCrLf, "")
            str = Replace(str, vbCr, "")
            str = Replace(str, vbLf, "")
            JsonEscape = str
        End Function

' ============================
' REGISTRAR USUÁRIO
' ============================
If action = "register" Then

    
    rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
    Set objJSON = ParseJSON(rawJSON)

    ' Extrair campos do JSON com tratamento de erro
    If IsObject(objJSON) Then
        On Error Resume Next
        nome = objJSON.nome
        If Err.Number <> 0 Then nome = ""
        Err.Clear

        email = objJSON.email
        If Err.Number <> 0 Then email = ""
        Err.Clear

        senhahash = objJSON.senhahash
        If Err.Number <> 0 Then senhahash = ""
        Err.Clear
        On Error GoTo 0
    Else
        Response.Status = "400 Bad Request"
        Response.Write "{""success"":false,""message"":""JSON inválido ou vazio.""}"
        Response.End
    End If

    ' Validação
    If nome = "" Or email = "" Or senhahash = "" Then
        Response.Write "{""success"":false,""message"":""Todos os campos são obrigatórios.""}"
        Response.End
    End If

    ' Inserir usuário via procedure
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4 ' adCmdStoredProc
    cmd.CommandText = "spRegistrarUsuario"
    cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 100, nome)
    cmd.Parameters.Append cmd.CreateParameter("@Email", 200, 1, 150, email)
    cmd.Parameters.Append cmd.CreateParameter("@SenhaHash", 200, 1, 200, senhahash)
    cmd.Execute
    Set cmd = Nothing

    ' Gerar token simples
    token = GerarToken()

    ' Atualizar token no banco
    sql = "UPDATE Usuarios SET Token='" & Replace(token,"'","''") & "' WHERE Email='" & Replace(email,"'","''") & "'"
    conDB.Execute sql

    ' Retornar JSON
    Response.ContentType = "application/json"
    Response.Write "{""success"":true,""message"":""Registro realizado!"",""token"":""" & token & """}"




' ============================
' LOGIN
' ============================
ElseIf action = "login" Then
    rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
    Set objJSON = ParseJSON(rawJSON)

    ' Extrair campos do JSON com tratamento de erro
    If IsObject(objJSON) Then
        On Error Resume Next
        nome = objJSON.nome
        If Err.Number <> 0 Then nome = ""
        Err.Clear

        senhahash = objJSON.senhahash
        If Err.Number <> 0 Then senhahash = ""
        Err.Clear
        On Error GoTo 0

    Else
        Response.Status = "400 Bad Request"
        Response.Write "{""success"":false,""message"":""JSON inválido ou vazio.""}"
        Response.End
    End If

    ' Verifica se os campos foram enviados
    If nome = "" Or senhahash = "" Then
        Response.Status = "400 Bad Request"
        Response.Write "{""success"":false,""message"":""Nome e senha obrigatórios.""}"
        Response.End
    End If

    ' Consulta no banco usando a procedure
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4 ' Stored Procedure
    cmd.CommandText = "spLoginUsuario"

    cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 100, nome)
    cmd.Parameters.Append cmd.CreateParameter("@SenhaHash", 200, 1, 200, senhahash)

    Set rs = cmd.Execute

    If Not rs.EOF Then
        ' Usuário válido → gerar token simples
        token = rs("Token") ' ou use GerarToken(nome, rs("Email")) se quiser criar um novo token   

        Response.ContentType = "application/json"
        Response.Write "{""success"":true,""token"":""" & JsonEscape(token) & """,""tipoUsuario"":""" & JsonEscape(rs("TipoUsuario")) & """}"
        Response.End

    Else
        Response.Status = "401 Unauthorized"
        Response.Write "{""success"":false,""message"":""Credenciais inválidas.""}"
        Response.End
    End If

    rs.Close
    Set rs = Nothing
    Set cmd = Nothing


' ============================
' LISTAR USUÁRIOS
' ============================
ElseIf action = "list" Then
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4 ' adCmdStoredProc
    cmd.CommandText = "spListarUsuarios"
    
    Set rs = cmd.Execute

    Response.Write "["
    Dim primeiro
    primeiro = True

    Do Until rs.EOF
        If Not primeiro Then Response.Write ","
        primeiro = False

        Response.Write "{""UserID"": " & rs("Id") & _
                       ", ""Nome"": """ & Replace(rs("Nome"), """", "\""") & """" & _
                       ", ""Email"": """ & Replace(rs("Email"), """", "\""") & """" & _
                       ", ""TipoUsuario"": """ & rs("TipoUsuario") & """" & _
                       ", ""DataCriacao"": """ & FormatDateTime(rs("DataCriacao"), 2) & """}"
        rs.MoveNext
    Loop

    Response.Write "]"

    rs.Close
    Set rs = Nothing
    Set cmd = Nothing

' ============================
' AÇÃO INVÁLIDA
' ============================
Else

    Response.Status = "400 Bad Request"
    Response.Write "{""error"": ""Ação inválida""}"
End If

conDB.Close
%>
