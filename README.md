# Smart-X · IoT ingestion & validation gateway

A consolidated **Parts 1, 2 and final POE application**: a .NET 10 API, responsive browser dashboard,
typed telemetry processing, simulated devices, sensor profiles, file attachments,
recursive deployment validation, and an interactive incident replay desk.

**Start here:** extract the entire ZIP first. Install the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0),
then double-click **Start-SmartX.cmd** on Windows. The dashboard opens at
**http://localhost:5080**. Keep the terminal window open while using the app.

No paid API, cloud account, Node.js, hardware, database server, or frontend package
installation is needed to run the application. The frontend is native HTML, CSS
and JavaScript ES modules, served by the .NET API on the same origin.

## Open in Visual Studio 2026

1. Extract the entire ZIP and open **SmartX.sln**.
2. In Visual Studio Installer, ensure **ASP.NET and web development** and
   the **.NET 10 SDK** are installed.
3. In Solution Explorer, right-click **SmartX.Api → Set as Startup Project**.
4. Choose the **SmartX** launch profile, build with **Ctrl+Shift+B**, and
   start with **Ctrl+F5**. The browser opens at **http://localhost:5080**.

The API and frontend start together. Do not set the Core library or Tests
runner as the startup project. See `START-HERE.txt` for the short checklist.

## Run from a terminal

Open a terminal in the folder containing `SmartX.sln`:

```sh
dotnet --list-sdks
dotnet restore SmartX.sln
dotnet build SmartX.sln -c Release
dotnet run --project src/SmartX.Api -c Release --no-build
```

Open **http://localhost:5080** after the server reports that it is listening.
On macOS/Linux, `bash start.sh` performs the build and run steps. Press **Ctrl+C**
to stop cleanly. A modern Chrome, Edge, Firefox or Safari browser is required.
Do not open `index.html` directly: the running API is part of the application.

If port 5080 is occupied:

```sh
dotnet run --project src/SmartX.Api -c Release -- --urls=http://localhost:5085
```

Then open `http://localhost:5085`. The frontend uses relative API URLs, so it follows
the new port automatically. The Windows launcher always opens the default port.

## What is included

| Workspace | Working features |
|---|---|
| Gateway home | All three linked pillars are active: sensor telemetry, simulated command history, and mesh topology. |
| Live overview | Arrival rate, accepted/rejected counts, current device status, aggregate power, live charts, threshold bands and incident shortcuts. |
| Sensor registry | Search, type/status filters, pagination, registration, editing and confirmed deletion. |
| Sensor profile | Live history, CSV export, identifiers, location, thresholds, linked configuration/photo/log uploads, download and deletion. |
| Incident desk | Threshold/delta anomaly detection, missed-heartbeat alerts, captured evidence, animated replay, scrubbing, acknowledgement and automatic recovery. |
| Telemetry lab | Pause/resume, gateway emission cycle, bulk sensor seeding, spike/disconnect/restore scenarios, editable typed JSON batches and actual API results. |
| Deployments | Nested profile editor, recursive validation, enabled-ancestor rules, tree view and protection against orphaned sensors. |
| Command history (Part 2) | FIFO simulated command queue, persistent processing status, simulated ping/disconnect/restore/spike and LIFO undo. |
| Indexed telemetry (final POE) | AVL index keyed by timestamp + sequence; inclusive efficient range searches, tree height and indexed count. |
| Network topology (final POE) | Graph nodes and weighted bidirectional edges, visual mesh, offline-node isolation, BFS/DFS traversal, Dijkstra route, Prim spanning forest. |
| Quick start | In-app walkthrough and explanation of gateway behavior. |

The initial environment contains **96 simulated sensors and 5,760 historical
readings**, spread across a hydroponic farm, estate utilities and smart-grid
feeders. The simulator continues sending data every two seconds by default.
Use **Seed sensors** to add up to 2,000 devices at a time, within the 5,000-device
gateway limit. Each new device receives 60 historical readings through the same
validation pipeline as live data.

## Required C# concepts

