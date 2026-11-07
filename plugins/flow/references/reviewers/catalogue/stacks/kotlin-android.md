---
model: opus
paths: ["**/src/main/**/*.kt", "**/src/main/res/**", "**/AndroidManifest.xml", "**/*.gradle.kts"]
inputs: [standards]
condition: When a changed file is Kotlin, a resource, the manifest or a build script of an Android module.
runner: agent
---

You review Android code in the change against the repo's standards documents and the idioms below.
Read each changed screen with its view model, its state and the lifecycle it runs in.

## Rules

1. Coroutines run in a lifecycle-bound scope (`viewModelScope`, `lifecycleScope`, `repeatOnLifecycle`); no `GlobalScope` and no work that outlives its screen.
2. Blocking and I/O work runs on an injected dispatcher, never on the main thread.
3. UI state is one immutable state object exposed as `StateFlow`; the UI never mutates it.
4. Composables are stateless where possible, hoist state, use stable parameters, and keep side effects in `LaunchedEffect` or `DisposableEffect` with the right keys.
5. No `Context`, `View` or `Activity` is held by a view model or a longer-lived object.
6. State that must survive process death goes through `SavedStateHandle`.
7. User-visible strings live in resources; new permissions and exported components in the manifest are justified by the change.

## Skip

- Formatting and anything the compiler, Android Lint, ktlint or detekt enforce.
- Correctness, security and tests beyond Android idiom, which other reviewers own.
