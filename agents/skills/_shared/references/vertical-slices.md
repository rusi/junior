# Vertical Slice Validation

A slice delivers a working outcome through the product's actual consumer boundary:
an API response, CLI result, library behavior, rendered document, configuration effect,
or UI. The consumer may be a person or another program. This is a planning norm;
selecting the boundary and required layers requires judgment.

Before presenting a contract or generating a story:
- Name the consumer, the outcome, and how that consumer can verify it.
- Include every layer that outcome needs; do not add a UI, service, or database solely
  to satisfy a generic stack checklist.
- Integrate with the real product architecture. Reduce capability while keeping the
  outcome complete; do not defer required integration or verification to another story.
- For code, specify behavioral tests at the consumer boundary and relevant internal layers.
  For documents or configuration, specify artifact review or observable validation.

Valid slices include a library operation with tested return values and errors, an API
that returns real results through its required storage, a CLI that produces a usable file,
a rendered document, or a static UI with no backend requirement.

A database schema alone is incomplete when the promised outcome is an editable profile.
An API operation is complete when the API is the intended consumer boundary; it is
incomplete when the promised outcome also requires a profile screen that is absent.

If a slice fails, name the missing outcome or integration. Recommend narrowing capability
or including the missing required layer, without adding unrelated presentation layers.
