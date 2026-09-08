#!/bin/bash
# Bootstrap after a fresh clone, and again after changing an ARB file or an
# annotated SDK class.
#
# Root `flutter pub get` resolves the app but writes no package_config for
# the three nested packages, and the analyzer needs each one — a fresh
# clone that skipped this step showed 289 errors, every one of them an
# unresolved import. build_runner used to paper over it for the SDK alone
# by pub-getting implicitly; the other two packages got nothing.
set -e
cd "$(dirname "$0")"

for pkg in forumcopilot_sdk discourse_core discourse_ui; do
  echo "Resolving packages/$pkg..."
  (cd "packages/$pkg" && dart pub get)
done

# Only the SDK has generated code (dart_mappable / json_annotation) and its
# output is committed; this regenerates it after a model change.
# discourse_core and discourse_ui have none.
echo "Generating forumcopilot_sdk mappers..."
(cd packages/forumcopilot_sdk && dart run build_runner build --delete-conflicting-outputs)

echo "Generating localizations..."
flutter gen-l10n
echo "Done."
