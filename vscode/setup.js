#!/usr/bin/env node

const { execSync } = require('child_process')
const fs = require('fs')
const os = require('os')
const path = require('path')

console.log('🧠 Configurando VS Code')

const extensions = [
  'eamodio.gitlens',
  'esbenp.prettier-vscode',
  'miguelsolorio.symbols',
  'brandonkirbyson.vscode-animations',
  'be5invis.vscode-custom-css'
]

extensions.forEach(ext => {
  try {
    execSync(`code --install-extension ${ext}`, { stdio: 'ignore' })
    console.log(`✔ ${ext}`)
  } catch {}
})

let settingsPath
if (os.platform() === 'win32') {
  settingsPath = path.join(process.env.APPDATA, 'Code', 'User', 'settings.json')
} else {
  settingsPath = path.join(os.homedir(), '.config', 'Code', 'User', 'settings.json')
}

fs.mkdirSync(path.dirname(settingsPath), { recursive: true })

const baseSettings = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'settings.json'), 'utf8')
)

let current = {}
if (fs.existsSync(settingsPath)) {
  current = JSON.parse(fs.readFileSync(settingsPath, 'utf8'))
}

const finalSettings = { ...current, ...baseSettings }

fs.writeFileSync(settingsPath, JSON.stringify(finalSettings, null, 2))
console.log('✅ VS Code pronto')