# Portfolio 5 – Distributed and Cloud Databases (Wakawell)

## Overview
This portfolio discusses how Wakawell's database would scale as a distributed, cloud-hosted
system. It covers replication, sharding, and the trade-off between consistency and
availability. A real cloud deployment (Neo4j AuraDB) from Portfolio 4 is used as evidence.

## 1. Replication – reads and writes
Wakawell's workload is uneven. At rush hour, thousands of riders search routes and fares,
but only the two administrators ever change the data.

**Design: one primary database and several read replicas.**
- **All writes** (new stops, fare updates) go to the **primary**. There is only ever one
  place where data changes, so copies can never disagree about the "real" fare.
- The primary automatically copies each change to the **replicas**.
- **All rider searches** go to the replicas, which spreads the load across several servers.

**Benefits:** faster searches at peak times, and if one replica fails, riders are sent to
another, so the service stays up.

## 2. Sharding – splitting the data by city
If Wakawell expands to Lagos, the data would be **sharded by city**: Abuja's stops, routes
and fares on one server, Lagos's on another.

- **Advantage:** each server handles a smaller workload, and searches only look at one
  city's data. Riders are sent to the right shard by their location, in the same way
  ride-hailing apps detect which city a user is in.
- **Usual problem:** a journey *between* cities would need data from both shards, which
  makes queries more complex.
- **Why it suits Wakawell:** Wakawell plans journeys *within* a city, not between states,
  so cross-shard queries would be rare. City is a natural shard key.

## 3. Consistency vs availability
When a fare is updated on the primary, the replicas may show the old fare for a few
seconds until they catch up.

**Choice: show the slightly old value and let it catch up (eventual consistency).**
A fare that is a few seconds out of date causes little harm, but a blank screen at rush
hour would frustrate riders. This puts **availability** first, in line with the CAP
theorem's trade-off between consistency and availability during network problems.

Where accuracy matters most, such as admin edits to the same fare (Portfolio 3), the
**primary** still enforces strict consistency with transactions and locks.

## 4. Cloud deployment evidence
The graph database in Portfolio 4 runs on **Neo4j AuraDB Free**, a managed cloud service
hosted on **Google Cloud (europe-west1, Belgium)**. The cloud provider handles servers,
backups and uptime, so the team does not manage hardware.

| Option | Pros | Cons |
|---|---|---|
| Self-hosted server | Full control, data stays local | Team must manage hardware, backups, power and connectivity |
| Managed cloud (e.g. AuraDB, Amazon RDS) | Easy scaling, automatic backups, high uptime | Ongoing cost; data may be hosted outside Nigeria |

For a two-person team, a managed cloud database is the practical choice. Hosting location
would need reviewing against Nigerian data protection rules (NDPA 2023) before handling
any personal rider data.

## Evidence
- `aura-instance.png` – Neo4j AuraDB Free instance running in the cloud
