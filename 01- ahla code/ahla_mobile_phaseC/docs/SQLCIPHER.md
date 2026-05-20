# SQLCipher with rusqlite (Notes)

- rusqlite doesn't bundle SQLCipher by default. You can link SQLCipher yourself.
- iOS: follow Zetetic guide (add `SQLITE_HAS_CODEC=1`, link Security.framework) and ensure no system sqlite3 conflicts.
- Android: provide libsqlcipher and link via NDK; disable bundled sqlite feature.

References:
- Zetetic SQLCipher (Apple): https://www.zetetic.net/sqlcipher/sqlcipher-apple-community/
- rusqlite issue on bundling sqlcipher: https://github.com/rusqlite/rusqlite/issues/765
- Troubleshooting linking (cipher_version): https://discuss.zetetic.net/t/sqlcipher-not-working-on-ios-release-builds/6764
