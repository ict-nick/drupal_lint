#!/usr/bin/env sh
set -e

echo "Running Drupal lint checks..."

phpcs --standard=vendor/ict-nick/drupal-lint/config/phpcs.xml.dist
phpstan analyse --configuration=vendor/ict-nick/drupal-lint/config/phpstan.neon
eslint .
stylelint "**/*.css"
cspell "**/*.{php,js,css,md}"

echo "✔ All lint checks passed"