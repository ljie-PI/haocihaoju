# Haocihaoju

A Flutter app for:
- multi-page article scanning with phone camera,
- server-side OCR text extraction and page merge,
- LLM-style literary quote mining and commentary,
- local excerpt storage with cloud-ready repository interfaces.

## MVP Features Implemented

1. Camera scan flow (scan pages one by one)
2. OCR extraction per page (remote OCR service)
3. Multi-page text merge into one article body
4. Literary excerpt suggestions with contextual analysis
5. Local excerpt list (SQLite)
6. Cloud migration-ready data interface (`CloudQuoteSync`)

## Project Structure

- `lib/src/ui/screens/scan_screen.dart`: scan, OCR, analyze, save
- `lib/src/ui/screens/quotes_screen.dart`: saved excerpts list
- `lib/src/services`: remote OCR + LLM analysis abstractions/implementations
- `lib/src/data`: repository + local datasource + cloud sync interface
- `lib/src/models`: core domain models

## Run

```bash
flutter pub get
flutter run \
  --dart-define=OCR_API_URL=https://your-api.example.com/ocr \
  --dart-define=OCR_API_KEY=your-key
```

## Remote OCR Contract

- Request:
  - `POST` multipart/form-data
  - image field name defaults to `image` (override with `--dart-define=OCR_IMAGE_FIELD=...`)
- Authentication:
  - default header `Authorization: Bearer <OCR_API_KEY>`
  - override header name with `--dart-define=OCR_API_KEY_HEADER=...`
- Response text parsing:
  - defaults to field path `text` (override with `--dart-define=OCR_TEXT_FIELD=...`)
  - also auto-fallbacks common fields like `ocr_text`, `result.text`, `data.text`

## Notes for Cloud Migration

The app already separates storage behind `QuoteRepository` and `CloudQuoteSync`.
To migrate to cloud later:
1. Implement a concrete `CloudQuoteSync` (REST/Firebase/Supabase).
2. Pass it into `LocalQuoteRepository(cloudSync: ...)`.
3. Add auth and conflict resolution policy.