| Requirement | Implementation and actual use |
|---|---|
| Generic wrapper class | `src/SmartX.Core/Telemetry.cs`: `TelemetryPacket<T>` holds `float`, `int` or `bool`. `Services/Ingestion.cs` uses separate typed stores and endpoints. |
| Operator overloading | `PowerReading` supports `+`, `-`, `<`, `>`; `MoistureReading` supports `-`, `<`, `>`. Dashboard aggregate power executes `+`; anomaly detection executes delta subtraction and moisture comparison. |
| Advanced arrays and lists | `TelemetryBatch<T>` carries a jagged `TelemetryPacket<T>[][]`. `BatchBuffer.Flatten<T>` checks size and copies in order into a preallocated `List<TelemetryPacket<T>>`. Simulation seeds history through this path. |
| Recursion | `DeploymentValidator` recursively validates nested profiles and derives enabled leaf paths. Registration and profile updates use it. Cycles, duplicate IDs, excessive depth and disabled ancestors are handled. |
| API integration | `src/SmartX.Client/api.js` calls the ASP.NET Core Minimal API. Registration, history, telemetry, uploads, configuration and incidents all use real endpoints. |

`float`, `int` and `bool` stay native throughout ingestion and retained storage.
The chart projection converts numerical values for display only. It does not
replace the typed pipeline. JSON numeric strings and string booleans are rejected.

## Final POE — major data structures and algorithms

### AVL self-balancing binary search tree

`src/SmartX.Core/TimeIndex.cs` implements rotations, insertion, removal and
an inclusive timestamp search keyed by `(timestamp, sequence)`. The index is
maintained as accepted telemetry arrives and pruned when retention evicts
readings; restored snapshots rebuild the index on startup. A balanced AVL tree
keeps insertion/deletion at **O(log n)** and a range lookup at approximately
**O(log n + k)** for k returned readings. This is a real index, not a list
scan (Sedgewick and Wayne, 2011). Open **Indexed telemetry** to query a sensor.

### Graph, traversal, routing and minimum spanning forest

`src/SmartX.Core/Mesh.cs` models an undirected weighted adjacency-list graph.
The gateway creates simulation-specific links between devices in the same
location, with redundant peer connections and a gateway link per location.
**BFS** explores in increasing hop count; **DFS** explores depth first;
**Dijkstra** finds minimum total simulated cost, while **Prim** constructs the
minimum-cost spanning forest with a `PriorityQueue<TElement,TPriority>`
(Cormen et al., 2022; Microsoft, n.d.). Offline devices are visible but isolated
and cannot be used by routes. Costs are **deterministic simulation units**, not
measured Wi-Fi strength, hardware path costs or evidence of an operational
ESP32 mesh. Route requests validate node IDs and return not-found when no
traversable route exists. Use **Mesh topology** and switch between all links
and the minimum spanning forest.

### FIFO command stream and undo stack

`src/SmartX.Api/Services/Commands.cs` uses `Queue<Guid>` for incoming commands
and `Stack<Guid>` for latest-first reversal; the background worker updates
command status. A bounded 500-entry log is checkpointed, including pending
commands. **Command effects are simulation-only.** Commands never actuate
external sensors or real devices. Open **Command history** to demonstrate.

### New REST endpoints

| Endpoint | Purpose |
|---|---|
| `GET /api/sensors/{id}/telemetry/range?from=...&to=...&limit=500` | Inclusive AVL timestamp query |
| `GET /api/network/topology?maxNodes=100` | Display nodes, edges, BFS/DFS, Prim MST/forest |
| `GET /api/network/route?from=gateway&to={sensorGuid}&algorithm=dijkstra` | Dijkstra or BFS route |
| `GET /api/commands?take=100` | Persistent command history |
| `POST /api/commands` | Queue `{ "sensorId": "...", "action": "Ping" }` |
| `POST /api/commands/undo` | Reverse most recent applied simulated-state change |

**API limits:** mesh display 5–500 sensors (backend routing supports the entire
registered local mesh); query result cap 2,000 and search-window cap 365 days;
command queue cap 100 pending and command retention cap 500. Historical telemetry
still uses the existing 30–2,000 packets-per-sensor rolling retention.

For the algorithm explanations and IIE Harvard reference list, see
`docs/REFERENCES.md`. For the assessment mapping see `docs/POE_RUBRIC_MAP.md`.

## Try the complete workflow

1. Open **Live overview** and check the readings arriving from seeded devices.
2. Open **Sensor registry → Register sensor**. Enter a name, a unique identifier,
   a category/type, an enabled deployment location and alert thresholds.
