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

<img width="361" height="772" alt="image" src="https://github.com/user-attachments/assets/8ae7142c-1fb3-427e-bf48-4daae55a02fa" />
</td>

<td align="center">

<img width="357" height="768" alt="image" src="https://github.com/user-attachments/assets/9fad0a00-1585-4d9c-8fc6-916b0414183f" />

</td>
</tr>
</table>
<table>
<tr>
<td align="center">

<img width="363" height="767" alt="image" src="https://github.com/user-attachments/assets/649030fe-c0e6-499a-8072-aae3877fd108" />
</td>

<td align="center">
<img width="352" height="781" alt="image" src="https://github.com/user-attachments/assets/d23f8174-d9c1-4f52-9921-5b21da3117a3" />

</td>
</tr>
</table>
</table>
<table>
<tr>
<td align="center">

<img width="361" height="766" alt="image" src="https://github.com/user-attachments/assets/8e989b34-e404-4067-b36a-db1a53a50502" />
</td>

<td align="center">
<img width="356" height="770" alt="image" src="https://github.com/user-attachments/assets/b7e4ecfd-fa4e-4850-b9a3-97351f9d1168" />

</td>
</tr>
</table>

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







