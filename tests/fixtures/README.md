# Fixtures de payload de hook

Payloads JSON representando o que o Kiro envia no STDIN de um hook `command`
no evento `PreToolUse`. Usados por `test-hook-integration.sh` para validar que
os adaptadores extraem o comando corretamente, independente da variação de schema.

As chaves cobertas (`tool_input.command`, `toolInput.command`, `input.command`,
`command`) refletem os fallbacks implementados em `scripts/hooks/*.sh`, garantindo
robustez a variações de versão do protocolo de hooks.
