# Contributing

Contributions are always welcome, no matter how large or small!

We want this community to be friendly and respectful to each other. Please follow it in all your interactions with the project. Before contributing, please read the [code of conduct](./CODE_OF_CONDUCT.md).

## Development workflow

This project contains the following packages:

- The library package in the root directory.
- An example app in the `example/` directory.

To get started with the project, run `flutter pub get` in the root directory to install the required dependencies:

```sh
flutter pub get
```

Then install dependencies for the example app:

```sh
cd example
flutter pub get
```

The [example app](/example/) demonstrates usage of the library. You need to run it to test any changes you make.

It is configured to use the local version of the library, so any changes you make to the library's source code will be reflected in the example app.

You can use various commands from the root directory to work with the project.

To run the example app on Android:

```sh
cd example
flutter run -d android
```

To run the example app on iOS:

```sh
cd example
flutter run -d ios
```

Make sure your code passes the Dart analyzer and lints. Run the following to verify:

```sh
flutter analyze
```

To fix formatting errors, run the following:

```sh
dart format .
```

Remember to add tests for your change if possible. Run the unit tests by:

```sh
flutter test
```

### Commit message convention

We follow the [conventional commits specification](https://www.conventionalcommits.org/en) for our commit messages:

- `fix`: bug fixes, e.g. fix crash due to deprecated method.
- `feat`: new features, e.g. add new method to the module.
- `refactor`: code refactor, e.g. migrate from one pattern to another.
- `docs`: changes into documentation, e.g. add usage example for the module.
- `test`: adding or updating tests, e.g. add integration tests.
- `chore`: tooling changes, e.g. change CI config.

### Linting and tests

We use the [Dart analyzer](https://dart.dev/tools/dart-analyze) for static analysis and [flutter_lints](https://pub.dev/packages/flutter_lints) for linting the code.

### Scripts

Common commands for development:

- `flutter pub get`: Install project dependencies.
- `flutter analyze`: Run static analysis on the codebase.
- `dart format .`: Format code according to Dart style guidelines.
- `flutter test`: Run unit tests.
- `flutter pub publish --dry-run`: Validate package before publishing.

### Sending a pull request

> **Working on your first pull request?** You can learn how from this _free_ series: [How to Contribute to an Open Source Project on GitHub](https://app.egghead.io/playlists/how-to-contribute-to-an-open-source-project-on-github).

When you're sending a pull request:

- Prefer small pull requests focused on one change.
- Verify that linters and tests are passing.
- Review the documentation to make sure it looks good.
- Follow the pull request template when opening a pull request.
- For pull requests that change the API or implementation, discuss with maintainers first by opening an issue.
