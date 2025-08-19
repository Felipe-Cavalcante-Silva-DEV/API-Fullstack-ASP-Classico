<%@ LANGUAGE="VBSCRIPT" %>
<!--#include virtual="/includes/conexao.asp" -->
<!--#include virtual="/includes/json.asp" -->

<%
Response.ContentType = "application/json"

' ============================
' Chave única de verificação da API
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
' Função auxiliar para escapar JSON
' ============================
Function EscapeJSON(str)
    EscapeJSON = Replace(str, """", "\""")
End Function

' ============================
' Detecta método HTTP
' ============================
Dim metodo
metodo = Request.ServerVariables("REQUEST_METHOD")

If metodo = "GET" Then
    ' ============================
    ' Listar produtos
    ' ============================
    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spListarProdutos"
    Set rs = cmd.Execute

    Response.Write "["
    Do Until rs.EOF
        Response.Write "{""ProdutoID"": " & rs("Id") & _
                       ", ""Nome"": """ & EscapeJSON(rs("Nome")) & """" & _
                       ", ""Descricao"": """ & EscapeJSON(rs("Descricao")) & """" & _
                       ", ""Preco"": " & Replace(rs("Preco"), ",", ".") & _
                       ", ""Estoque"": " & rs("Estoque") & "}"
        rs.MoveNext
        If Not rs.EOF Then Response.Write ","
    Loop
    Response.Write "]"

    rs.Close
    Set rs = Nothing
    Set cmd = Nothing

ElseIf metodo = "POST" Then
    ' ============================
    ' Adicionar produto
    ' ============================
    Dim rawJSON
    rawJSON = ""
    If Request.TotalBytes > 0 Then
        rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
    End If

    If rawJSON = "" Then
        Response.Write "{""success"":false,""message"":""Nenhum JSON enviado""}"
        Response.End
    End If

    Dim objJSON
    Set objJSON = Nothing
    On Error Resume Next
    Set objJSON = ParseJSON(rawJSON)
    If Err.Number <> 0 Or objJSON Is Nothing Then
        Response.Write "{""success"":false,""message"":""JSON inválido: " & Err.Description & """}"
        Response.End
    End If
    On Error GoTo 0

    ' Extrair campos
    Dim nome, descricao, preco, estoque
    On Error Resume Next
    nome = objJSON.nome
    descricao = objJSON.descricao
    preco = CDbl(objJSON.preco)
    estoque = CInt(objJSON.estoque)
    If Err.Number <> 0 Then
        Response.Write "{""success"":false,""message"":""Erro ao extrair campos do JSON: " & Err.Description & """}"
        Response.End
    End If
    On Error GoTo 0

    ' Validação básica
    If nome = "" Or preco <= 0 Then
        Response.Write "{""success"":false,""message"":""Campos obrigatórios ausentes ou inválidos""}"
        Response.End
    End If

    ' Inserir produto via procedure
    Dim cmdAdd, rsAdd, novoId
    Set cmdAdd = Server.CreateObject("ADODB.Command")
    cmdAdd.ActiveConnection = conDB
    cmdAdd.CommandType = 4
    cmdAdd.CommandText = "spCriarProduto"
    cmdAdd.Parameters.Append cmdAdd.CreateParameter("@Nome", 200, 1, 150, nome)
    cmdAdd.Parameters.Append cmdAdd.CreateParameter("@Descricao", 200, 1, 500, descricao)
    cmdAdd.Parameters.Append cmdAdd.CreateParameter("@Preco", 5, 1, , preco)
    cmdAdd.Parameters.Append cmdAdd.CreateParameter("@Estoque", 3, 1, , estoque)

    Set rsAdd = cmdAdd.Execute

    novoId = 0
    If Not rsAdd.EOF Then novoId = rsAdd("NovoProdutoID")

    Response.Write "{""success"":true,""message"":""Produto criado com sucesso"",""NovoProdutoID"":" & novoId & "}"

    Set rsAdd = Nothing
    Set cmdAdd = Nothing

Else
    Response.Status = "405 Method Not Allowed"
    Response.Write "{""success"":false,""message"":""Método HTTP não permitido""}"
End If
%>
