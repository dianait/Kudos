# 🎯 Documentation guidelines

## Structure

Each documentation file follows this template:

```markdown
# 🎯 [Category]: [Title]

## 💡 Convention

[Convention summary - 1-2 sentences explaining the rule.]

## 🏆 Benefits

- [Benefit 1.]
- [Benefit 2.]
- [Benefit 3.]

## 👀 Examples

### ✅ Good: [Brief description of the good practice]

[Code block or description.]

### ❌ Bad: [Brief description of the bad practice]

[Code block or description.]

## 🧐 Real world examples

- [`Component/File Name`](./path/to/file.swift)
- [`Another Component`](./path/to/another/file.swift)

## ☝️ Exceptional cases: When to not take into account this convention

[List of cases where exceptions are valid.]

### 🥽 Example of exceptional case

[Description of the exceptional case context.]

[Code block or description showing the valid exception.]

## 🔗 Related agreements

- [Related agreement title](./path-to-related-agreement.md).
- [Another related agreement](./path-to-another-agreement.md).
```

## Title and file name

The filename is critical: AI agents use it to decide whether to load the document or not. A descriptive filename ensures the convention is discovered and applied; a vague one means it will be ignored.

Use kebab-case for the filename, derived from the title. Reflect in the title and filename the actual convention instead of the generic category or concept.

Examples:

- "Localization via Copies and A11y enums" → `copies-a11y-localized-enums.md`.
- "Constants extracted to typed enums" → `constants-as-typed-enums.md`.
- "MVVM only when state exceeds 4 properties" → `mvvm-viewmodel-threshold.md`.

## Good and bad examples

- Use H4 (`####`) sub-headings only when there are multiple examples within a good or bad section.
- Use the appropriate code language in fenced code blocks (always `swift` for Swift code).
- Avoid code comments in the example snippets. Provide a brief description between the heading and the code block only if really necessary.

## Optional sections

- If the convention doesn't have exceptional cases, omit the "Exceptional cases" section entirely.
- If there are no real world examples, omit the "Real world examples" section entirely.
- If there are no related agreements, omit the "Related agreements" section entirely.

## Style

- Maximize information density: convey as much as possible in as few words as possible.
- End each phrase with a period, including bullet point items.
- Avoid documenting with the whole phrase in strong emphasis.

## Reference example

See [`docs/utilities/constants-as-typed-enums.md`](utilities/constants-as-typed-enums.md) as a complete example of correctly structured documentation.
