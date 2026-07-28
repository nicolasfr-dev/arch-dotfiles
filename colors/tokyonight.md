# Tokyo Night — paleta de referência

Fonte única de verdade das cores usadas em todos os configs deste repo.

## Base

| Papel | Hex | Onde aparece |
|---|---|---|
| `bg` | `#1a1b26` | fundo de janelas, waybar, foot, wofi |
| `bg_dark` | `#16161e` | fundo de campos de entrada, tooltips |
| `surface` | `#24283b` | cards (swaync widgets, botões wlogout) |
| `bg_high` | `#292e42` | hover de módulos da waybar |
| `gutter` | `#3b4261` | bordas |
| `comment` | `#565f89` | texto secundário, placeholders, ícones inativos |
| `fg_dark` | `#a9b1d6` | texto de corpo |
| `fg` | `#c0caf5` | texto principal |

## Acentos

| Papel | Hex | Onde aparece |
|---|---|---|
| `blue` | `#7aa2f7` | **acento principal** — borda ativa, relógio, workspace ativo, highlight |
| `cyan` | `#7dcfff` | rede, links |
| `magenta` | `#bb9af7` | áudio, gradiente da borda ativa, caps lock |
| `teal` | `#73daca` | bateria carregando, URLs no terminal |
| `green` | `#9ece6a` | bateria ok |
| `yellow` | `#e0af68` | brilho, bateria em aviso |
| `orange` | `#ff9e64` | submap, privacidade, reiniciar |
| `red` | `#f7768e` | erros, bateria crítica, desligar |

## Regra de uso

- **Azul** é o acento; magenta/ciano são secundários. Não usar mais de dois acentos no mesmo componente.
- Bordas sempre `gutter` (`#3b4261`); só a janela **ativa** ganha o gradiente azul → magenta.
- Estados semânticos (`green`/`yellow`/`red`) são exclusivos de bateria, rede e erros — nunca decorativos.
