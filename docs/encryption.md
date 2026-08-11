# Encryption

The application uses [ActiveRecord Encryption](https://guides.rubyonrails.org/active_record_encryption.html) to encrypt sensitive data.

Application-level encryption ensures that we reduce the risk of leaking PII information should
the database ever be compromised.

## Key derivation uses SHA-1

`config/application.rb` pins two settings below `config.load_defaults`:

```ruby
config.active_record.encryption.hash_digest_class = OpenSSL::Digest::SHA1
config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true
```

Rails 7.1 changed the digest used to derive encryption keys from SHA-1 to SHA-256. Every
encrypted column in this database was written under SHA-1, so taking the new default would
change the derived key: deterministic `email` lookups on `User` and `DsiUser` would match
nothing, and the non-deterministic name columns would not decrypt at all.

Do not remove these without re-encrypting the existing data first. Note this is specific to
Active Record encryption — `active_support.key_generator_hash_digest_class`, which signs
session cookies, moved to SHA-256 back in Rails 7.0 and is not pinned.

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
