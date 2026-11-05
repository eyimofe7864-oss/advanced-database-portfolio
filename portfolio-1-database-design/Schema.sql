CREATE DATABASE IF NOT EXISTS wakawell_portfolio;
USE wakawell_portfolio;

CREATE TABLE IF NOT EXISTS corridors (
    corridor_id  INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS stops (
    stop_id    INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    latitude   DECIMAL(9,6) NOT NULL,
    longitude  DECIMAL(9,6) NOT NULL
);

CREATE TABLE IF NOT EXISTS landmarks (
    landmark_id  INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    type         VARCHAR(50),
    stop_id      INT NOT NULL,
    FOREIGN KEY (stop_id) REFERENCES stops(stop_id)
);

CREATE TABLE IF NOT EXISTS routes (
    route_id      INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(150) NOT NULL UNIQUE,
    vehicle_type  ENUM('shared taxi', 'bus', 'keke') NOT NULL,
    corridor_id   INT NOT NULL,
    FOREIGN KEY (corridor_id) REFERENCES corridors(corridor_id)
);

CREATE TABLE IF NOT EXISTS route_stops (
    route_id    INT NOT NULL,
    stop_id     INT NOT NULL,
    stop_order  INT NOT NULL,
    PRIMARY KEY (route_id, stop_order),
    UNIQUE (route_id, stop_id),
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    FOREIGN KEY (stop_id)  REFERENCES stops(stop_id)
);

CREATE TABLE IF NOT EXISTS fares (
    fare_id       INT AUTO_INCREMENT PRIMARY KEY,
    route_id      INT NOT NULL,
    from_stop_id  INT NOT NULL,
    to_stop_id    INT NOT NULL,
    amount        DECIMAL(8,2) NOT NULL,
    CHECK (amount > 0),
    CHECK (from_stop_id <> to_stop_id),
    UNIQUE (route_id, from_stop_id, to_stop_id),
    FOREIGN KEY (route_id)     REFERENCES routes(route_id),
    FOREIGN KEY (from_stop_id) REFERENCES stops(stop_id),
    FOREIGN KEY (to_stop_id)   REFERENCES stops(stop_id)
);

CREATE TABLE IF NOT EXISTS transfers (
    transfer_id    INT AUTO_INCREMENT PRIMARY KEY,
    from_route_id  INT NOT NULL,
    to_route_id    INT NOT NULL,
    from_stop_id   INT NOT NULL,
    to_stop_id     INT NOT NULL,
    walking_note   VARCHAR(255),
    FOREIGN KEY (from_route_id) REFERENCES routes(route_id),
    FOREIGN KEY (to_route_id)   REFERENCES routes(route_id),
    FOREIGN KEY (from_stop_id)  REFERENCES stops(stop_id),
    FOREIGN KEY (to_stop_id)    REFERENCES stops(stop_id)
);