#!/usr/bin/env node

const { execSync } = require('child_process')
const fs = require('fs')
const os = require('os')
const path = require('path')

console.log('🧠 Configurando VS Code')

function parseJsonLenient(text) {
  try {
    return JSON.parse(text)
  } catch {}

  const withoutBlockComments = text.replace(/\/\*[\s\S]*?\*\//g, '')
  const withoutLineComments = withoutBlockComments.replace(/^\s*\/\/.*$/gm, '')
  const withoutTrailingCommas = withoutLineComments.replace(/,\s*([}\]])/g, '$1')
  return JSON.parse(withoutTrailingCommas)
}

function hasCodeCli() {
  try {
    execSync('code --version', { stdio: 'ignore' })
    return true
  } catch {
    return false
  }
}

const extensions = [
  'eamodio.gitlens',
  'esbenp.prettier-vscode',
  'miguelsolorio.symbols',
  'brandonkirbyson.vscode-animations',
  'be5invis.vscode-custom-css'
]

if (!hasCodeCli()) {
  console.log("⚠️  Comando 'code' não encontrado; pulando instalação de extensões (reinicie o terminal/abra o VS Code uma vez e rode novamente).")
} else {
  extensions.forEach(ext => {
    try {
      execSync(`code --install-extension ${ext}`, { stdio: 'ignore' })
      console.log(`✔ ${ext}`)
    } catch {
      console.log(`⚠️  Falhou ao instalar: ${ext}`)
    }
  })
}

let settingsPath
if (os.platform() === 'win32') {
  settingsPath = path.join(process.env.APPDATA, 'Code', 'User', 'settings.json')
} else {
  settingsPath = path.join(os.homedir(), '.config', 'Code', 'User', 'settings.json')
}

fs.mkdirSync(path.dirname(settingsPath), { recursive: true })

const baseSettings = parseJsonLenient(
  fs.readFileSync(path.join(__dirname, 'settings.json'), 'utf8')
)

let current = {}
if (fs.existsSync(settingsPath)) {
  try {
    current = parseJsonLenient(fs.readFileSync(settingsPath, 'utf8'))
  } catch {
    current = {}
  }
}

const finalSettings = { ...current, ...baseSettings }

fs.writeFileSync(settingsPath, JSON.stringify(finalSettings, null, 2))
console.log('✅ VS Code pronto')