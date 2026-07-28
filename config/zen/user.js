// Zen Browser - prefs gerenciadas pelos dotfiles
// Reaplicado a cada inicializacao do navegador.

// Habilita userChrome.css / userContent.css. Sem isto o tema nao carrega.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// ---- tema escuro ----
// O tema ativo e o "default-theme" (segue o sistema) e ele reportava
// color-scheme: light para o chrome, o que fazia o light-dark() do Zen cair no
// ramo claro e pintar a sidebar de rgb(235,235,235). Isto forca a deteccao.
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("browser.theme.toolbar-theme", 0); // 0 = dark
user_pref("browser.theme.content-theme", 0);
user_pref("browser.display.background_color.dark", "#1a1b26");

// ---- knobs nativos do Zen ----
// zen.theme.accent-color alimenta --zen-primary-color direto por JS
// (zenThemeModifier.js), e o Zen deriva o resto da paleta a partir dele.
// Faz o mesmo que sobrescrever a variavel no CSS, sem tocar em CSS.
user_pref("zen.theme.accent-color", "#7aa2f7"); // string
user_pref("zen.theme.border-radius", 10);       // int, casa com o Hyprland

// O FUNDO da sidebar/toolbar NAO se define aqui: e o gradiente por workspace,
// escolhido na propria UI do Zen (botao direito no workspace -> cores).
// Tentar pintar isso via userChrome.css quebra o hover-to-expand da sidebar.
