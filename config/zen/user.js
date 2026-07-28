// Zen Browser - prefs gerenciadas pelos dotfiles
// Este arquivo e reaplicado a cada inicializacao do navegador.

// Habilita userChrome.css / userContent.css. Sem isto o tema nao carrega.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Forca a UI do navegador em escuro (0 = dark, 1 = light, 2 = system)
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.theme.content-theme", 0);

// Reduz o flash branco entre navegacoes
user_pref("browser.display.background_color.dark", "#1a1b26");
