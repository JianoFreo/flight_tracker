# Flight Tracker

A real-time flight tracking app built with Flutter. It fetches **live aircraft
data directly from the device/browser** — there is no backend server, no
database, and no API key required to run it.

## Features

- **Live tracking**: list and map views of currently airborne/grounded
  aircraft, auto-refreshing on a configurable interval.
- **Region picker**: scope queries to a continent (or the whole world).
- **Search**: filter by callsign or origin country.
- **Filter & sort**: ground/airborne filter, altitude range slider, and
  sort by callsign, altitude, speed, country, or last contact.
- **Nearby tab**: uses the device's GPS (on demand, with permission) to
  sort tracked aircraft by distance from you.
- **Favorites**: star any aircraft to track it on its own screen;
  persisted locally so it survives app restarts.
- **Statistics dashboard**: aircraft counts, average/highest altitude,
  fastest ground speed, and a bar chart of top origin countries, all
  computed client-side from data already fetched.
- **Settings**: light/dark/system theme, imperial vs. metric units, and
  refresh interval, all persisted locally.
- **Offline fallback**: if a refresh fails, the app shows the last
  successfully fetched data (clearly labeled as cached) instead of an
  empty screen.
- **Country flags**: best-effort flag emoji next to origin country.


<table>
<tr>
<td align="center">

<img width="320" height="707" alt="image" src="https://github.com/user-attachments/assets/e98d9fcc-c66c-479d-93a2-7cf8c3485c92" />
</td>

<td align="center">

<img width="326" height="701" alt="image" src="https://github.com/user-attachments/assets/329c7fd3-a818-4601-8d16-bfa4e34a11e8" />

</td>
</tr>
</table>
<table>
<tr>
<td align="center">

<img width="356" height="772" alt="image" src="https://github.com/user-attachments/assets/1faa69dd-21fb-4a50-96c0-af63ae46f804" />
</td>

<td align="center">
<img width="352" height="768" alt="image" src="https://github.com/user-attachments/assets/07e88b42-19d1-4d41-be54-5f923f3fbfc5" />

</td>
</tr>
</table
# Flight Tracker

A real-time flight tracking app built with Flutter. It fetches **live aircraft
data directly from the device/browser** — there is no backend server, no
database, and no API key required to run it.

## How it works

- **Data source:** [OpenSky Network](https://opensky-network.org/) public
  REST API (`/api/states/all`). It's free, requires no signup for light use,
  and returns live aircraft position, altitude, speed, heading, and more.
- **No backend:** the Flutter app calls the OpenSky API straight from
  `FlightService` using the `http` package. There is nothing to host or
  deploy server-side.
- **Maps:** rendered with `flutter_map` using OpenStreetMap raster tiles,
  which also require no API key.


Each layer only talks to the one below it (screens → widgets → provider →
service → model).