3. Open the sensor profile and upload `samples/device-config.json` or
   `samples/hardware.log`. Download it to verify the attachment.
4. Open **Telemetry lab**. Choose a simulated moisture probe and click **Inject spike**.
5. Open **Incident desk → Replay evidence**. Play or scrub through the captured
   readings and review the recommended investigation step.
6. **Acknowledge** the incident. It remains open until the readings recover.
7. In the lab, click **Restore signal**. Two normal readings may be needed: the
   first return from a spike can itself exceed the delta threshold.
8. Click **Disconnect**. Wait for the heartbeat grace period, then investigate
   the critical incident. Restore the signal and observe automatic recovery.
9. Pause the stream, generate a 32-reading JSON payload, and send it. Change one
   value to a string or reuse an old sequence to demonstrate rejection.
10. Download a sensor's CSV history, stop the application and restart it. Sensor
    configuration, retained readings, incidents and attachments remain available.

## Validation behavior

- Moisture is a finite `float` from 0–100%; power is an `int` from 0–1,000,000 W;
  valves use genuine JSON booleans.
- Each sensor has a strictly increasing positive sequence. Duplicate and
  out-of-order sequences are rejected. Timestamps may equal the last timestamp,
  but cannot go backwards, exceed 30 seconds into the future, or be over 24 hours old.
- Request structure and JSON-type errors return HTTP 400. Validly structured
  batches return HTTP 200 with per-packet `accepted`, `rejected`, `errors` and
  processing time. Valid rows still ingest when other rows are rejected.
- Values outside physical type limits are rejected. Values inside physical
  limits but beyond the configured alert thresholds are accepted and flagged.
- An alert opens for values below/above the thresholds or an absolute change
  greater than the delta limit. Threshold equality is normal. Boolean transitions
  are ordinary state changes, not numeric anomalies.
- Disconnect detection uses **server receipt time**, not the sensor timestamp.
  The grace period is `max(10 seconds, 3 × expected reporting interval)`.
- A deliberate simulation pause suspends heartbeat monitoring of simulated
  devices except explicitly disconnected devices. External devices remain monitored.
- Acknowledgement means the incident has been seen. It does not mark a failing
  sensor healthy. A fresh normal reading/heartbeat resolves the relevant incident.

## Data and capacity

Configuration is in `src/SmartX.Api/appsettings.json`. With `dotnet run`, data
is stored in `src/SmartX.Api/data/`. This folder is excluded from Git and publishing.

| Setting | Default / bounds |
|---|---|
| `SmartX:SeedSensorCount` | 96 on the first launch; configurable 3–2,000 |
| `SmartX:StartSimulator` | `true` on the first launch |
| `SmartX:HistoryPerSensor` | 300 retained packets per sensor; 30–2,000 |
| `SmartX:PersistenceSeconds` | 15 seconds; 5–300 |
| `SmartX:DataDirectory` | `data`, relative to the API content root |
| Request size | 6 MiB; file bytes limited to 5 MiB |
| Ingestion batch | At most 4,096 packets across at most 128 jagged rows |
| Sensor count | At most 5,000 |
| Incident retention | Most recent 1,000; resolved incidents evicted first when full |
| Attachment quota | 10 files per sensor; 500 MiB per gateway |

The app checkpoints the typed in-memory state using an atomic file replacement.
Configuration mutations save immediately; telemetry saves periodically and on
graceful shutdown. A hard crash can lose readings since the last checkpoint.
History retention is intentionally bounded; export data before it rolls out.
Incident evidence is captured separately with its original alert thresholds.

Back up the entire `data` directory **while the app is stopped**. To reset the demo,
stop it and rename that directory to a backup name, then restart. Do not delete
your only copy of work you intend to keep. Corrupt checkpoints stop startup with
an error; they are never silently overwritten with seed data.

## Build and verify

```sh
dotnet build SmartX.sln -c Release
dotnet run --project tests/SmartX.Tests -c Release --no-build
python scripts/integration_test.py
```

The core test project is a dependency-free executable test runner: it exits
non-zero on failure. Use `dotnet run`, not `dotnet test`. The integration script
requires Python 3.10+ and starts its own gateway on port 5091 with a temporary data
directory. It covers actual HTTP endpoints, file-upload tokens, persistence,
typed payload rejection, incident recovery, 4,096-packet batches and 1,000-device seeding.

