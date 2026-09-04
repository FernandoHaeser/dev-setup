# Dev Setup Universal

[![platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)](https://github.com/fernandohaeser/dev-setup)
[![last commit](https://img.shields.io/github/last-commit/fernandohaeser/dev-setup)](https://github.com/fernandohaeser/dev-setup/commits/main)
[![repo size](https://img.shields.io/github/repo-size/fernandohaeser/dev-setup)](https://github.com/fernandohaeser/dev-setup)
[![issues](https://img.shields.io/github/issues/fernandohaeser/dev-setup)](https://github.com/fernandohaeser/dev-setup/issues)
[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Shell](https://img.shields.io/badge/Shell-bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

Setup automático de ambiente de desenvolvimento para **Windows, Linux e macOS**.

Com um único comando, este projeto instala e configura:

- Node.js (LTS)
- Git
- Visual Studio Code
- Extensões, tema, ícones, animações e cursor customizado do VS Code

O usuário não precisa baixar nada manualmente — basta executar o comando correspondente ao seu sistema.

- [Windows](#windows)
- [Linux](#linux-ubuntu--debian)
- [macOS](#macos)

---

## Como funciona

1. Você executa um comando.
2. O script:
   - detecta o sistema operacional;
   - instala as dependências (Node, Git, VS Code);
   - baixa apenas os arquivos necessários, de forma temporária;
   - aplica todas as configurações do VS Code;
   - remove os arquivos temporários ao finalizar.
3. Ambiente pronto para uso.

> O script não exige que você clone ou baixe o repositório. Ele apenas faz download temporário de `vscode/setup.js` e `vscode/settings.json`.

---

## Estrutura do projeto

```text
dev-setup/
├─ README.md
├─ install.ps1              # Instalador Windows
├─ install.sh               # Instalador Linux
├─ install-macos.sh         # Instalador macOS
├─ bootstrap/
├─ vscode/
│  ├─ setup.js              # Script Node (instala extensões + settings)
│  └─ settings.json         # Fonte da verdade das configurações
```

> A pasta `terminal/` ainda existe no repositório (scripts independentes de configuração de terminal), mas não é mais chamada pelos instaladores — o setup atual cobre apenas o VS Code.

---

## Windows

### Pré-requisito (evita erro de scripts bloqueados)

Antes de rodar o instalador, libere a execução de scripts para o seu usuário:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
```

> Se sua máquina for gerenciada pela empresa (GPO/Intune), esse comando pode ser bloqueado. Nesse caso, use o PowerShell 7 (`pwsh`) e/ou pule a etapa de profile do Windows PowerShell.

### Executar instalação

Abra o PowerShell como administrador e execute:

```powershell
iwr https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install.ps1 -useb | iex
```

---

## Linux (Ubuntu / Debian)

### Executar instalação

```bash
curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install.sh | bash
```

---

## macOS

### Executar instalação

```bash
curl -fsSL https://raw.githubusercontent.com/fernandohaeser/dev-setup/main/install-macos.sh | bash
```

> O Homebrew será instalado automaticamente caso não exista.

---

## O que é configurado no VS Code

- Tema escuro
- Ícones customizados (vscode-icons + Symbols)
- Animações de cursor (`vscode-animations`) e efeito de rastro (`smearcursor`)
- Prettier como formatter padrão
- GitLens
- Auto Save
- Sidebar e Activity Bar reposicionadas
- Fonte com ligatures (JetBrains Mono)
- Lista completa das extensões usadas no dia a dia (Python, PHP, Dart/Flutter, Docker, Java, remoto via SSH, entre outras)

Tudo isso vem de `vscode/settings.json`, que é a fonte da verdade das configurações e da lista de extensões (chave `__extensions`).

### Ativando o cursor customizado (Custom CSS)

O efeito de cursor depende da extensão `be5invis.vscode-custom-css`, que por segurança do VS Code não se ativa sozinha. Depois que o script terminar:

1. Abra o VS Code.
2. Abra a paleta de comandos (`Cmd/Ctrl + Shift + P`).
3. Rode o comando **Enable Custom CSS and JS**.
4. Reinicie o VS Code quando solicitado.

Esse passo é manual porque a extensão precisa alterar um arquivo interno do próprio VS Code — não há como automatizar isso com segurança pelo script.

---

## Posso rodar mais de uma vez?

Sim. O setup é idempotente:

- não reinstala o que já existe;
- apenas ajusta o que estiver faltando.

---

## Quero personalizar

- Configurações do VS Code → edite `vscode/settings.json`.
- Lista de extensões → edite a chave `__extensions` em `vscode/settings.json`.

---

## Problemas comuns

### `code: command not found`
Reabra o terminal ou reinicie o sistema.

### Saída verbosa do `apt` / `update-alternatives`
É normal o Ubuntu imprimir várias linhas durante instalações (ex.: `update-alternatives`, `Processing triggers`). Isso não é erro.

### Extensão não instalou
Abra o VS Code uma vez manualmente e rode o script novamente.

---

## Requisitos mínimos

- Windows 11
- Ubuntu/Debian ou derivado (20.04+)
- macOS 12+
- Conexão com internet

Nada mais.

---

## Filosofia

> Clone nada. Configure nada. Pense em nada.
> Só rode o comando e comece a codar.

---

## Dica final

Depois de finalizar, reinicie o terminal para carregar todas as configurações corretamente.

Bom código.
