# flight_tracker


### Flight Tracker Flutter app that shows live aircraft positions, altitude, speed, and heading on an interactive map and list, sourced directly from the OpenSky Network's public REST API. There's no backend server, database, or API key in the loop, the app calls OpenSky and renders OpenStreetMap tiles straight from the client, refreshing automatically every 15 seconds. The codebase is split into clear layers (models, services, providers, screens, widgets, utils) so the data source, state management, and UI can each be modified independently. Note: because it hits a third-party API with no backend proxy, web builds are subject to that API's CORS policy, mobile and desktop builds are unaffected.

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



