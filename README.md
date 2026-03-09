# 📦 Sistema de Pedidos e Gestão de Produtos

Aplicativo desenvolvido em **Flutter** para gerenciamento de **clientes, produtos e pedidos**, com controle de estoque e upload de imagens.

O sistema é **multiplataforma** e funciona em:

* 📱 Mobile (Android)
* 🌐 Web
* 💻 Desktop (Windows)

Utiliza **Riverpod para gerenciamento de estado** e diferentes bancos de dados dependendo da plataforma.

---

# 🚀 Tecnologias Utilizadas

Principais tecnologias do projeto:

* **Flutter**
* **Dart**
* **Riverpod**
* **SQLite (sqflite)**
* **Hive**
* **Image Picker**
* **Intl**
* **UUID**

---

# 🗄 Banco de Dados por Plataforma

O aplicativo utiliza **bancos diferentes dependendo da plataforma**.

| Plataforma | Banco utilizado             |
| ---------- | --------------------------- |
| Android    | SQLite (sqflite)            |
| Windows    | SQLite (sqflite_common_ffi) |
| Web        | Hive                        |

### 📱 Mobile / Desktop

Utiliza **SQLite** através de:

```
sqflite
sqflite_common_ffi
```

Vantagens:

* banco relacional
* persistência local
* consultas SQL
* bom desempenho

---

### 🌐 Web

Utiliza **Hive**.

Hive é um banco:

* NoSQL
* muito rápido
* compatível com navegador
* funciona com IndexedDB

---
# 🌐 Integração Externa (API) 
O sistema se conecta à API pública ViaCEP para automatizar o cadastro de endereços.

* Endpoint Base: https://viacep.com.br/ws/
* Implementação: Localizada em services/api_service.dart.

* Fluxo:
1. Usuário digita o CEP no formulário de cliente.
2. Sistema valida o formato do CEP.
3. Requisição GET é enviada para a API.
4. Dados recebidos (Logradouro, Bairro, Cidade) preenchem automaticamente os campos do formulário.
5. Tratamento de erros exibe mensagens amigáveis (Snackbars) em caso de falha ou CEP inexistente.
---

# 🧩 Funcionalidades do Sistema

## 👤 Gestão de Clientes

Permite cadastrar e gerenciar clientes.

### Funcionalidades

* Criar cliente
* Editar cliente
* Excluir cliente
* Listar clientes

### Dados do cliente

* ID
* Razão Social
* CNPJ
* E-mail
* Endereço
* CEP
* Logradouro

---

# 📦 Gestão de Produtos

Permite cadastrar produtos que poderão ser vendidos em pedidos.

### Funcionalidades

* Criar produto
* Editar produto
* Excluir produto
* Listar produtos
* Upload de imagens

### Dados do produto

* ID
* Descrição
* Valor de venda
* Quantidade em estoque
* Imagens

---

# 🖼 Sistema de Imagens

Os produtos podem possuir **uma ou mais imagens**.

Ele detecta automaticamente:

| Tipo           | Widget usado  |
| -------------- | ------------- |
| Web            | Image.network |
| Mobile/Desktop | Image.file    |
| URL            | Image.network |

Caso a imagem não exista:

```
Icon(Icons.broken_image)
```

---

# 🛒 Criação de Pedidos

O sistema permite criar pedidos vinculados a clientes.

### Fluxo de criação

1. Selecionar cliente
2. Escolher produtos
3. Definir quantidade
4. Adicionar ao carrinho
5. Finalizar pedido

---

# 🧾 Carrinho de Compras

Durante a criação do pedido, os produtos são adicionados a um **carrinho temporário**.

### Cálculo

```
subtotal = quantidade × valor do produto
```

```
total do pedido = soma dos subtotais
```

Os valores são formatados com:

```
intl
```

# 📉 Controle de Estoque

Ao finalizar um pedido, o sistema automaticamente:

1. registra o pedido
2. diminui o estoque dos produtos vendidos
3. atualiza a lista de produtos

---
# ✅ Validações e UX

Para garantir a qualidade da aplicação foram implementados:

* Validação de formulários
Campos obrigatórios e validação de formato (ex: e-mail)

* Feedback visual (Loading)
Uso de CircularProgressIndicator durante buscas e operações

* Tratamento de erros
Captura de exceções com try/catch e exibição de SnackBar

* Confirmação de ações
Diálogos antes de excluir produtos ou pedidos

---

# 🧠 Gerenciamento de Estado

O aplicativo utiliza **Riverpod**.

Providers principais:

* `clientProvider`
* `productProvider`
* `orderProvider`

Eles são responsáveis por:

* carregar dados
* atualizar a interface
* interagir com os repositórios

---

# 🧪 Testes

O projeto possui suporte a:

* **testes unitários**
* **testes de integração**

```
flutter_test
mockito
integration_test
```


# 📂 Estrutura do Projeto

```
lib/
core
 ├ database_helper.dart

models
 ├ client.dart
 ├ product.dart
 └ order.dart

providers
 ├ client_provider.dart
 ├ client_repository_provider.dart
 ├ order_provider.dart
 ├ order_repository_provider.dart
 ├ product_provider.dart
 └ producto_repository_provider.dart
  
repositories
 ├ client
   ├ client_repository.dart
   ├ hive_client_repository.dart
   └ sqlite_client_repository.dart
 ├ order
   ├ hive_order_repository.dart
   ├ order_repository.dart
   └ sqlite_order_repository.dart
 └  product
   ├ hive_product_repository.dart
   ├ product_repository.dart 
   └ sqlite_product_repository.dart

services
  ├ api_service.dart

ui
 ├ pages
   ├ clients
     ├ client_form_page.dart
     └ client_list_page.dart
   ├ orders 
     ├ new_order_page.dart
     └ order_list_page.dart
   └ products
     ├ product_from_page.dart
     └ product_list_page.dart
 ├ widgets
     └ image_display_widget.dart
 ├ HomeScreen.dart
 └ main.dart
```
---
# 🛠️ Como Executar

1. Clone o repositório
2. Entre na pasta do projeto
3. Instale as dependências: flutter pub get
4. Execute o projeto
* Mobile:   flutter run

* Web:   flutter run -d chrome

* Desktop (Windows):   flutter run -d windows
---

# Projeto desenvolvido para estudo de:

* Flutter multiplataforma
* Riverpod
* Arquitetura em camadas
* Persistência local