Optional browser checks require Node.js and Playwright only for testing:

```sh
npm install --no-save playwright
npx playwright install chromium
node scripts/browser_test.cjs
```

The browser script uses an isolated gateway on port 5092, exercises the UI at
desktop and mobile sizes, and writes screenshots/results under `artifacts/`.
These development dependencies are not required to run Smart-X. In locked-down
build environments, `dotnet build -m:1 -p:UseSharedCompilation=false` avoids
MSBuild/compiler-server IPC restrictions.

See `docs/VERIFICATION.md` for the results obtained for this delivery.

## Publishing a runnable folder

```sh
dotnet publish src/SmartX.Api -c Release --no-self-contained -o artifacts/publish
cd artifacts/publish
dotnet SmartX.Api.dll
```

This includes the frontend assets and requires the .NET 10 ASP.NET Core runtime
on the destination machine. The source package requires the .NET 10 SDK for building.
To produce a Windows x64 app that includes its runtime, from a machine with
internet access for runtime-pack restore:

```sh
dotnet publish src/SmartX.Api -c Release -r win-x64 --self-contained true -o artifacts/win-x64
```

Run `SmartX.Api.exe` in that output folder and open `http://localhost:5080`.
Self-contained Windows output is not included in this source delivery.

## Optional Docker

```sh
docker compose up --build
```

Open `http://localhost:5080`. A named volume retains gateway data. The container
runs as the runtime image's non-root application user. The host port binds only
to loopback. Stop with `docker compose down`; the data volume remains.
Docker configuration is included but requires Docker to build and run; see the
verification document for whether it was exercised in this environment.

## GitHub and development history

The original uploaded archive included a **Codex-authored history bundle** (`smartx-history.bundle`). The recovered source and that provenance bundle are preserved. These commits **must not be represented as student-authored work**. Log your own genuine changes and reviews with meaningful commits. The GitHub
repository supplied for this delivery is
`https://github.com/ST10437872-Emeris/PROG7312_POE`.
The connected GitHub account has read access but no write permission to it,
so the project has **not** been uploaded. The ZIP is a complete local delivery.

To inspect the original development provenance separately:

```sh
git clone smartx-history.bundle ../SmartX-original-history
```

For your own submission, **verify the repository owner and ask for write
permission** before uploading anything. Extract this source ZIP, then use
GitHub Desktop to add its folder to an authorised repository. Commit meaningful
changes as you actually make or review them; do not create fictional or
backdated student commits. Do not force-push over an existing team's history.
The included GitHub Actions workflow validates the solution on push.

## Scope and next assessment parts

This is a **local, single-user assessment application**. It uses direct HTTP
telemetry ingestion and simulation; it does not implement an MQTT broker, *physical* mesh routing, *hardware* device commands, multi-user authentication or distributed storage.
It binds to loopback by default and should not be exposed as an authenticated
public service without additional work. Mutation requests require a custom
header; multipart uploads also use ASP.NET Core antiforgery tokens. These checks
do not replace authentication. Files use extension/type checks, safe storage
names, size limits and attachment-only downloads; malware scanning is outside scope.

A final POE report is supplied separately in DOCX and PDF, with **evidence
placeholders** for screenshots and a final results table to complete after
running the solution on the submitting computer. No grade or execution result
is guaranteed. The original incident replay remains fully available.

See `docs/ARCHITECTURE.md`, `docs/API.md`, `docs/REQUIREMENTS.md` and
`docs/DEMO.md` for the developer and presentation handover.

## Final submission checklist (verify yourself)

- `dotnet restore SmartX.sln`, `dotnet build SmartX.sln -c Release` and `dotnet run --project tests/SmartX.Tests -c Release --no-build` finish without errors.
- Run `python scripts/integration_test.py` and investigate any failing checks.
- Open and demonstrate **all three pillars**, telemetry query, graph route, MST, BFS/DFS and simulated command/undo.
- Take authentic UI, test and CLI screenshots, and place them in the report at the labelled placeholders.
- Export the final report to **PDF**. Upload the functioning code to your authorised GitHub repository, with **20+ authentic meaningful project commits** if the rubric requires it.
- Record the requested YouTube demo and include its working URL. Attach a concrete feedback/update ledger identifying changes actually made.
- If using Docker, verify `docker compose up --build`; this environment did **not** execute Docker.

