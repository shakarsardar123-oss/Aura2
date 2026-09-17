#!/data/data/com.termux/files/usr/bin/bash

PROJECT_ROOT="$HOME/New-agent"
cd "$PROJECT_ROOT" || exit 1

WRAPPER_FILE="android/gradle/wrapper/gradle-wrapper.properties"

echo "=== دروستکردنی فۆڵدەر و فایلی wrapper بە دەست ==="
mkdir -p android/gradle/wrapper
cat > "$WRAPPER_FILE" <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
EOF

echo "✅ فایل دروستکرا:"
cat "$WRAPPER_FILE"

echo ""
echo "=== زۆرکردن بۆ زیادکردنی بۆ git (بەبێ گوێدانە .gitignore) ==="
git add -f "$WRAPPER_FILE"
git status

echo ""
echo "=== ناردن بۆ GitHub ==="
if git diff --cached --quiet; then
    echo "ℹ️ هیچ گۆڕانکارییەک نییە"
else
    git commit -m "fix: add missing gradle-wrapper.properties (gradle 8.9)"
    git push
fi
