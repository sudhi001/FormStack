# Security Policy

## Supported versions

| Version | Supported |
|---|---|
| 3.x | Yes |
| 2.x | Security fixes only, until 2027-02-28 |
| < 2.0 | No |

## Reporting a vulnerability

Report privately through
[GitHub Security Advisories](https://github.com/sudhi001/FormStack/security/advisories/new),
or by email to the maintainer listed on the pub.dev page. Please do not open a
public issue for a vulnerability.

Include the affected version, a description of the impact, and steps to
reproduce. You can expect an acknowledgement within 5 working days and an
assessment within 15.

## Scope

FormStack renders forms and collects answers. The areas where a defect could
have security consequences for an application:

- **Form definitions are executable input.** `loadFromAsset`,
  `buildFormFromJsonString` and the registries build UI and validators from
  JSON. Treat a form definition from a network source with the same care as
  code: validate its origin and integrity. Loading an attacker-controlled
  definition lets them choose what is asked, what is stored, and which
  validators apply.
- **Expressions.** `ResultFormat.expression` and `ExpressionRelevant` evaluate a
  small comparison grammar. It is not a general interpreter and does not reach
  the host, but expressions from an untrusted definition should still be
  treated as untrusted.
- **Collected answers.** Results are held in memory and, when persistence is
  enabled, handed to the application's `FormPersistence` implementation.
  FormStack does not encrypt them; choosing appropriate at-rest protection for
  the data being collected is the application's responsibility. This matters
  particularly for the health and research use cases the library targets.
- **Client-side validation is not a security control.** `ResultFormat` improves
  data quality and user experience. Re-validate on the server.

## Out of scope

- Vulnerabilities in the Flutter SDK or in third-party dependencies — report
  those upstream, though we will take a dependency bump.
- Denial of service caused by a deliberately pathological form definition
  supplied by the application itself.
