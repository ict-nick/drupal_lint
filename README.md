# drupal-lint

A shared, Composer-installable Drupal linting toolkit aligned with Drupal.org CI.

## Add to a Drupal project

This package is consumed directly from GitHub.

```bash
composer config repositories.ict-nick-drupal-lint vcs https://github.com/ict-nick/drupal_lint.git
composer require --dev ict-nick/drupal-lint:dev-main
```

## Usage

Lint only git-changed custom code (default):

`sh vendor/bin/files.sh | sh vendor/bin/lint.sh`

Lint all custom code:

`sh vendor/bin/files.sh --all | sh vendor/bin/lint.sh`
