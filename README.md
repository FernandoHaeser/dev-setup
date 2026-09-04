# Dev Setup Universal

[![platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)](https://github.com/fernandohaeser/dev-setup)
[![last commit](https://img.shields.io/github/last-commit/fernandohaeser/dev-setup)](https://github.com/fernandohaeser/dev-setup/commits/main)
[![repo size](https://img.shields.io/github/repo-size/fernandohaeser/dev-setup)](https://github.com/fernandohaeser/dev-setup)
[![issues](https://img.shields.io/github/issues/fernandohaeser/dev-setup)](https://github.com/fernandohaeser/dev-setup/issues)
[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Shell](https://img.shields.io/badge/Shell-bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

Setup automático de ambiente de desenvolvimento para **Windows, Linux e macOS**.

Com **um único comando**, este projeto instala e configura:

- ✅ Node.js (LTS)
- ✅ Git
- ✅ Visual Studio Code
- ✅ Extensões, temas, ícones e animações do VS Code

👉 O usuário **não precisa baixar nada manualmente**, apenas rodar o comando do seu sistema.

- [Windows](#windows)
- [Linux](#linux-ubuntu--debian)
- [macOS](#macos)

---

## 🧠 Como funciona

1. Você executa **um comando**
2. O script:
   - detecta o sistema operacional
   - instala dependências (Node, Git, VS Code)
   - baixa **apenas os arquivos necessários** (temporariamente)
   - aplica todas as configurações do VS Code
   - apaga os arquivos temporários ao finalizar
3. Pronto. Ambiente configurado.

> Importante: o script **não exige** que você clone/baixe o repositório. Ele só faz download temporário de `vscode/setup.js` e `vscode/settings.json`.

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
```

> A pasta `terminal/` ainda existe no repositório (scripts standalone de configuração de terminal), mas não é mais chamada pelos instaladores — o setup cobre apenas o VS Code.

---

## 🪟 Windows

### ✅ Pré-requisito (evita erro de scripts bloqueados)

Antes de rodar o instalador, libere execução de scripts **para o seu usuário**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
```

> Se sua máquina for gerenciada por empresa (GPO/Intune), esse comando pode ser bloqueado. Nesse caso, use o PowerShell 7 (`pwsh`) e/ou pule a etapa de profile do Windows PowerShell.

### ▶️ Executar instalação

Abra o **PowerShell como administrador** e execute:

```powershell
iwr https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install.ps1 -useb | iex
```

---

## 🐧 Linux (Ubuntu / Debian)

### ▶️ Executar instalação

```bash
curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install.sh | bash
```

---

## 🍎 macOS

### ▶️ Executar instalação

```bash
curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install-macos.sh | bash
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

## 🔁 Posso rodar mais de uma vez?

✅ Sim.

O setup é **idempotente**:
- Não reinstala o que já existe
- Apenas ajusta o que falta

---

## 🧩 Quero personalizar

- VS Code → edite `vscode/settings.json`
- Extensões → edite a lista `__extensions` em `vscode/settings.json`

---

## 🛑 Problemas comuns

### `code: command not found`
Reabra o terminal ou reinicie o sistema.

### Saída verbosa do `apt` / `update-alternatives`
É normal o Ubuntu imprimir várias linhas durante instalações (ex.: `update-alternatives`, `Processing triggers`). Isso não é erro.

### Extensão não instalou
Abra o VS Code uma vez manualmente e rode o script novamente.

---

## ✅ Requisitos mínimos

- Windows 11
- Ubuntu/Debian ou derivado (20.04+)
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
