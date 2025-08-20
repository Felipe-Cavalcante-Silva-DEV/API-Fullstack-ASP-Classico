<%@ Language="VBScript" %>
<!--#include virtual="/includes/conexao.inc" -->
<!--#include virtual="/includes/json.inc" -->
<!--#include virtual="/includes/geraToken.inc" -->
<!--#include virtual="/includes/validaTokenApi.inc" -->

<%
Dim action
action = Request("action")


' =========================
' Função: registrar usuário
' =========================
Function RegistrarUsuario(nome, email, senhaHash)
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4 ' Stored Procedure
    cmd.CommandText = "spRegistrarUsuario"
    cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 100, nome)
    cmd.Parameters.Append cmd.CreateParameter("@Email", 200, 1, 150, email)
    cmd.Parameters.Append cmd.CreateParameter("@SenhaHash", 200, 1, 200, senhaHash)
    cmd.Execute
    Set cmd = Nothing
End Function

' =========================
' Função: login usuário
' =========================
Function LoginUsuario(nome, senhaHash)
    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spLoginUsuario"
    cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 100, nome)
    cmd.Parameters.Append cmd.CreateParameter("@SenhaHash", 200, 1, 200, senhaHash)

    Set rs = cmd.Execute

    If Not rs.EOF Then
        LoginUsuario = rs("Token")
    Else
        LoginUsuario = ""
    End If

    rs.Close
    Set rs = Nothing
    Set cmd = Nothing
End Function

' =========================
' Função: listar usuários
' =========================
Function ListarUsuarios()
    Dim cmd, rs, json, primeiro
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spListarUsuarios"
    Set rs = cmd.Execute

    json = "["
    primeiro = True

    Do Until rs.EOF
        If Not primeiro Then json = json & ","
        primeiro = False
        json = json & "{""UserID"": " & rs("Id") & _
                       ", ""Nome"": """ & Replace(rs("Nome"), """", "\""") & """" & _
                       ", ""Email"": """ & Replace(rs("Email"), """", "\""") & """" & _
                       ", ""TipoUsuario"": """ & rs("TipoUsuario") & """" & _
                       ", ""DataCriacao"": """ & FormatDateTime(rs("DataCriacao"), 2) & """}"
        rs.MoveNext
    Loop

    json = json & "]"

    rs.Close
    Set rs = Nothing
    Set cmd = Nothing

    ListarUsuarios = json
End Function

' =========================
' Dispatcher das ações
' =========================
Dim rawJSON, objJSON, nome, email, senhaHash, token

Select Case action
    Case "register", "login"
        ' Só ler JSON se for POST
        If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
            Response.Status = "400 Bad Request"
            Response.Write "{""success"":false,""message"":""Método inválido""}"
            Response.End
        End If

        rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
        If rawJSON = "" Then
            Response.Status = "400 Bad Request"
            Response.Write "{""success"":false,""message"":""JSON vazio""}"
            Response.End
        End If

        Set objJSON = ParseJSON(rawJSON)

        If action = "register" Then
            nome = objJSON.nome
            email = objJSON.email
            senhaHash = objJSON.senhahash

            If nome = "" Or email = "" Or senhaHash = "" Then
                Response.Status = "400 Bad Request"
                Response.Write "{""success"":false,""message"":""Todos os campos obrigatórios""}"
                Response.End
            End If

            ' Registrar usuário
            Call RegistrarUsuario(nome,email,senhaHash)

            ' Gerar token e atualizar banco
            token = GerarToken()
            conDB.Execute "UPDATE Usuarios SET Token='" & Replace(token,"'","''") & "' WHERE Email='" & Replace(email,"'","''") & "'"

            Response.ContentType = "application/json"
            Response.Write "{""success"":true,""token"":""" & token & """}"

        ElseIf action = "login" Then
            nome = objJSON.nome
            senhaHash = objJSON.senhahash

            token = LoginUsuario(nome,senhaHash)

            If token = "" Then
                Response.Status = "401 Unauthorized"
                Response.Write "{""success"":false,""message"":""Credenciais inválidas""}"
                Response.End
            End If

            Response.ContentType = "application/json"
            Response.Write "{""success"":true,""token"":""" & token & """}"

        End If

    Case "list"
         If not ValidarToken() then
            Response.Status = "401 Unauthorized"
            Response.Write "{""success"":false,""message"":""token inválidas""}"
            Response.End
        End if

        Response.ContentType = "application/json"
        Response.Write ListarUsuarios()

    Case Else
        Response.Status = "400 Bad Request"
        Response.Write "{""success"":false,""message"":""Ação inválida""}"
End Select

conDB.Close
%>
