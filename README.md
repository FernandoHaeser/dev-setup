# 🚀 Dev Setup Universal

# Teste

Setup automático de ambiente de desenvolvimento para **Windows, Linux e macOS**.

Com **um único comando**, este projeto instala e configura:

- ✅ Node.js (LTS)
- ✅ Git
- ✅ Visual Studio Code
- ✅ Extensões, temas, ícones e animações do VS Code
- ✅ Terminal personalizado (**opcional**)

👉 O usuário **não precisa baixar nada manualmente**, apenas rodar o comando do seu sistema.

---

## 🧠 Como funciona

1. Você executa **um comando**
2. O script:
   - detecta o sistema operacional
   - instala dependências (Node, Git, VS Code)
   - pergunta se você quer configurar o terminal (mesmo rodando via `curl | bash`)
   - se você escolher terminal, ele roda **primeiro**
   - baixa **apenas os arquivos necessários** (temporariamente)
   - aplica todas as configurações do VS Code
   - apaga os arquivos temporários ao finalizar
3. Pronto. Ambiente configurado.

> Importante: o script **não exige** que você clone/baixe o repositório. Ele só faz download temporário de:
>
>- `vscode/setup.js` e `vscode/settings.json`
>- `terminal/<seu-sistema>.*` (somente se você habilitar o terminal)

---

## 📦 Estrutura do projeto

```text
dev-setup/
├─ README.md
├─ install.ps1              # Instalador Windows
├─ install.sh               # Instalador Linux
├─ install-macos.sh         # Instalador macOS
├─ bootstrap/
├─ vscode/
│  ├─ setup.js              # Script Node (instala extensões + settings)
│  └─ settings.json         # Fonte da verdade das configs
├─ terminal/
│  ├─ windows.ps1
│  ├─ linux.sh
│  └─ macos.sh
```

---

## 🪟 Windows

### ▶️ Executar instalação

Abra o **PowerShell como administrador** e execute:

```powershell
iwr https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install.ps1 -useb | iex
```

### ✅ Forçar terminal ligado/desligado (sem prompt)

- Terminal ligado:

```powershell
$env:SETUP_TERMINAL = "true"; iwr https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/bootstrap/bootstrap.ps1 -useb | iex
```

- Terminal desligado:

```powershell
$env:SETUP_TERMINAL = "false"; iwr https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/bootstrap/bootstrap.ps1 -useb | iex
```

### 💬 Durante o processo

Você verá a pergunta:

```
Deseja instalar/configurar o TERMINAL? (s/n)
```

- `s` → instala e personaliza o terminal
- `n` → pula essa etapa

---

## 🐧 Linux (Ubuntu / Debian)

### ▶️ Executar instalação

```bash
curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install.sh | bash
```

### ✅ Forçar terminal ligado/desligado (sem prompt)

- Terminal ligado:

```bash
DEV_SETUP_TERMINAL=s curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install.sh | bash
```

- Terminal desligado:

```bash
DEV_SETUP_TERMINAL=n curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install.sh | bash
```

### 💬 Durante o processo

```
Deseja instalar/configurar o TERMINAL? (s/n):
```

- `s` → instala e personaliza o terminal
- `n` → segue só com VS Code

---

## 🍎 macOS

### ▶️ Executar instalação

```bash
curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install-macos.sh | bash
```

### ✅ Forçar terminal ligado/desligado (sem prompt)

- Terminal ligado:

```bash
DEV_SETUP_TERMINAL=s curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install-macos.sh | bash
```

- Terminal desligado:

```bash
DEV_SETUP_TERMINAL=n curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install-macos.sh | bash
```

> O Homebrew será instalado automaticamente se não existir.

---

## 🎨 O que é configurado no VS Code

- Tema escuro moderno
- Ícones customizados
- Animações de cursor
- Prettier como formatter padrão
- GitLens
- Auto Save
- Sidebar e Activity Bar reposicionados
- Suporte a símbolos e ícones especiais

Tudo isso vem de:

```text
vscode/settings.json
```

Esse arquivo é a **fonte da verdade**.

---

## 🖥️ Terminal (opcional)

Se ativado, o script instala e configura:

- Prompt estilizado
- Ícones Nerd Font
- Tema moderno
- Integração com Git

Cada sistema usa seu próprio script:

- Windows → `terminal/windows.ps1`
- Linux → `terminal/linux.sh`
- macOS → `terminal/macos.sh`

---

## 🔁 Posso rodar mais de uma vez?

✅ Sim.

O setup é **idempotente**:
- Não reinstala o que já existe
- Apenas ajusta o que falta

---

## 🧩 Quero personalizar

- VS Code → edite `vscode/settings.json`
- Extensões → edite `vscode/setup.js`
- Terminal → edite os scripts da pasta `terminal/`
- Perfis → crie um JSON em `profiles/`

---

## 🛑 Problemas comuns

### `code: command not found`
Reabra o terminal ou reinicie o sistema.

### Extensão não instalou
Abra o VS Code uma vez manualmente e rode o script novamente.

---

## ✅ Requisitos mínimos

- Windows 10+
- Ubuntu/Debian ou derivado
- macOS 12+
- Conexão com internet

Nada mais.

---

## 🧠 Filosofia

> Clone nada. Configure nada. Pense em nada.  
> Só roda o comando e começa a codar.

---

## ⭐ Dica final

Depois de finalizar, **reinicie o terminal** para carregar todas as configurações corretamente.

Bom código 🚀
