# API Fullstack ASP Clássico

Este projeto é uma aplicação web desenvolvida com Classic ASP, utilizando banco de dados SQL Server.
Ele serve como uma API para gerenciamento de produtos, permitindo operações de CRUD (Criar, Ler, Atualizar, Excluir) através de requisições HTTP.

## Funcionalidades

* **Cadastro e Edição de Produtos**: Formulário para adicionar ou editar produtos, incluindo campos como nome, preço, descrição e estoque.
* **Listagem de Produtos**: Exibição de produtos cadastrados em uma tabela, com possibilidade de busca e filtragem.
* **Exclusão de Produtos**: Remoção de produtos através de um botão de exclusão na tabela.
* **Integração com API Externa**: Comunicação via AJAX para persistência e importação de dados externos.

## Tecnologias Utilizadas

* **Frontend**: HTML, CSS, JavaScript (jQuery), Bootstrap 5
* **Backend**: Classic ASP (VBScript)
* **Banco de Dados**: SQL Server
* **API Externa**: Fake Store API para importação de produtos

## Estrutura de Diretórios

```
/api
  /produtos.asp        # Lógica da API para produtos
/includes
  /conexao.asp         # Conexão com o banco de dados
  /validaToken.asp     # Validação de token de autenticação
  /sidebar.asp         # Componente de barra lateral
index.asp              # Página principal da aplicação
login.asp              # Página de login
relatorios.asp         # Página de relatórios
usuarios.asp           # Página de gerenciamento de usuários
```

## Como Utilizar

1. **Clonar o Repositório**

   ```bash
   git clone https://github.com/Felipe-Cavalcante-Silva-DEV/API-Fullstack-ASP-Classico.git
   ```

2. **Configurar o Banco de Dados**

   Crie um banco de dados no SQL Server e execute os scripts SQL necessários para criar as tabelas.

3. **Configurar a Conexão**

   Edite o arquivo `/includes/conexao.asp` para configurar as credenciais de acesso ao banco de dados.

4. **Executar a Aplicação**

   Hospede os arquivos em um servidor que suporte Classic ASP, como o IIS (Internet Information Services) no Windows.

5. **Acessar a Aplicação**

   Abra o navegador e acesse:

   ```
   http://localhost/index.asp
   ```

## Contribuições

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork deste repositório.

2. Crie uma branch para sua funcionalidade:

   ```bash
   git checkout -b minha-feature
   ```

3. Faça commit das suas alterações:

   ```bash
   git commit -am 'Adiciona nova funcionalidade'
   ```

4. Push para a branch:

   ```bash
   git push origin minha-feature
   ```

5. Abra um Pull Request.

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para mais detalhes.
