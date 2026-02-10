# Haocihaoju

A Flutter app for:
- multi-page article scanning with phone camera,
- on-device OCR text extraction and page merge (ML Kit),
- LLM-style literary quote mining and commentary,
- local excerpt storage with cloud-ready repository interfaces.

## MVP Features Implemented

1. Camera scan flow (scan pages one by one)
2. OCR extraction per page (on-device ML Kit)
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
flutter run
```

## OCR Implementation

- Current default OCR is on-device `ML Kit Text Recognition`.
- No OCR API URL or API key is required for scan and recognize.

## Notes for Cloud Migration

The app already separates storage behind `QuoteRepository` and `CloudQuoteSync`.
To migrate to cloud later:
1. Implement a concrete `CloudQuoteSync` (REST/Firebase/Supabase).
2. Pass it into `LocalQuoteRepository(cloudSync: ...)`.
3. Add auth and conflict resolution policy.
