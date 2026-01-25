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
- ✅ Terminal personalizado (**opcional**)

👉 O usuário **não precisa baixar nada manualmente**, apenas rodar o comando do seu sistema.

- [Windows](#windows)
- [Linux](#linux-ubuntu--debian)
- [macOS](#macos)
- [Depois que finalizar (Terminal)](#depois-que-finalizar-terminal)

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
- Tema moderno
- Integração com Git

Cada sistema usa seu próprio script:

- Windows → `terminal/windows.ps1`
- Linux → `terminal/linux.sh`
- macOS → `terminal/macos.sh`

---

## ✅ Depois que finalizar (Terminal)

Algumas configurações (fonte, shell padrão, `PATH`, perfil do PowerShell) só aparecem **ao abrir uma nova sessão**.

### 🪟 Windows (Windows Terminal / PowerShell)

1. Feche e reabra o **Windows Terminal**.
2. Abra uma aba de **PowerShell** (de preferência `pwsh`).
3. Se o tema/prompt não aparecer:
   - Confirme que o perfil foi escrito em `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`.
   - Rode `pwsh` novamente (nova aba) para recarregar o profile.
4. Se aparecer erro vermelho dizendo que o profile “não pode ser carregado porque a execução de scripts foi desabilitada”, isso é **ExecutionPolicy** do Windows PowerShell (5.1) bloqueando scripts.
   - Recomendado: use o PowerShell 7 (`pwsh`) no Windows Terminal.
   - Alternativa (por usuário): rode `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` e abra uma nova aba.
5. Se o `oh-my-posh`/`neofetch` não for encontrado, reinicie o Windows Terminal (às vezes o PATH demora a atualizar após o `winget`).

### 🐧 Linux (Ubuntu/Debian)

1. Feche e reabra o terminal.
2. Se você ainda cair no **bash**, rode:

```bash
exec zsh
```

3. Para abrir o assistente do tema (Powerlevel10k):

```bash
p10k configure
```

4. Se o script não conseguiu setar o zsh como shell padrão, rode manualmente (pode pedir senha):

```bash
sudo chsh -s "$(command -v zsh)" "$USER"
```

5. Para ver o terminal “do jeito certo”, abra o **Terminator** e valide se a fonte/ícones aparecem.

### 🍎 macOS

1. Feche e reabra o terminal.
2. Se você usa zsh (padrão no macOS), o `.zshrc` já será carregado automaticamente.
3. Se o prompt/aliases não aparecerem, rode:

```bash
source ~/.zshrc
```

4. As Nerd Fonts são instaladas via Homebrew Cask; às vezes o Terminal/iTerm precisa ser reaberto para listar a fonte.

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

### Saída verbosa do `apt` / `update-alternatives`
É normal o Ubuntu imprimir várias linhas durante instalações (ex.: `update-alternatives`, `Processing triggers`). Isso não é erro.

### `oh-my-posh` ou comandos do terminal não aparecem
Após instalar o terminal (Linux/macOS), reinicie o terminal (ou abra uma nova sessão) para recarregar o `PATH` e o `.zshrc`.

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
