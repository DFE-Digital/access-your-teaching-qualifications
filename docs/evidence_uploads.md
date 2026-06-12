# Evidence uploads

Users signed in via One Login can ask the TRA to change their name or date of birth, attaching an evidence file as part of the request. This document covers how those files are validated, scanned, and removed. See [Azure Storage](azure_storage.md) for where they're stored.

## The flow

1. The user completes the change request form and attaches a file.
2. The form object (`Qualifications::OneLoginUsers::NameChangeForm` or `DateOfBirthChangeForm`) validates the submission, then creates the change request and attaches the file via Active Storage.
3. The user confirms the request, and the controller's `confirm` action sends it to the Qualifications API and enqueues the malware scan job.
4. The file stays in storage for TRA review unless the scan flags it, in which case it's purged.

## Validation

Validation lives in the form objects under `app/forms/qualifications/one_login_users/`. A file must be present, no larger than 3MB (`MAX_SIZE`), and a PDF, JPEG or PNG (`ALLOWED_CONTENT_TYPES`).

The content type check doesn't trust the client. The declared `Content-Type` header must be an allowed type and match what Marcel sniffs from the file's magic bytes — Marcel gets only the file IO, no filename or declared type, following the [WHATWG MIME Sniffing Standard](https://mimesniff.spec.whatwg.org/).

Note that the two form objects validate independently — if you change validation in one, check the other.
