# 📱 Agenda & Notas — Projeto Flutter

Aplicativo mobile completo com gerenciamento de contatos e bloco de notas, com banco de dados local (SQLite).

---

## ✨ Funcionalidades

### 👤 Contatos
- ✅ Listar contatos (ordem alfabética, favoritos primeiro)
- ✅ Busca por nome ou telefone
- ✅ Criar novo contato (nome, telefone, e-mail)
- ✅ **Editar contato existente (UPDATE)**
- ✅ Marcar/desmarcar como favorito ⭐
- ✅ Excluir contato com confirmação
- ✅ Avatar com iniciais colorido

### 📝 Bloco de Notas
- ✅ Listar notas em grade (estilo post-it colorido)
- ✅ Busca por título ou conteúdo
- ✅ Criar nova nota com título e conteúdo livre
- ✅ Editar nota existente
- ✅ **Anexar imagem** (câmera ou galeria)
- ✅ Excluir nota
- ✅ Aviso de alterações não salvas

---

## 🚀 Como Rodar

### Pré-requisitos
- Flutter SDK 3.x instalado: https://flutter.dev/docs/get-started/install
- Android Studio ou VS Code com extensão Flutter
- Dispositivo Android (físico ou emulador)

### Passos

```bash
# 1. Entre na pasta do projeto
cd agenda_app

# 2. Instale as dependências
flutter pub get

# 3. Verifique se o dispositivo está conectado
flutter devices

# 4. Execute o app
flutter run
```

### Build APK para distribuição

```bash
flutter build apk --release
# O APK fica em: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                   # Ponto de entrada + tema global
├── database/
│   └── database_helper.dart    # SQLite — CRUD contatos e notas
├── models/
│   ├── contato.dart            # Model Contato
│   └── nota.dart               # Model Nota
└── screens/
    ├── home_screen.dart         # Navegação inferior (tabs)
    ├── contatos_screen.dart     # Lista de contatos
    ├── contato_form_screen.dart # Criar / EDITAR contato
    ├── notas_screen.dart        # Grade de notas
    └── nota_form_screen.dart    # Criar / editar nota + imagem
```

---

## 🗄️ Banco de Dados (SQLite)

### Tabela `contatos`
| Campo      | Tipo    | Descrição               |
|------------|---------|-------------------------|
| id         | INTEGER | PK autoincrement        |
| nome       | TEXT    | Nome completo           |
| telefone   | TEXT    | Número de telefone      |
| email      | TEXT    | E-mail (opcional)       |
| favorito   | INTEGER | 0 = normal, 1 = favorito|
| criado_em  | TEXT    | Data ISO 8601           |

### Tabela `notas`
| Campo        | Tipo | Descrição              |
|--------------|------|------------------------|
| id           | INTEGER | PK autoincrement   |
| titulo       | TEXT | Título da nota         |
| conteudo     | TEXT | Conteúdo livre         |
| imagem_path  | TEXT | Caminho da imagem local|
| criado_em    | TEXT | Data de criação        |
| atualizado_em| TEXT | Última modificação     |

---

## 📦 Dependências Principais

| Pacote          | Versão  | Uso                            |
|-----------------|---------|--------------------------------|
| sqflite         | ^2.3.0  | Banco de dados SQLite local    |
| path            | ^1.8.3  | Manipulação de caminhos        |
| path_provider   | ^2.1.2  | Diretórios do sistema          |
| image_picker    | ^1.0.7  | Câmera e galeria de imagens    |
| intl            | ^0.19.0 | Formatação de datas            |
| google_fonts    | ^6.1.0  | Tipografia Poppins             |

---

## 🎨 Paleta de Cores

| Elemento      | Cor           |
|---------------|---------------|
| Primária      | `#6C63FF` (roxo) |
| Secundária    | `#FF6584` (rosa) |
| Background    | `#F8F7FF`     |
| Favorito      | `#FFB347` (âmbar)|
| Texto escuro  | `#2D2B55`     |

---

## 🔧 Permissões Android

Adicionadas no `AndroidManifest.xml`:
- `CAMERA` — para tirar fotos nas notas
- `READ_MEDIA_IMAGES` — Android 13+ (galeria)
- `READ_EXTERNAL_STORAGE` — Android ≤ 12

> Em Android 13+, o sistema solicita as permissões automaticamente ao acessar câmera/galeria.
