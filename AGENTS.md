# Smart-X development guidance

- This project implements Part 1 of the Smart-X IoT assessment in .NET 10.
- Keep the backend in C# and preserve native float/int/bool ingestion paths.
- Do not replace telemetry payloads with object/dynamic storage or string coercion.
- Preserve the disabled command/history and mesh-routing pillars until their
  assessment requirements are provided.
- Preserve the generic packet class, overloaded reading operators, jagged-array
  conversion and recursive deployment validation in real execution paths.
- Client source lives in `src/SmartX.Client` and is copied by the API project.
  Do not manually edit generated `bin`/`obj` assets.
- Keep runtime data out of source control and published deliverables.
- Use meaningful commits. Do not invent student authorship or backdated history.
- For behavior changes, build the solution and run the relevant existing core,
  API and browser checks. The integration/browser scripts use their own data folders.
- Update the README and requirement map if public behavior changes.
- The research report is a separate deliverable to prepare after app review.
