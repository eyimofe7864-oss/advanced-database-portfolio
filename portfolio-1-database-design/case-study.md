# Wakawell – Case Study

## The organisation
Wakawell is an Abuja-first mobility intelligence platform designed to help people
navigate the city's public transportation system, particularly shared taxis and other
forms of informal transport. It provides information about routes, stops, landmarks,
fares and transfers, using local transport knowledge to help users understand how to
get from one location to another without relying on expensive ride-hailing services.

## Users
- **Riders** – the main users. They search for routes, check fares and find stops.
- **Administrators** – the two-person development team, who add and update routes,
  stops, landmarks and fares.
- **Drivers** – planned as future service providers. They are outside the scope of
  this version of the database.

## What the database must store
- **Corridors** – major roads shared by several routes (e.g. the Kubwa Expressway).
- **Stops** – pick-up and drop-off points, with their location.
- **Landmarks** – recognisable places near stops (markets, banks, junctions) that help
  riders identify where to board or alight.
- **Routes** – a journey made up of an ordered sequence of stops, with a vehicle type
  (shared taxi, bus or keke).
- **Fares** – the price of travelling between stops on a route.
- **Transfers** – points where a rider changes from one route to another.

## Key operations
1. Find a route from one location to another, including transfers.
2. Check the fare for a trip.
3. Find the nearest stop to a given location.

## Why a database is needed
Today, this information lives in people's heads and in informal channels. Without a
structured database, fares become wrong or outdated, the same stop gets recorded more
than once under different names, riders receive conflicting directions, and updates
made by different administrators can overwrite each other. A relational database with
keys, constraints and normalisation keeps one correct, consistent version of each fact.

## Scope and data
This version covers route information for riders and data maintenance by
administrators, for selected Abuja corridors. Rider accounts, saved trips,
rider fare reports, driver accounts and live vehicle tracking are planned
future extensions and are deliberately left out to keep the design focused.
The dataset used in this portfolio is a simplified sample, not Wakawell's
production data.
