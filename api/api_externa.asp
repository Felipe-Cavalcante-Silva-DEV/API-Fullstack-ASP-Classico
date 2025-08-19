<%@ LANGUAGE="VBSCRIPT" %>
<!--#include virtual="/includes/conexao.asp" -->
<!--#include virtual="/includes/json.asp" -->

<%
Response.ContentType = "application/json"

' ============================
' Chave única de verificação
' ============================
Const CHAVE_SECRETA = "MINHA_CHAVE_EXTERNA"
Dim chaveCliente
chaveCliente = Trim(Request.QueryString("key"))

If chaveCliente <> CHAVE_SECRETA Then
    Response.Status = "401 Unauthorized"
    Response.Write "{""success"":false,""message"":""Acesso negado""}"
    Response.End
End If

' ============================
' Variáveis globais
' ============================
Dim action, rawJSON, objJSON, produtoId, nome, descricao, preco, estoque
action = Request("action")

' ============================
' Função auxiliar para escapar JSON
' ============================
Function EscapeJSON(str)
    EscapeJSON = Replace(str, """", "\""")
End Function

' ============================
' Funções
' ============================

Function ListarProdutos()
    Dim cmd, rs, json, primeiro
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spListarProdutos"
    Set rs = cmd.Execute

    json = "["
    primeiro = True

    Do Until rs.EOF
        If Not primeiro Then json = json & ","
        primeiro = False

        json = json & "{""ProdutoID"": " & rs("Id") & _
                       ", ""Nome"": """ & EscapeJSON(rs("Nome")) & """" & _
                       ", ""Descricao"": """ & EscapeJSON(rs("Descricao")) & """" & _
                       ", ""Preco"": " & Replace(CStr(rs("Preco")), ",", ".") & _
                       ", ""Estoque"": " & rs("Estoque") & "}"
        rs.MoveNext
    Loop

    json = json & "]"

    rs.Close
    Set rs = Nothing
    Set cmd = Nothing

    ListarProdutos = json
End Function

Function CriarProduto(nome, descricao, preco, estoque)
    Dim cmd, rs, novoId
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spCriarProduto"
    cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 150, nome)
    cmd.Parameters.Append cmd.CreateParameter("@Descricao", 200, 1, 500, descricao)
    cmd.Parameters.Append cmd.CreateParameter("@Preco", 5, 1, , preco)
    cmd.Parameters.Append cmd.CreateParameter("@Estoque", 3, 1, , estoque)

    Set rs = cmd.Execute

    If Not rs.EOF Then
        novoId = rs("NovoProdutoID")
    Else
        novoId = 0
    End If

    rs.Close
    Set rs = Nothing
    Set cmd = Nothing

    CriarProduto = novoId
End Function

' ============================
' Dispatcher das ações
' ============================

Select Case action

    Case "list"
        Response.Write ListarProdutos()

    Case "add"
        rawJSON = ""
        If Request.TotalBytes > 0 Then
            rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
        End If

        If rawJSON = "" Then
            Response.Write "{""success"":false,""message"":""Nenhum JSON enviado""}"
            Response.End
        End If

        On Error Resume Next
        Set objJSON = ParseJSON(rawJSON)
        If Err.Number <> 0 Or objJSON Is Nothing Then
            Response.Write "{""success"":false,""message"":""JSON inválido: " & Err.Description & """}"
            Response.End
        End If
        On Error GoTo 0

        nome = objJSON.nome
        descricao = objJSON.descricao
        preco = CDbl(objJSON.preco)
        estoque = CInt(objJSON.estoque)

        If nome = "" Or preco <= 0 Then
            Response.Write "{""success"":false,""message"":""Campos obrigatórios ausentes ou inválidos""}"
            Response.End
        End If

        produtoId = CriarProduto(nome, descricao, preco, estoque)

        Response.Write "{""success"":true,""message"":""Produto criado com sucesso"",""NovoProdutoID"":" & produtoId & "}"

    Case Else
        Response.Status = "400 Bad Request"
        Response.Write "{""success"":false,""message"":""Ação inválida""}"

End Select

conDB.Close
%>
