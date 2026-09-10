# Encryption

The application uses [ActiveRecord Encryption](https://guides.rubyonrails.org/active_record_encryption.html) to encrypt sensitive data.

Application-level encryption ensures that we reduce the risk of leaking PII information should
the database ever be compromised.

## Key derivation is moving from SHA-1 to SHA-256

Rails 7.1 changed the digest used to derive encryption keys from SHA-1 to SHA-256. Every
encrypted column in this database was written under SHA-1, so the change cannot be taken
until the existing ciphertext has been rewritten.

Keys are now derived with SHA-256. `config/application.rb` keeps one override:

```ruby
config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true
```

That registers a SHA-1 previous scheme, which carries the eight non-deterministic columns:
`User#family_name`, `#given_name`, `#name` and `#one_login_verified_name`, `DsiUser#first_name`
and `#last_name`, `Console1984::Command#statements` and `Audits1984::Audit#notes`. They decrypt
under either digest while it is set.

It does nothing for the two deterministic columns, `User#email` and `DsiUser#email`. The scheme
it adds is non-deterministic, and Rails only attaches a previous scheme to an attribute whose
determinism matches, so those two have no fallback and must be rewritten.

### Converting the data

```bash
make production railstask TASK=pii:re_encrypt
make production railstask TASK=pii:verify
```

`pii:re_encrypt` rewrites every encrypted column under the current digest, in batches, one
transaction per batch. Each batch logs the arguments to resume with, so an interruption is recovered by copying
`pii:re_encrypt[User,12345]` from the log. Rerunning it is safe: it writes the
same plaintext back, though the non-deterministic columns get fresh ciphertext each pass.

`pii:verify` reads every encrypted column through a type with no previous schemes and exits
non-zero if anything fails, so it answers the only question that matters: would these rows
survive the override being removed. It has to build that type itself, because the models' own
types have the SHA-1 fallback and would report success right up until the override goes.

Nothing in the ciphertext records which digest derived its key (`store_key_references` is off),
so there is no way to count remaining rows in SQL. Reading them is the only check.

Both tasks are ordinary rake tasks, so console1984's protected mode does not apply: it installs
only when a console starts. They must be run with the service in maintenance mode. Once the digest change
is deployed, any write to `User` or `DsiUser` decrypts the record through DfE Analytics'
after-commit callback, which raises on a row that has not been converted yet.

The override comes out once `pii:verify` reports nothing in production. Tracked at
https://github.com/DFE-Digital/teaching-record-team-project-board/issues/455

Note this is all specific to Active Record encryption. `active_support.key_generator_hash_digest_class`,
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
