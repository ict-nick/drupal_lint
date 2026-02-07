#!/usr/bin/env sh

# Do NOT exit on first error
set +e

FAILED=0
MISSING=0

echo "Running Drupal lint checks…"
echo

# Helper: check command existence
check_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Helper: run a command and track failure
run_check() {
  LABEL="$1"
  CMD="$2"

  echo "▶ $LABEL"
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

if check_cmd phpcs; then
  run_check "PHPCS (Drupal standards)" \
    "phpcs --standard=vendor/ict-nick/drupal-lint/config/phpcs.xml.dist"
else
  MISSING=1
  FAILED=1
  echo "✖ PHPCS not found"
  echo "  Install with:"
  echo "    composer require --dev drupal/coder squizlabs/php_codesniffer"
  echo
fi

# ---- PHPSTAN --------------------------------------------------

if check_cmd phpstan; then
  run_check "PHPStan (Drupal)" \
    "phpstan analyse --configuration=vendor/ict-nick/drupal-lint/config/phpstan.neon"
else
  MISSING=1
  FAILED=1
  echo "✖ PHPStan not found"
  echo "  Install with:"
  echo "    composer require --dev phpstan/phpstan mglaman/phpstan-drupal"
  echo
fi

# ---- ESLINT ---------------------------------------------------

if check_cmd eslint; then
  run_check "ESLint" "eslint ."
else
  MISSING=1
  FAILED=1
  echo "✖ ESLint not found"
  echo "  Install with:"
  echo "    npm install --save-dev eslint eslint-config-drupal"
  echo
fi

# ---- STYLELINT ------------------------------------------------

if check_cmd stylelint; then
  run_check "Stylelint" 'stylelint "**/*.css"'
else
  MISSING=1
  FAILED=1
  echo "✖ Stylelint not found"
  echo "  Install with:"
  echo "    npm install --save-dev stylelint stylelint-config-standard"
  echo
fi

# ---- CSPELL ---------------------------------------------------

if check_cmd cspell; then
  run_check "CSpell" 'cspell "**/*.{php,js,css,md}"'
else
  MISSING=1
  FAILED=1
  echo "✖ CSpell not found"
  echo "  Install with:"
  echo "    npm install --save-dev cspell"
  echo
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
