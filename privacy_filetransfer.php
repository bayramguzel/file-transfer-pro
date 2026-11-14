<?php
$lang = isset($_GET['lang']) ? $_GET['lang'] : null;
if (!$lang) {
    $browser_lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? 'en', 0, 2);
    $supported_langs = ['tr', 'de', 'en'];
    $lang = in_array($browser_lang, $supported_langs) ? $browser_lang : 'en';
}
$appName = "Last Updated: " . date("Y");
$content = [
    'tr' => [
        'title' => 'Gizlilik Politikası - ' . $appName, 'home' => 'Anasayfa', 'effective_date' => 'Yürürlük Tarihi',
        'intro_title' => 'Giriş', 'intro_text' => '41Software olarak gizliliğinize önem veriyoruz.',
        'collect_title' => 'Toplanan Veriler', 'points' => '<h3>Privacy Policy - File Transfer Pro</h3>
<li><strong>Last Updated:</strong> ' . date("Y") . '</li>
<li><strong>Company:</strong> 41software.com</li>
<li><strong>Contact:</strong> info@41software.com</li>
<h3>Introduction</h3>
<li>File Transfer Pro is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our application.</li>
<h3>Information We Collect</h3>
<li>File Transfer Pro is designed with privacy in mind:</li>
<li><strong>No Personal Data Collection</strong>: We do not collect, store, or transmit any personal information to external servers.</li>
<li><strong>Local Processing</strong>: All file transfers occur directly between your devices on your local network or via Bluetooth.</li>
<li><strong>No Account Required</strong>: The app does not require user registration or account creation.</li>
<h3>Data Usage</h3>
<li><strong>Profile Name</strong>: Your chosen display name is stored locally on your device only.</li>
<li><strong>Transfer History</strong>: File transfer records are stored locally on your device and are never uploaded to external servers.</li>
<li><strong>App Settings</strong>: All preferences and settings are stored locally using device storage.</li>
<h3>Permissions</h3>
<li>The app requires certain permissions to function:</li>
<li><strong>Storage Access</strong>: To read and write files for transfer</li>
<li><strong>Network Access</strong>: To discover and connect to devices on your local network</li>
<li><strong>Bluetooth</strong>: To enable Bluetooth file transfers</li>
<li><strong>Location (when required)</strong>: Some Android versions require location permission for WiFi scanning</li>
<li>These permissions are used solely for the app\'s core functionality and never for data collection.</li>
<h3>Data Security</h3>
<li>All file transfers are performed using secure, encrypted connections</li>
<li>No data is stored on intermediate servers</li>
<li>Files are transferred directly between devices</li>
<h3>Third-Party Services</h3>
<li>File Transfer Pro does not integrate with any third-party analytics, advertising, or tracking services.</li>
<h3>Children\'s Privacy</h3>
<li>Our app does not knowingly collect information from children under 13 years of age.</li>
<h3>Changes to This Policy</h3>
<li>We may update this Privacy Policy from time to time. Any changes will be reflected in the app and on our website.</li>
<h3>Contact Us</h3>
<li>If you have any questions about this Privacy Policy, please contact us:</li>
<li><strong>Website:</strong> www.41software.com</li>
<li><strong>Email:</strong> info@41software.com</li>
<h3>Your Rights</h3>
<li>You have the right to:</li>
<li>Delete all app data at any time through your device settings</li>
<li>Revoke app permissions through your device settings</li>
<li>Contact us with any privacy concerns</li>
<li>© ' . date('Y') . ' 41software.com - All Rights Reserved</li>',
        'security_title' => 'Güvenlik', 'security_text' => 'Verileriniz cihazınızda yerel olarak saklanır.',
        'contact_title' => 'İletişim', 'contact_text' => 'Sorularınız için bizimle iletişime geçebilirsiniz.', 'last_updated' => 'Son Güncelleme:'
    ],
    'en' => [
        'title' => 'Privacy Policy - ' . $appName, 'home' => 'Home', 'effective_date' => 'Effective Date',
        'intro_title' => 'Introduction', 'intro_text' => 'At 41Software, we value your privacy.',
        'collect_title' => 'Information Collected', 'points' => '<h3>Privacy Policy - File Transfer Pro</h3>
<li><strong>Last Updated:</strong> ' . date("Y") . '</li>
<li><strong>Company:</strong> 41software.com</li>
<li><strong>Contact:</strong> info@41software.com</li>
<h3>Introduction</h3>
<li>File Transfer Pro is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our application.</li>
<h3>Information We Collect</h3>
<li>File Transfer Pro is designed with privacy in mind:</li>
<li><strong>No Personal Data Collection</strong>: We do not collect, store, or transmit any personal information to external servers.</li>
<li><strong>Local Processing</strong>: All file transfers occur directly between your devices on your local network or via Bluetooth.</li>
<li><strong>No Account Required</strong>: The app does not require user registration or account creation.</li>
<h3>Data Usage</h3>
<li><strong>Profile Name</strong>: Your chosen display name is stored locally on your device only.</li>
<li><strong>Transfer History</strong>: File transfer records are stored locally on your device and are never uploaded to external servers.</li>
<li><strong>App Settings</strong>: All preferences and settings are stored locally using device storage.</li>
<h3>Permissions</h3>
<li>The app requires certain permissions to function:</li>
<li><strong>Storage Access</strong>: To read and write files for transfer</li>
<li><strong>Network Access</strong>: To discover and connect to devices on your local network</li>
<li><strong>Bluetooth</strong>: To enable Bluetooth file transfers</li>
<li><strong>Location (when required)</strong>: Some Android versions require location permission for WiFi scanning</li>
<li>These permissions are used solely for the app\'s core functionality and never for data collection.</li>
<h3>Data Security</h3>
<li>All file transfers are performed using secure, encrypted connections</li>
<li>No data is stored on intermediate servers</li>
<li>Files are transferred directly between devices</li>
<h3>Third-Party Services</h3>
<li>File Transfer Pro does not integrate with any third-party analytics, advertising, or tracking services.</li>
<h3>Children\'s Privacy</h3>
<li>Our app does not knowingly collect information from children under 13 years of age.</li>
<h3>Changes to This Policy</h3>
<li>We may update this Privacy Policy from time to time. Any changes will be reflected in the app and on our website.</li>
<h3>Contact Us</h3>
<li>If you have any questions about this Privacy Policy, please contact us:</li>
<li><strong>Website:</strong> www.41software.com</li>
<li><strong>Email:</strong> info@41software.com</li>
<h3>Your Rights</h3>
<li>You have the right to:</li>
<li>Delete all app data at any time through your device settings</li>
<li>Revoke app permissions through your device settings</li>
<li>Contact us with any privacy concerns</li>
<li>© ' . date('Y') . ' 41software.com - All Rights Reserved</li>',
        'security_title' => 'Security', 'security_text' => 'Your data is stored locally on your device.',
        'contact_title' => 'Contact Us', 'contact_text' => 'For questions and support regarding our privacy policy.', 'last_updated' => 'Last Updated:'
    ],
    'de' => [
        'title' => 'Datenschutzerklärung - ' . $appName, 'home' => 'Startseite', 'effective_date' => 'Gültig ab',
        'intro_title' => 'Einführung', 'intro_text' => 'Bei 41Software legen wir Wert auf Ihre Privatsphäre.',
        'collect_title' => 'Gesammelte Daten', 'points' => '<h3>Privacy Policy - File Transfer Pro</h3>
<li><strong>Last Updated:</strong> ' . date("Y") . '</li>
<li><strong>Company:</strong> 41software.com</li>
<li><strong>Contact:</strong> info@41software.com</li>
<h3>Introduction</h3>
<li>File Transfer Pro is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our application.</li>
<h3>Information We Collect</h3>
<li>File Transfer Pro is designed with privacy in mind:</li>
<li><strong>No Personal Data Collection</strong>: We do not collect, store, or transmit any personal information to external servers.</li>
<li><strong>Local Processing</strong>: All file transfers occur directly between your devices on your local network or via Bluetooth.</li>
<li><strong>No Account Required</strong>: The app does not require user registration or account creation.</li>
<h3>Data Usage</h3>
<li><strong>Profile Name</strong>: Your chosen display name is stored locally on your device only.</li>
<li><strong>Transfer History</strong>: File transfer records are stored locally on your device and are never uploaded to external servers.</li>
<li><strong>App Settings</strong>: All preferences and settings are stored locally using device storage.</li>
<h3>Permissions</h3>
<li>The app requires certain permissions to function:</li>
<li><strong>Storage Access</strong>: To read and write files for transfer</li>
<li><strong>Network Access</strong>: To discover and connect to devices on your local network</li>
<li><strong>Bluetooth</strong>: To enable Bluetooth file transfers</li>
<li><strong>Location (when required)</strong>: Some Android versions require location permission for WiFi scanning</li>
<li>These permissions are used solely for the app\'s core functionality and never for data collection.</li>
<h3>Data Security</h3>
<li>All file transfers are performed using secure, encrypted connections</li>
<li>No data is stored on intermediate servers</li>
<li>Files are transferred directly between devices</li>
<h3>Third-Party Services</h3>
<li>File Transfer Pro does not integrate with any third-party analytics, advertising, or tracking services.</li>
<h3>Children\'s Privacy</h3>
<li>Our app does not knowingly collect information from children under 13 years of age.</li>
<h3>Changes to This Policy</h3>
<li>We may update this Privacy Policy from time to time. Any changes will be reflected in the app and on our website.</li>
<h3>Contact Us</h3>
<li>If you have any questions about this Privacy Policy, please contact us:</li>
<li><strong>Website:</strong> www.41software.com</li>
<li><strong>Email:</strong> info@41software.com</li>
<h3>Your Rights</h3>
<li>You have the right to:</li>
<li>Delete all app data at any time through your device settings</li>
<li>Revoke app permissions through your device settings</li>
<li>Contact us with any privacy concerns</li>
<li>© ' . date('Y') . ' 41software.com - All Rights Reserved</li>',
        'security_title' => 'Sicherheit', 'security_text' => 'Ihre Daten werden lokal auf Ihrem Gerät gespeichert.',
        'contact_title' => 'Kontakt', 'contact_text' => 'Bei Fragen wenden Sie sich bitte an uns.', 'last_updated' => 'Aktualisiert am:'
    ]
];
$c = $content[$lang];
?>
<!DOCTYPE html>
<html lang="<?php echo $lang; ?>">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $c['title']; ?></title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; line-height: 1.6; padding: 20px; background: #f4f7f9; color: #333; }
        .container { max-width: 850px; margin: auto; background: #fff; padding: 40px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        h1 { color: #1e3a8a; border-bottom: 3px solid #3b82f6; padding-bottom: 10px; }
        h2 { color: #1e40af; margin-top: 30px; border-left: 5px solid #3b82f6; padding-left: 15px; }
        h3 { color: #374151; background: #f3f4f6; padding: 10px; border-radius: 5px; }
        .nav-buttons { display: flex; justify-content: center; gap: 10px; margin: 20px 0; flex-wrap: wrap; }
        .btn { display: inline-block; padding: 12px 24px; text-decoration: none; background: #3b82f6; color: white; border-radius: 8px; font-weight: bold; transition: 0.3s; }
        .btn:hover { background: #1d4ed8; transform: translateY(-2px); }
        .lang-switch { text-align: right; margin-bottom: 15px; }
        .btn-lang { padding: 6px 15px; background: #fff; border: 1px solid #ddd; font-size: 0.8em; }
        .btn-lang.active { background: #3b82f6; color: #fff; }
        ul { list-style-type: none; padding: 0; }
        li { margin-bottom: 12px; padding-left: 30px; position: relative; }
        li::before { content: "🔹"; position: absolute; left: 0; }
        hr { margin: 40px 0; border: 0; border-top: 1px solid #eee; }
    </style>
</head>
<body>
<div class="lang-switch">
    <a href="?lang=tr" class="btn btn-lang <?php echo $lang=='tr'?'active':''; ?>">TR</a>
    <a href="?lang=de" class="btn btn-lang <?php echo $lang=='de'?'active':''; ?>">DE</a>
    <a href="?lang=en" class="btn btn-lang <?php echo $lang=='en'?'active':''; ?>">EN</a>
</div>
<div class="container">
    <div class="nav-buttons">
        <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (TR)</a>
        <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (DE)</a>
        <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (EN)</a>
    </div>
    <h1><?php echo $c['title']; ?></h1>
    <p><strong><?php echo $c['effective_date']; ?>:</strong> <?php echo date('d.m.Y'); ?></p>
    <h2><?php echo $c['intro_title']; ?></h2><p><?php echo $c['intro_text']; ?></p>
    <h2><?php echo $c['collect_title']; ?></h2><div class="policy-content"><ul><?php echo $c['points']; ?></ul></div>
    <h2><?php echo $c['security_title']; ?></h2><p><?php echo $c['security_text']; ?></p>
    <h2><?php echo $c['contact_title']; ?></h2><p><?php echo $c['contact_text']; ?></p>
    <p><strong>41Software</strong><br><a href="https://www.41software.com">www.41software.com</a><br>Email: info@41software.com</p>
    <div class="nav-buttons">
        <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (TR)</a>
        <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (DE)</a>
        <a href="https://www.41software.com" class="btn"><?php echo $c['home']; ?> (EN)</a>
    </div>
    <hr><div class="footer-info"><p>&copy; <?php echo date('Y'); ?> 41Software</p></div>
</div>
</body>
</html>
