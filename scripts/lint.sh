#!/usr/bin/env sh

set +e

FAILED=0
MISSING=0

FILES="$(cat)"

if [ -z "$FILES" ]; then
  echo "No relevant files to lint. Skipping."
  exit 0
fi

echo "Running Drupal lint checks on:"
echo "$FILES"
echo

# Split files by type
PHP_FILES=$(echo "$FILES" | grep -E '\.(php|module|inc|install|theme)$' || true)
JS_FILES=$(echo "$FILES" | grep -E '\.js$' || true)
CSS_FILES=$(echo "$FILES" | grep -E '\.css$' || true)

# PHPStan wants directories, not files
PHPSTAN_DIRS=$(echo "$PHP_FILES" | xargs -n1 dirname | sort -u)

check_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_check() {
  LABEL="$1"
  CMD="$2"

  echo "---------> $LABEL"
  echo "---------> $CMD"
  sh -c "$CMD"
  STATUS=$?

  if [ $STATUS -ne 0 ]; then
    FAILED=1
    echo "✖ $LABEL failed"
  else
    echo "✔ $LABEL passed"
  fi

  echo
}

# ---- PHPCS ----------------------------------------------------

if [ -n "$PHP_FILES" ]; then
  if check_cmd phpcs; then
    run_check "PHPCS (Drupal standards)" \
      "phpcs --standard=vendor/ict-nick/drupal-lint/config/phpcs.xml.dist $PHP_FILES"
  else
    MISSING=1
    FAILED=1
    echo "✖ PHPCS not found"
    echo "  Install with:"
    echo "    composer require --dev drupal/coder squizlabs/php_codesniffer"
    echo
  fi
fi

# ---- PHPSTAN --------------------------------------------------

if [ -n "$PHPSTAN_DIRS" ]; then
  if check_cmd phpstan; then
    run_check "PHPStan (Drupal)" \
      "phpstan analyse --configuration=vendor/ict-nick/drupal-lint/config/phpstan.neon $PHPSTAN_DIRS"
  else
    MISSING=1
    FAILED=1
    echo "✖ PHPStan not found"
    echo "  Install with:"
    echo "    composer require --dev phpstan/phpstan mglaman/phpstan-drupal"
    echo
  fi
fi

# ---- ESLINT ---------------------------------------------------

if [ -n "$JS_FILES" ]; then
  if check_cmd eslint; then
    run_check "ESLint" \
      "eslint --no-eslintrc --config vendor/ict-nick/drupal-lint/config/.eslintrc.json $JS_FILES"
  else
    FAILED=1
    echo "✖ ESLint not found"
    echo
    echo "  JavaScript files were detected, but ESLint is not available."
    echo "  To enable JavaScript linting (Drupal standards), install:"
    echo
    echo "    npm install --save-dev eslint@^8 eslint-config-drupal"
    echo
  fi
fi

# ---- STYLELINT ------------------------------------------------

if [ -n "$CSS_FILES" ]; then
  if check_cmd stylelint; then
    run_check "Stylelint" "stylelint $CSS_FILES"
  else
    MISSING=1
    FAILED=1
    echo "✖ Stylelint not found"
    echo "  Install with:"
    echo "    npm install --save-dev stylelint stylelint-config-standard"
    echo
  fi
fi

# ---- SUMMARY --------------------------------------------------

if [ $FAILED -ne 0 ]; then
  echo
  echo "❌❌❌"
  echo "Lint checks completed with errors."
  echo

  if [ $MISSING -ne 0 ]; then
    echo "⚠️  One or more tools were missing."
    echo "   See installation instructions above."
    echo
  fi

  exit 1
fi

echo
echo "🎉 All lint checks passed"
exit 0
