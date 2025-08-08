// Firefox kiosk configuration
// This file configures Firefox preferences for kiosk mode

// Disable updates
user_pref("app.update.enabled", false);
user_pref("app.update.auto", false);

// Disable new tab page and home page suggestions
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");

// Disable toolbars and UI elements (but keep tabs visible for two-tab kiosk)
user_pref("browser.toolbars.bookmarks.visibility", "never");
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.sessionstore.resume_from_crash", false);

// Tab-related preferences for kiosk mode
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.tabs.warnOnCloseOtherTabs", false);
user_pref("browser.link.open_newwindow", 3); // Open new windows in tabs
user_pref("browser.link.open_newwindow.restriction", 0);

// Disable password manager
user_pref("signon.rememberSignons", false);

// Disable downloads
user_pref("browser.download.forbid_open_with", true);
user_pref("browser.download.useDownloadDir", false);

// Disable notifications
user_pref("dom.webnotifications.enabled", false);
user_pref("dom.push.enabled", false);

// Disable right-click context menu
user_pref("dom.event.contextmenu.enabled", false);

// Disable developer tools
user_pref("devtools.toolbox.host", "disabled");
user_pref("devtools.debugger.enabled", false);

// Disable zoom
user_pref("zoom.minPercent", 100);
user_pref("zoom.maxPercent", 100);

// Disable geolocation
user_pref("geo.enabled", false);

// Disable camera and microphone
user_pref("media.navigator.enabled", false);

// Performance optimizations
user_pref("gfx.webrender.enabled", true);
user_pref("layers.acceleration.force-enabled", true);

// Disable crash reporting
user_pref("toolkit.crashreporter.enabled", false);

// Disable safe browsing delays
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);

// Additional kiosk preferences for two-tab mode
user_pref("browser.tabs.tabMinWidth", 100); // Ensure tabs are visible
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.userMadeSearchSuggestionsChoice", true);
user_pref("browser.search.suggest.enabled", false);

// Prevent new tab/window creation via keyboard shortcuts
user_pref("browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
