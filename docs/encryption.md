# Encryption

The application uses [ActiveRecord Encryption](https://guides.rubyonrails.org/active_record_encryption.html) to encrypt sensitive data.

Application-level encryption ensures that we reduce the risk of leaking PII information should
the database ever be compromised.

## Key derivation

Keys are derived with SHA-256, the Rails default since `load_defaults 7.1`.

Every encrypted column in this database was originally written under SHA-1, which was the
default when they were first encrypted. They were rewritten under SHA-256 by a one-off
`pii:re_encrypt` task, run with the service in maintenance mode, and the SHA-1 overrides in
`config/application.rb` were removed once a companion `pii:verify` task confirmed no row
depended on them. Both tasks were deleted afterwards. See
https://github.com/DFE-Digital/teaching-record-team-project-board/issues/455

One thing worth knowing before changing a digest or key again: nothing in the ciphertext
records which key derived it, because `store_key_references` is off. There is no way to tell a
converted row from an unconverted one in SQL, and no way to count what is left. Any future
change needs the same shape of migration, and the only completion check available is reading
every row through a type with no previous schemes.

Note this is specific to Active Record encryption. `active_support.key_generator_hash_digest_class`,
which signs session cookies, moved to SHA-256 back in Rails 7.0 and is not pinned.

## Encryption keys

Rails encrypts data using a key that is stored outside of version control. In deployed environments
we use the RAILS_MASTER_KEY environment variable to pass the key to the application.

For local development, the key is stored in `config/master.key`. This file is not encrypted, so it
should be kept secret.

### Accessing the key

To gain access to this key, you can call `make dev print-keyvault-secret | grep RAILS_MASTER_KEY` and
then copy the value from the output to your local `config/master.key` file.

### Rotating keys

There may be a reason to rotate the encryption key in the future. See [this guide](https://guides.rubyonrails.org/active_record_encryption.html#rotating-keys) for the details.

ActiveRecord Encryption supports a list of keys. It uses the last key in the list for encrypting data
and will try all the keys in the list for decrypting until one works.

To add a new key to the list, make sure you have the correct value set in `config/master.key`. Then...

```bash
EDITOR=vi rails credentials:edit
```

Add a new key to the list and then save the file. This will mutate the `config/credentials.yml.enc` file.
Commit these changes to the repo and deploy.
