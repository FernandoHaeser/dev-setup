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
  const clean = text
    .replace(/\/\*[\s\S]*?\*\//g, '')   // block comments
    .replace(/^\s*\/\/.*$/gm, '')        // line comments
    .replace(/,\s*([}\]])/g, '$1')       // trailing commas
  return JSON.parse(clean)
}

function hasCodeCli() {
  try {
    execSync('code --version', { stdio: 'ignore' })
    return true
  } catch {
    return false
  }
}

function resolveExtFile(extPrefix, fallbackFolder, ...fileParts) {
  const extDir = path.join(os.homedir(), '.vscode', 'extensions')

  let folder = null
  if (fs.existsSync(extDir)) {
    folder = fs.readdirSync(extDir).find(d => d.startsWith(extPrefix))
  }

  const relPath = path.join(extDir, folder ?? fallbackFolder, ...fileParts)

  if (os.platform() === 'win32') {
    return 'file:///' + relPath.replace(/\\/g, '/')
  }
  return 'file://' + relPath
}

function getAnimationsExtPath() {
  return resolveExtFile(
    'brandonkirbyson.vscode-animations',
    'brandonkirbyson.vscode-animations-2.0.7',
    'dist', 'updateHandler.js'
  )
}

function getSmearcursorExtPath() {
  return resolveExtFile(
    'yesitsfebreeze.smearcursor',
    'yesitsfebreeze.smearcursor-1.3.0',
    '_smearcursor.js'
  )
}

function getSettingsPath() {
  const platform = os.platform()

  if (platform === 'win32') {
    return path.join(process.env.APPDATA, 'Code', 'User', 'settings.json')
  }

  if (platform === 'darwin') {
    return path.join(os.homedir(), 'Library', 'Application Support', 'Code', 'User', 'settings.json')
  }

  // linux / ubuntu
  return path.join(os.homedir(), '.config', 'Code', 'User', 'settings.json')
}

const baseSettings = parseJsonLenient(
  fs.readFileSync(path.join(__dirname, 'settings.json'), 'utf8')
)

const extensions = baseSettings['__extensions'] ?? []
delete baseSettings['__extensions']

if (!hasCodeCli()) {
  console.log("⚠️  Comando 'code' não encontrado; pulando extensões.")
} else {
  extensions.forEach(ext => {
    try {
      execSync(`code --install-extension ${ext} --force`, { stdio: 'ignore' })
      console.log(`✔ ${ext}`)
    } catch {
      console.log(`⚠️  Falhou: ${ext}`)
    }
  })
}

baseSettings['vscode_custom_css.imports'] = [getAnimationsExtPath(), getSmearcursorExtPath()]

const settingsPath = getSettingsPath()
fs.mkdirSync(path.dirname(settingsPath), { recursive: true })

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

console.log(`✅ VS Code pronto (${os.platform()} — ${settingsPath})`)
