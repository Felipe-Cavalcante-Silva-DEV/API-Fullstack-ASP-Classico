API Fullstack ASP Clássico

Este projeto é uma aplicação web desenvolvida com Classic ASP, utilizando banco de dados SQL Server. Ele serve como uma API para gerenciamento de produtos, permitindo operações de CRUD (Criar, Ler, Atualizar, Excluir) através de requisições HTTP.
GitHub
+2
GitHub
+2

Funcionalidades

Cadastro e Edição de Produtos: Formulário para adicionar ou editar produtos, incluindo campos como nome, preço, descrição e estoque.

Listagem de Produtos: Exibição de produtos cadastrados em uma tabela, com possibilidade de busca e filtragem.

Exclusão de Produtos: Remoção de produtos através de um botão de exclusão na tabela.

Integração com API: Comunicação com uma API externa para persistência de dados.

Tecnologias Utilizadas

Frontend: HTML, CSS, JavaScript (jQuery), Bootstrap 5

Backend: Classic ASP (VBScript)

Banco de Dados: SQL Server

API Externa: Comunicação via requisições HTTP (AJAX)
GitHub
+3
TheOneTechnologies
+3
scholarhat.com
+3
GitHub
+1
Medium
+3
GitHub
+3
GitHub
+3

Estrutura de Diretórios

O projeto está organizado da seguinte forma:

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

Como Utilizar

Clonar o Repositório

Clone este repositório para o seu ambiente local:

git clone https://github.com/Felipe-Cavalcante-Silva-DEV/API-Fullstack-ASP-Classico.git


Configurar o Banco de Dados

Crie um banco de dados no SQL Server e execute os scripts SQL presentes na pasta /SQL para criar as tabelas necessárias.

Configurar a Conexão

Edite o arquivo /includes/conexao.asp para configurar as credenciais de acesso ao banco de dados.

Executar a Aplicação

Hospede os arquivos em um servidor que suporte Classic ASP, como o IIS (Internet Information Services) no Windows.

Acessar a Aplicação

Abra o navegador e acesse http://localhost/index.asp para utilizar a aplicação.

Contribuições

Contribuições são bem-vindas! Para contribuir:

Faça um fork deste repositório.

Crie uma branch para sua funcionalidade (git checkout -b minha-feature).

Faça commit das suas alterações (git commit -am 'Adiciona nova funcionalidade').

Push para a branch (git push origin minha-feature).

Abra um Pull Request.
