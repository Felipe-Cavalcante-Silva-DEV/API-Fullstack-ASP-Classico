<%@ Language="VBScript" %>
<!--#include virtual="/includes/conexao.inc" -->
<!--#include virtual="/includes/json.inc" -->
<!--#include virtual="/includes/geraToken.inc" -->
<!--#include virtual="/includes/validaToken.inc" -->

<%
Response.ContentType = "application/json"
Dim action, rawJSON, objJSON, produtoId, nome, descricao, preco, estoque

action = Request("action")

' =========================
' Funções CRUD de produto
' =========================

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
                       ", ""Nome"": """ & rs("Nome") & """" & _
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

Function AtualizarProduto(produtoId, nome, descricao, preco, estoque)
    Dim cmd, linhasAfetadas
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spAtualizarProduto"
    cmd.Parameters.Append cmd.CreateParameter("@Id", 3, 1, , produtoId)
    cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 150, nome)
    cmd.Parameters.Append cmd.CreateParameter("@Descricao", 200, 1, 500, descricao)
    cmd.Parameters.Append cmd.CreateParameter("@Preco", 5, 1, , preco)
    cmd.Parameters.Append cmd.CreateParameter("@Estoque", 3, 1, , estoque)
    
    cmd.Execute linhasAfetadas
    Set cmd = Nothing

    AtualizarProduto = linhasAfetadas
End Function

Function ExcluirProduto(produtoId)
    Dim cmd, linhasAfetadas
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spExcluirProduto"
    cmd.Parameters.Append cmd.CreateParameter("@Id", 3, 1, , produtoId)
    
    cmd.Execute linhasAfetadas
    Set cmd = Nothing

    ExcluirProduto = linhasAfetadas
End Function



' =========================
' Dispatcher das ações
' =========================
Select Case action

    Case "list"
        Response.Write ListarProdutos()

    Case "add", "update", "delete"
        rawJSON = ""
        If Request.TotalBytes > 0 Then
            rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
        End If

        If rawJSON = "" Then
            Response.Status = "400 Bad Request"
            Response.Write "{""success"":false,""message"":""JSON vazio""}"
            Response.End
        End If

        Set objJSON = ParseJSON(rawJSON)
        If objJSON Is Nothing Then
            Response.Status = "400 Bad Request"
            Response.Write "{""success"":false,""message"":""JSON inválido""}"
            Response.End
        End If

        If action = "add" Then
            nome = objJSON.nome
            descricao = objJSON.descricao
            preco = CDbl(objJSON.preco)
            estoque = CInt(objJSON.estoque)

            produtoId = CriarProduto(nome, descricao, preco, estoque)
            Response.Write "{""success"":true,""NovoProdutoID"":" & produtoId & "}"

        ElseIf action = "update" Then
            produtoId = CLng(objJSON.produtoId)
            nome = objJSON.nome
            descricao = objJSON.descricao
            preco = CDbl(objJSON.preco)
            estoque = CInt(objJSON.estoque)

            Dim linhasAtualizadas
            linhasAtualizadas = AtualizarProduto(produtoId, nome, descricao, preco, estoque)

            If linhasAtualizadas = 0 Then
                Response.Status = "404 Not Found"
                Response.Write "{""success"":false,""message"":""Produto não encontrado""}"
            Else
                Response.Write "{""success"":true,""message"":""Produto atualizado""}"
            End If

        ElseIf action = "delete" Then
            produtoId = CLng(objJSON.produtoId)
            Dim resultado
            resultado = ExcluirProduto(produtoId)

            If resultado = 0 Then
                Response.Status = "404 Not Found"
                Response.Write "{""success"":false,""message"":""Produto não encontrado""}"
            Else
                Response.Write "{""success"":true,""message"":""Produto excluído""}"
            End If
        End If

    Case Else
        Response.Status = "400 Bad Request"
        Response.Write "{""success"":false,""message"":""Ação inválida""}"

End Select

conDB.Close
%>
