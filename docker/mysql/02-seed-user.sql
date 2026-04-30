-- Local-only dev seed — single test user matching DEV_AUTO_LOGIN_USER_ID in
-- gestion/config.docker.php (id_utilisateur = 347). Not real PII.
--
--   Email:    dev@appliceo.local
--   Password: Test123!  (bcrypt $2b$, accepted by PHP password_verify)
--   Type:    administrateur

INSERT INTO `ap_users` VALUES (
    347,
    'm',
    'dev',
    'Dev',
    'User',
    'dev@appliceo.local',
    NULL,
    '0000000000',
    '0000000000',
    'fr',
    '$2b$10$.9NEMsFA22CRhMDC/yO2De8aqwgiRpbdzyPNZ061pHJ7YpznRAbFC',
    'administrateur',
    NULL,
    347,
    NULL,
    NULL,
    NULL,
    '2020-01-01 00:00:00',
    '2020-01-01 00:00:00',
    1,
    '2026-04-30 00:00:00',
    '127.0.0.1',
    NULL,
    NULL,
    NULL, NULL,
    NULL, NULL,
    NULL, NULL, NULL, NULL
);
