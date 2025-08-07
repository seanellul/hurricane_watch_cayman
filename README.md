# 🌪 Cayman Hurricane Watch

A comprehensive hurricane preparedness app for the Cayman Islands, providing real-time weather updates, hurricane tracking, and emergency preparedness resources.

## Features

### 📰 Latest News
- Real-time hurricane-related news from Cayman Compass, Loop Cayman, and NHC Advisories
- RSS feed integration with automatic filtering for hurricane-related content
- Pull-to-refresh functionality for latest updates

### 🌤 Weather Updates
- Current weather conditions for Cayman Islands
- Interactive map showing active hurricane locations
- Hurricane tracking with category information and storm details
- Real-time weather data from Open-Meteo API
- NHC (National Hurricane Center) integration for storm data

### 📊 Dashboard
- Hurricane preparedness checklist generator
- Emergency contact information with one-tap calling
- Household profile setup for personalized checklists
- Progress tracking for preparedness items
- Vendor integration for essential supplies

## Technical Stack

- **Frontend**: Flutter (cross-platform iOS/Android)
- **State Management**: Provider pattern
- **Maps**: Flutter Map with OpenStreetMap tiles
- **Data Sources**: 
  - Open-Meteo API for weather data
  - NHC JSON feeds for hurricane data
  - RSS feeds for news content
- **UI**: Material Design 3 with custom Cayman-themed color palette

## Color Palette

- **Navy**: #002B49 (Primary)
- **Storm Cyan**: #00A8C8 (Secondary)
- **Alert Orange**: #FF6F00 (Tertiary)
- **Light Gray**: #F5F5F5 (Background)
- **Dark Gray**: #333333 (Text)

## Getting Started

1. Ensure you have Flutter installed and configured
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter packages pub run build_runner build` to generate JSON serialization code
5. Run `flutter run` to start the app

## Project Structure

```
lib/
├── models/           # Data models with JSON serialization
├── services/         # API services and data fetching
├── providers/        # State management with Provider
├── screens/          # Main app screens
├── widgets/          # Reusable UI components
└── utils/           # Theme and utility functions
```

## Data Sources

### Weather Data
- **Open-Meteo API**: Current weather and forecasts for Cayman Islands
- **NHC Active Storms**: Real-time hurricane tracking data
- **NHC GIS Feeds**: Storm tracks, wind fields, and watch/warning zones

### News Sources
- **Cayman Compass**: Local news and weather updates
- **Loop Cayman**: Regional news coverage
- **NHC Advisories**: Official hurricane advisories

### Emergency Information
- **Cayman Islands Emergency Services**: Police, Fire, Hospital contacts
- **Government Information**: Official emergency procedures
- **Red Cross**: Disaster relief resources

## Development Notes

- The app uses mock data for development when APIs are unavailable
- RSS feeds are parsed and filtered for hurricane-related content
- Map visualization shows hurricane locations relative to Cayman Islands
- Checklist system adapts quantities based on household size and needs

## Future Enhancements

- Push notifications for storm alerts
- Offline mode with cached data
- Historical storm data visualization
- Enhanced vendor integration with real-time inventory
- User accounts and saved household profiles
- Animated weather visualizations

## License

This project is developed for the Cayman Islands community as a hurricane preparedness tool.
# hurricane_watch_cayman
